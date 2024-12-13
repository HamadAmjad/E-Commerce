import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() async {
    final ordersRef = FirebaseDatabase.instance.ref('orders');
    try {
      final snapshot = await ordersRef.get();
      if (snapshot.exists) {
        final List<Map<String, dynamic>> loadedOrders = [];

        print('Snapshot exists, fetching data...');

        // Loop through each user's order in the 'orders' node
        snapshot.children.forEach((userSnapshot) {
          // Access the 'orderdetails' node for each user
          final orderDetailsRef = userSnapshot.child('orderdetails');

          // Loop through each order under 'orderdetails'
          orderDetailsRef.children.forEach((orderSnapshot) {
            final orderData = orderSnapshot.value as Map;

            // Debugging: print raw order data for each order
            print('Raw Order Data: ${orderSnapshot.value}');

            // Create an order object from the fetched data
            loadedOrders.add({
              'orderId': orderSnapshot.key, // Unique order ID
              'name': orderData['name'] ?? 'Unknown',
              'phone': orderData['phone'] ?? 'Unknown',
              'address': orderData['address'] ?? 'Unknown',
              'items': orderData['items'] ?? [],
              'status': orderData['status'] ?? 'Pending',
              'orderDate': orderData['orderDate'] ?? 'Unknown',
            });
          });
        });

        setState(() {
          _orders = loadedOrders;
          _isLoading = false;
          print('Orders loaded: $_orders');
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('No orders found.');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching orders: $error');
    }
  }

  // Update order status in Firebase
  void _updateOrderStatus(String orderId, String status) async {
    final ordersRef = FirebaseDatabase.instance.ref('orders');

    try {
      // Loop through all phone numbers
      final snapshot = await ordersRef.get();
      if (snapshot.exists) {
        snapshot.children.forEach((userSnapshot) {
          // Find the order under the 'orderdetails' node for each phone number
          final orderDetailsRef = userSnapshot.child('phone');

          orderDetailsRef.children.forEach((orderSnapshot) {
            if (orderSnapshot.key == orderId) {
              // Update the status of the order with the given orderId
              orderSnapshot.ref.update({'status': status});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order status updated to $status')),
              );
            }
          });
        });

        // Reload orders after status update
        _fetchOrders();  // This is crucial to reload and show the updated status
      } else {
        print('No orders found.');
      }
    } catch (error) {
      print('Error updating order status: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating order status')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.cyanAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(child: Text('No orders available'))
          : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          print('Order at index $index: $order'); // Debugging line to ensure order is being parsed

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(order['name'] ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone: ${order['phone']}'),
                  Text('Address: ${order['address']}'),
                  Text('Order Date: ${order['orderDate']}'),
                  Text('Status: ${order['status']}'),
                  const SizedBox(height: 8),
                  Text('Items:'),
                  ...((order['items'] as List<dynamic>?)?.map((item) {
                    return Text('${item['name']} x ${item['quantity']}');
                  }).toList() ?? [Text('No items available')]), // Fallback for missing items
                ],
              ),
              trailing: DropdownButton<String>(
                value: order['status'],
                icon: const Icon(Icons.arrow_downward),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _updateOrderStatus(order['orderId'], newValue);
                  }
                },
                items: const <String>['Pending', 'Shipped', 'Received']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
