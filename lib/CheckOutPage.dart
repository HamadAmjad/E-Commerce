import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  const CheckoutPage({super.key, required this.cartItems});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();

  bool _isProcessingOrder = false;
  User? _currentUser;
  double _totalPrice = 0.0;
  double _discountPercentage = 0.0;
  double _finalPrice = 0.0;
  String _couponMessage = '';

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    _calculateTotal();
  }

  void _getUserDetails() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
        _nameController.text = user.displayName ?? '';
        _phoneController.text = user.phoneNumber ?? '';
      });
    }
  }

  void _calculateTotal() {
    double total = 0.0;
    for (var item in widget.cartItems) {
      total += (item['price'] ?? 0) * (item['quantity'] ?? 1);
    }
    setState(() {
      _totalPrice = total;
      _finalPrice = total; // Set initial final price
    });
  }


  void _placeOrder() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not logged in!')),
      );
      return;
    }

    setState(() {
      _isProcessingOrder = true;
    });

    final databaseRef = FirebaseDatabase.instance.ref('orders');
    final userId = _currentUser!.uid;
    final String? orderId = databaseRef.child(userId).push().key;

    if (orderId == null) {
      setState(() {
        _isProcessingOrder = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate order ID')),
      );
      return;
    }

    final orderDetails = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'email': _currentUser!.email ?? 'No Email',
      'address': _addressController.text,
      'items': widget.cartItems,
      'orderDate': DateTime.now().toIso8601String(),
      'totalPrice': _totalPrice,
      'discount': _discountPercentage,
      'finalPrice': _finalPrice,
      'couponCode': _couponController.text.trim(),
    };

    try {
      await databaseRef.child(userId).child(orderId).set(orderDetails);
      await FirebaseDatabase.instance.ref('carts').child(userId).remove();

      setState(() {
        _isProcessingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
      Navigator.pop(context);
    } catch (error) {
      setState(() {
        _isProcessingOrder = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $error')),
      );
    }
  }
  Future<void> applyCoupon(String couponCode) async {
    if (couponCode.isEmpty) {
      setState(() {
        _couponMessage = "Please enter a coupon code!";
      });
      return;
    }

    DatabaseReference couponRef = FirebaseDatabase.instance.ref("coupons");
    final snapshot = await couponRef.orderByChild("name").equalTo(couponCode).get();

    if (snapshot.exists && snapshot.value is Map<dynamic, dynamic>) {
      Map<dynamic, dynamic> couponData = snapshot.value as Map<dynamic, dynamic>;
      var firstCoupon = couponData.values.first;

      double discount = (firstCoupon['discount'] ?? 0).toDouble();

      if (discount > 0) {
        setState(() {
          _discountPercentage = discount;
          _finalPrice = _totalPrice - (_totalPrice * (_discountPercentage / 100));
          _couponMessage = "Coupon Applied! $_discountPercentage% discount applied.";
        });
      } else {
        setState(() {
          _couponMessage = "Invalid discount value.";
        });
      }
    } else {
      setState(() {
        _couponMessage = "Invalid Coupon Code!";
      });
    }
  }

  Future<void> _showCouponDialog() async {
    TextEditingController couponController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Coupon Code"),
        content: TextField(
          controller: couponController,
          decoration: const InputDecoration(
            labelText: "Coupon Code",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String enteredCoupon = couponController.text.trim();
              Navigator.pop(context);
              await applyCoupon(enteredCoupon);
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.cyanAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Shipping Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...widget.cartItems.map((item) {
                return ListTile(
                  leading: item['imageUrl'].isNotEmpty
                      ? Image.network(
                    item['imageUrl'],
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
                  )
                      : const Icon(Icons.broken_image),
                  title: Text(item['name'] ?? 'Unknown'),
                  subtitle: Text('Price: \$${item['price']} x ${item['quantity']}'),
                );
              }).toList(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _showCouponDialog,
                child: const Text("Apply Coupon"),
              ),
              const SizedBox(height: 20),
              Text("Total Price: \$${_totalPrice.toStringAsFixed(2)}"),
              Text("Discount: $_discountPercentage%"),
              Text("Final Price: \$${_finalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              const SizedBox(height: 32),
              _isProcessingOrder
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Place Order (Cash on Delivery)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

