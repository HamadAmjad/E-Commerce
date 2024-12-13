import 'package:ecommercestore/AboutUsPage.dart';
import 'package:ecommercestore/AddToCartPage.dart';
import 'package:ecommercestore/FavouritePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  // Method to fetch the current user's email
  Future<String?> _getCurrentUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email;
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250, // 70% of screen width,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Menu', style: TextStyle(color: Colors.black, fontSize: 24,fontWeight: FontWeight.w300)),
                SizedBox(height: 8.0),
                FutureBuilder<String?>(
                  future: _getCurrentUserEmail(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...', style: TextStyle(color: Colors.black, fontSize: 16));
                    } else if (snapshot.hasError) {
                      return Text('Error loading email', style: TextStyle(color: Colors.red, fontSize: 16));
                    } else if (snapshot.hasData) {
                      return Text(
                        snapshot.data ?? 'Guest',
                        style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
                      );
                    } else {
                      return Text('Guest', style: TextStyle(color: Colors.black, fontSize: 16));
                    }
                  },
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.cyanAccent,
            ),
          ),


          ListTile(
            leading: Icon(Icons.shopping_cart,color: Colors.black,),
            title: Text('Cart',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddToCartPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.star_outlined,color: Colors.black,),
            title: Text('Favorites',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline,color: Colors.black,),
            title: Text('About Us',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsPage()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.logout,color: Colors.red,),
            title: Text('Logout',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              // Optionally navigate to login or home page after logout
              Navigator.pushReplacementNamed(context, '/login'); // or home page route
            },
          ),
        ],
      ),
    );
  }
}
