import 'package:flutter/material.dart';
import 'package:food_delivery_app/screens/welcome_screen.dart';
import 'package:food_delivery_app/providers/cart_provider.dart'; // New import
import 'package:provider/provider.dart'; // New import

void main() {
  // Provide CartProvider to the whole app
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(), // Create an instance of our CartProvider
      child: const FoodDeliveryApp(), // Our main app
    ),
  );
}

class FoodDeliveryApp extends StatelessWidget {
  const FoodDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme( // Define app bar theme globally
          iconTheme: IconThemeData(color: Colors.black), // Black icons by default
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}