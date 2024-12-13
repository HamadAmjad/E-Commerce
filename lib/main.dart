import 'package:ecommercestore/AdminDashboardPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'HomePage.dart';
import 'LogInPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase once
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce Store',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in, show HomePage if logged in, else show LoginPage
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading spinner while waiting for Firebase to return the user state
        } else if (snapshot.hasData) {
          // Check if the logged-in user is the admin
          final user = snapshot.data!;
          if (user.email == 'admin@gmail.com') {
            return AdminDashboard(); // Show Admin Dashboard for the admin user
          } else {
            return HomePage(); // Show HomePage for normal users
          }
        } else {
          return const LoginPage(); // Otherwise, show LoginPage
        }
      },
    );
  }
}
