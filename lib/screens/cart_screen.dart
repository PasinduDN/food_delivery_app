import 'package:flutter/material.dart';
import 'package:food_delivery_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';
// These two imports are crucial for order placement
import 'package:food_delivery_data/food_delivery_data.dart'; // Import your shared package for Order and OrderRepository
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth to get the current user ID

class CartScreen extends StatelessWidget {
  // New property: true if this screen was pushed onto the navigation stack
  // False (by default) if it's displayed as a tab within an IndexedStack.
  final bool isPushedRoute;

  const CartScreen({super.key, this.isPushedRoute = false}); // Default value is false

  // --- NEW METHOD: Handles the process of placing an order ---
  Future<void> _placeOrder(BuildContext context) async {
    // Get access to the CartProvider to read cart contents
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    // Get the currently logged-in user from Firebase Authentication
    final currentUser = FirebaseAuth.instance.currentUser;

    // --- Basic Validations ---
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to place an order.')),
      );
      return; // Stop if no user is logged in
    }

    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty! Add items first.')),
      );
      return; // Stop if cart is empty
    }

    // Show a loading/processing message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Placing order...'), duration: Duration(seconds: 2)),
    );

    try {
      // 1. Prepare OrderItem objects from CartItem objects
      // We convert CartItem to OrderItem (which only contains necessary order details)
      final List<OrderItem> orderItems = cartProvider.items.map((cartItem) {
        return OrderItem(
          foodItem: cartItem.foodItem, // Use the FoodItem from the cart
          quantity: cartItem.quantity,
          itemTotalPrice: cartItem.totalPrice, // Capture the price at time of order
        );
      }).toList();

      // 2. Create the main Order object
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate a simple unique ID for the order
        userId: currentUser.uid, // Link the order to the current user's ID
        items: orderItems,
        subtotal: cartProvider.totalAmount, // Get subtotal from CartProvider
        deliveryFee: 5.00, // Hardcoded delivery fee (you can make this dynamic later)
        totalAmount: cartProvider.totalAmount + 5.00, // Calculate total amount
        orderDate: DateTime.now(), // Set current date/time
        status: 'pending', // Initial status of the order
      );

      // 3. Use OrderRepository to save the order to Firestore
      final orderRepository = OrderRepository(); // Instantiate your OrderRepository
      await orderRepository.placeOrder(order); // Call the placeOrder method

      // 4. On success: Clear the cart and show a success message
      cartProvider.clearCart(); // Clear all items from the cart
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order Placed Successfully!'), backgroundColor: Colors.green),
      );

      // 5. Navigate back or to an order confirmation screen
      if (isPushedRoute) {
        Navigator.pop(context); // If cart screen was pushed (from checkout), pop it
      }
      // If it's a tab, the user can manually switch back to the home tab or an order history tab.
      // You could also add Navigator.of(context).popUntil((route) => route.isFirst);
      // to go back to the very first screen (e.g., after successful order completion).
    } catch (e) {
      // If any error occurs during the order placement process, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consumer widget rebuilds its child whenever the CartProvider notifies a change.
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Item Carts', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.transparent, // Transparent background
            elevation: 0, // No shadow
            // Conditional leading button logic: shows back button only if pushed as a route.
            leading: isPushedRoute
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context); // Correctly pops this pushed route
                    },
                  )
                : null, // If it's a tab, no back button
          ),
          body: cart.items.isEmpty // Check if the cart is empty
              ? const Center(
                  child: Text(
                    'Your cart is empty!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : Column( // If cart is not empty, display its contents
                  children: [
                    Expanded(
                      // ListView.builder efficiently displays a scrollable list of cart items
                      child: ListView.builder(
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final cartItem = cart.items[index];
                          return Card( // Each cart item is displayed in a Card
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row( // Row to arrange image, text details, and quantity/delete buttons
                                children: [
                                  ClipRRect( // ClipRRect for rounded corners on image
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      cartItem.foodItem.imageUrl, // Display food item image
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 15), // Spacing
                                  Expanded( // Expanded to allow text to take available space
                                    child: Column( // Column for food name, price, total
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cartItem.foodItem.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          '\$${cartItem.foodItem.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 14),
                                        ),
                                        Text(
                                          'Total: \$${cartItem.totalPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row( // Row for quantity adjustment buttons and current quantity
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: () {
                                          cart.decreaseQuantity(cartItem.foodItem.id);
                                        },
                                      ),
                                      Text('${cartItem.quantity}'),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () {
                                          cart.increaseQuantity(cartItem.foodItem.id);
                                        },
                                      ),
                                    ],
                                  ),
                                  IconButton( // Delete item button
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      cart.removeItem(cartItem.foodItem.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding( // Padding for the summary and "Proceed to Payment" button
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row( // Subtotal row
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                              Text(
                                '\$${cart.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10), // Spacing
                          Row( // Delivery Fee row
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Delivery Fee:', style: TextStyle(fontSize: 16)),
                              Text(
                                '\$5.00', // Example fixed delivery fee
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(), // Separator line
                          Row( // Total row
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${(cart.totalAmount + 5.00).toStringAsFixed(2)}', // Calculate total
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20), // Spacing
                          ElevatedButton(
                            onPressed: () => _placeOrder(context), // Call the new _placeOrder method
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor, // Orange button
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Proceed to Payment',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            );
          },
        );
      }
    }