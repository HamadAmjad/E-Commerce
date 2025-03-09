import 'package:ecommercestore/AboutUsPage.dart';
import 'package:ecommercestore/AddToCartPage.dart';
import 'package:ecommercestore/Drawer.dart';
import 'package:ecommercestore/FavouritePage.dart';
import 'package:ecommercestore/ProductCard.dart';
import 'package:ecommercestore/ProductDetailsPage.dart';
import 'package:flutter/material.dart';
import 'product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState(); // Only call this once
    _fetchProducts();
    _searchController.addListener(_filterProducts);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }


  Future<void> _showWelcomeDialog() async {
    await showDialog(
      context: context,
      //barrierDismissible: false, // Prevents dismissing by tapping outside
      builder: (context) => AlertDialog(
        title: const Text("Welcome!"),
        content: const Text("Enjoy shopping with our latest discounts and offers!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchProducts() async {
    final databaseRef = FirebaseDatabase.instance.ref('products');
    try {
      final snapshot = await databaseRef.get();
      if (!mounted) return; // Ensure the widget is still in the tree

      if (snapshot.exists) {
        final List<Product> loadedProducts = [];
        final Set<String> loadedCategories = {'All'}; // Default category

        for (final entry in snapshot.children) {
          final productData = Map<String, dynamic>.from(entry.value as Map);
          loadedProducts.add(Product(
            name: productData['name'] ?? 'Unknown',
            price: productData['price']?.toDouble() ?? 0.0,
            imageUrl: productData['imageUrl'] ?? '',
            category: productData['category'] ?? 'Other',
            description: productData['description'],
          ));
          loadedCategories.add(productData['category'] ?? 'Other');
        }

        if (!mounted) return; // Check again before calling setState
        setState(() {
          _products = loadedProducts;
          _filteredProducts = loadedProducts;
          _categories = loadedCategories.toList();
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        print('No products found in the database.');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      print('Error fetching products: $error');
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products
          .where((product) =>
      product.name.toLowerCase().contains(query) &&
          (_selectedCategory == 'All' || product.category == _selectedCategory))
          .toList();
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterProducts();
  }

  void _addToFavorites(Product product) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
            'You need to be logged in to add items to favorites!')),
      );
      return;
    }

    final userEmail = user.email;
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email is not available!')),
      );
      return;
    }

    final userFavoritesRef = FirebaseDatabase.instance.ref(
        'favorites/${userEmail.replaceAll('.', ',')}/favoritesItems');

    try {
      final newFavoriteRef = userFavoritesRef.push();
      await newFavoriteRef.set({
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added to favorites!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add to favorites!')),
      );
      print('Error adding to favorites: $error');
    }
  }

  void _addToCart(Product product) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
            'You need to be logged in to add items to the cart!')),
      );
      return;
    }

    final userEmail = user.email;
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email is not available!')),
      );
      return;
    }

    final userCartRef = FirebaseDatabase.instance.ref(
        'carts/${userEmail.replaceAll('.', ',')}/cartItems');

    try {
      final newItemRef = userCartRef.push();
      await newItemRef.set({
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'quantity': 1,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added to cart!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add to cart!')),
      );
      print('Error adding to cart: $error');
    }
  }


  @override
  bool _isSearchExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    int crossAxisCount;

    if (screenWidth < 400) {
      crossAxisCount = 1;
    } else if (screenWidth < 950) {
      crossAxisCount = 2;
    } else if (screenWidth < 1050) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'E-Commerce',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.cyanAccent,
        actions: [
          if (screenWidth < 450)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = !_isSearchExpanded;
                });
              },
            ),
          IconButton(
            icon: const Icon(
                Icons.shopping_cart_checkout_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddToCartPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.star_outline, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isSearchExpanded || screenWidth >= 450 ? kToolbarHeight * 2 : kToolbarHeight),
          child: Column(
            children: [
              if (_isSearchExpanded || screenWidth >= 450)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      border: const OutlineInputBorder(),
                      hintStyle: const TextStyle(color: Colors.black),
                      suffixIcon: screenWidth >= 450
                          ? const Icon(Icons.search, color: Colors.black) // Search icon for big screens
                          : IconButton(
                        icon: const Icon(Icons.close, color: Colors.black), // Close icon for small screens
                        onPressed: () {
                          setState(() {
                            _isSearchExpanded = false;
                            _searchController.clear();
                          });
                        },
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox.shrink(), // Removes extra space when search is hidden
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return GestureDetector(
                      onTap: () => _selectCategory(category),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: _selectedCategory == category ? Colors.white : Colors.cyanAccent,
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

      ),
      drawer: MyDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: _filteredProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final product = _filteredProducts[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsPage(product: product),
                  ),
                );
              },
              child: ProductCard(
                product: product,
                onAddToCart: () => _addToCart(product),
                onAddToFavorites: () => _addToFavorites(product),
              ),
            );
          },
        ),
      ),
    );
  }
}