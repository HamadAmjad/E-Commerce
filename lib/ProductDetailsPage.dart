import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'product.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  List<Product> _relatedProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchRelatedProducts();
  }

  void _fetchRelatedProducts() async {
    final databaseRef = FirebaseDatabase.instance.ref('products');

    try {
      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        final List<Product> loadedProducts = [];

        for (final entry in snapshot.children) {
          final productData = Map<String, dynamic>.from(entry.value as Map);

          Product product = Product(
            name: productData['name'] ?? 'Unknown',
            price: productData['price']?.toDouble() ?? 0.0,
            imageUrl: productData['imageUrl'] ?? '',
            category: productData['category'] ?? 'Other',
            description: productData['description'],
          );

          // Check if product belongs to the same category but is not the current product
          if (product.category == widget.product.category && product.name != widget.product.name) {
            loadedProducts.add(product);
          }
        }

        setState(() {
          _relatedProducts = loadedProducts;
        });
      }
    } catch (error) {
      print('Error fetching related products: $error');
    }
  }

  void _addToFavorites(BuildContext context, Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to add items to favorites!')),
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

    final userFavoritesRef = FirebaseDatabase.instance
        .ref('favorites/${userEmail.replaceAll('.', ',')}/favoritesItems');

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

  void _addToCart(BuildContext context, Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to add items to the cart!')),
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

    final userCartRef = FirebaseDatabase.instance
        .ref('carts/${userEmail.replaceAll('.', ',')}/cartItems');

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
  Widget build(BuildContext context) {
    List<String> imageUrls = widget.product.imageUrl.split(RegExp(r'\s+')).where((url) => url.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Colors.cyanAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  if (imageUrls.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImage(imageUrl: imageUrls.first),
                      ),
                    );
                  }
                },
                child: Container(
                  height: MediaQuery.of(context).size.width > 800
                      ? 300  // Larger screens (e.g., tablets, desktops)
                      : MediaQuery.of(context).size.width > 450
                      ? 300  // Medium-sized screens
                      : 200, // Small screens (phones)
                  width: double.infinity,
                  child: Image.network(
                    imageUrls.isNotEmpty ? imageUrls.first : '',
                    fit: BoxFit.contain,
                  ),
                ),
              ),


              const SizedBox(height: 16.0),
              Text(widget.product.name, style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Text('\$${widget.product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20.0, color: Colors.green)),
              const SizedBox(height: 16.0),
              const Text("Category", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              Text(widget.product.category, style: const TextStyle(fontSize: 16.0, color: Colors.grey)),
              const SizedBox(height: 16.0),
              const Text("Description", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              Text(widget.product.description ?? 'No description available.', style: const TextStyle(fontSize: 16.0)),
              const SizedBox(height: 16.0),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 450) {
                    return Center(
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _addToCart(context, widget.product),
                            icon: const Icon(Icons.shopping_cart, color: Colors.black),
                            label: const Text("Add to Cart", style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                          ),
                          const SizedBox(height: 8.0),
                          ElevatedButton.icon(
                            onPressed: () => _addToFavorites(context, widget.product),
                            icon: const Icon(Icons.star_outline, color: Colors.black),
                            label: const Text("Add to Favorites", style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _addToCart(context, widget.product),
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text("Add to Cart"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _addToFavorites(context, widget.product),
                          icon: const Icon(Icons.star_outline),
                          label: const Text("Add to Favorites"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 20.0),
              const Text("Related Products", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              SizedBox(
                height: MediaQuery.of(context).size.width > 600 ? 250 : 190, // Responsive height
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double cardWidth = constraints.maxWidth > 600 ? 150 : 100;
                    double imageSize = constraints.maxWidth > 600 ? 120 : 80;
                    double textSize = constraints.maxWidth > 600 ? 18 : 14;
                    double priceSize = constraints.maxWidth > 600 ? 16 : 12;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _relatedProducts.length,
                      itemBuilder: (context, index) {
                        final product = _relatedProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsPage(product: product),
                              ),
                            );
                          },
                          child: Container(
                            width: cardWidth,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Image.network(
                                    product.imageUrl,
                                    height: imageSize,
                                    width: imageSize,
                                    fit: BoxFit.cover,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          product.name,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '\$${product.price.toStringAsFixed(2)}',
                                          style: TextStyle(fontSize: priceSize, color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

