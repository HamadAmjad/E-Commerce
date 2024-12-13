import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ManageProductsPage extends StatefulWidget {
  @override
  _ManageProductsPageState createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  final DatabaseReference _productsRef =
  FirebaseDatabase.instance.ref().child('products');

  Future<void> _deleteProduct(String productId) async {
    await _productsRef.child(productId).remove();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product deleted successfully!')),
    );
  }

  void _editProduct(String productId, Map productData) {
    TextEditingController nameController =
    TextEditingController(text: productData['name']);
    TextEditingController priceController =
    TextEditingController(text: productData['price'].toString());
    TextEditingController descriptionController =
    TextEditingController(text: productData['description']);
    TextEditingController imageUrlController =
    TextEditingController(text: productData['imageUrl']);
    TextEditingController categoryController =
    TextEditingController(text: productData['category']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(labelText: 'Image URL'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _productsRef.child(productId).update({
                  'name': nameController.text,
                  'price': double.parse(priceController.text),
                  'description': descriptionController.text,
                  'imageUrl': imageUrlController.text,
                  'category': categoryController.text,
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product updated successfully!')),
                );
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.cyanAccent,
          title: Text('Manage Products')),
      body: StreamBuilder(
        stream: _productsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final productsMap = snapshot.data?.snapshot.value as Map?;
          if (productsMap == null) {
            return Center(child: Text('No products found.'));
          }

          final productsList = productsMap.entries.map((entry) {
            return {
              'id': entry.key,
              ...Map<String, dynamic>.from(entry.value),
            };
          }).toList();

          return ListView.builder(
            itemCount: productsList.length,
            itemBuilder: (context, index) {
              final product = productsList[index];
              final productId = product['id'];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  leading: Image.network(
                    product['imageUrl'] ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product['name'] ?? 'Unnamed Product'),
                  subtitle: Text('${product['category']} - \$${product['price']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editProduct(productId, product),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(productId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
