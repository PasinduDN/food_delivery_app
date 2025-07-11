// food_delivery_app/lib/screens/auth_check_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/screens/home_screen.dart';
import 'package:food_delivery_app/screens/welcome_screen.dart';

class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a branded loading screen while checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              color: Theme.of(context).primaryColor.withOpacity(0.1), // Light background color from theme
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // *** NEW: Add your app logo here ***
                    Image.asset(
                      'assets/images/hello_food_logo.png', // Ensure this path is correct and asset exists
                      height: 150,
                    ),
                    const SizedBox(height: 30),
                    const CircularProgressIndicator(), // Standard loading spinner
                    const SizedBox(height: 20),
                    Text(
                      'Loading your app...',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in
          return const HomeScreen();
        } else {
          // No user is logged in
          return const WelcomeScreen();
        }
      },
    );
  }
}