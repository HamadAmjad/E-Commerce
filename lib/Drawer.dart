import 'package:ecommercestore/AboutUsPage.dart';
import 'package:ecommercestore/AddToCartPage.dart';
import 'package:ecommercestore/FavouritePage.dart';
import 'package:ecommercestore/LogInPage.dart';
import 'package:ecommercestore/UserOrderPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  // Method to get the current user
  User? _getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final user = _getCurrentUser();
    final bool isLoggedIn = user != null;

    return Drawer(
      width: 250, // 70% of screen width
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.cyanAccent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Menu',
                  style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w300),
                ),
                SizedBox(height: 8.0),
                Text(
                  isLoggedIn ? user.email ?? 'Unknown User' : 'Guest',
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          ListTile(
            leading: Icon(Icons.shopping_cart, color: Colors.black),
            title: Text('Cart', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddToCartPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.receipt_long_outlined, color: Colors.black),
            title: Text('My Orders', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserOrdersPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.star_outlined, color: Colors.black),
            title: Text('Favorites', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FavoritesPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: Colors.black),
            title: Text('About Us', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsPage()));
            },
          ),

          Divider(), // Adds a line separator before login/logout

          ListTile(
            leading: Icon(isLoggedIn ? Icons.logout : Icons.login, color: isLoggedIn ? Colors.red : Colors.green),
            title: Text(
              isLoggedIn ? 'Logout' : 'Login',
              style: TextStyle(color: isLoggedIn ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              if (isLoggedIn) {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login'); // Redirect to login page after logout
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                ); // Navigate to login page
              }
            },
          ),
        ],
      ),
    );
  }
}
