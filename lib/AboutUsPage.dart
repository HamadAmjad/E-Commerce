import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.cyanAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Welcome to Our E-Commerce Store!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'At Our E-Commerce Store, we are committed to providing our customers with the best shopping experience. We offer a wide variety of high-quality products across various categories, from electronics to clothing, all available at competitive prices.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Our Mission:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our mission is to make shopping easy, affordable, and enjoyable for everyone. We believe in providing top-notch customer service and ensuring that every order is processed with care and precision.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Why Choose Us?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'We prioritize customer satisfaction, fast shipping, and hassle-free returns. Our store features secure payment options, an easy-to-navigate interface, and constant updates with new products.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Follow Us:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook),
                  onPressed: () {
                    // Link to Facebook
                    // For example: Navigator.pushNamed(context, 'https://www.facebook.com/yourpage');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.facebook),
                  onPressed: () {
                    // Link to Twitter
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.facebook),
                  onPressed: () {
                    // Link to Instagram
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.facebook),
                  onPressed: () {
                    // Link to LinkedIn
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Contact Us:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you have any questions or need assistance, feel free to reach out to us via email at support@ecommercestore.com.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              '© 2024 Our E-Commerce Store. All rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
