import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserOrdersPage extends StatefulWidget {
  const UserOrdersPage({super.key});

  @override
  _UserOrdersPageState createState() => _UserOrdersPageState();
}

class _UserOrdersPageState extends State<UserOrdersPage> {
  User? _currentUser;
  DatabaseReference? _ordersRef;
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _getUserOrders();
  }

  void _getUserOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
        _ordersRef = FirebaseDatabase.instance.ref('orders').child(user.uid);
      });

      _ordersRef!.onValue.listen((event) {
        if (event.snapshot.exists) {
          final Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> fetchedOrders = [];

          data.forEach((orderId, orderData) {
            // Calculate Total Payment
            double totalPayment = 0.0;
            List<dynamic> items = orderData['items'] ?? [];
            for (var item in items) {
              totalPayment += (item['price'] * item['quantity']);
            }

            fetchedOrders.add({
              'orderId': orderId,
              'name': orderData['name'],
              'phone': orderData['phone'],
              'email': orderData['email'],
              'address': orderData['address'],
              'items': items,
              'orderDate': orderData['orderDate'],
              'totalPayment': totalPayment, // Store total payment
            });
          });

          setState(() {
            _orders = fetchedOrders.reversed.toList(); // Show latest orders first
            _isLoading = false;
          });
        } else {
          setState(() {
            _orders = [];
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.cyanAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(child: Text('No orders found!'))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID: ${order['orderId']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text('Name: ${order['name']}'),
                  Text('Phone: ${order['phone']}'),
                  Text('Email: ${order['email']}'),
                  Text('Address: ${order['address']}'),
                  Text(
                    'Order Date: ${DateTime.parse(order['orderDate']).toLocal()}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const Divider(),
                  const Text(
                    'Items:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...List.generate(
                    (order['items'] as List).length,
                        (i) => ListTile(
                      leading: (order['items'][i]['imageUrl'] ?? '').isNotEmpty
                          ? Image.network(
                        order['items'][i]['imageUrl'],
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                      )
                          : const Icon(Icons.broken_image),
                      title: Text(order['items'][i]['name'] ?? 'Unknown'),
                      subtitle: Text(
                        'Price: \$${order['items'][i]['price']} x ${order['items'][i]['quantity']}',
                      ),
                    ),
                  ),
                  const Divider(),
                  Text(
                    'Total Payment: \$${order['totalPayment'].toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
