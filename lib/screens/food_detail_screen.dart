import 'package:flutter/material.dart';
import 'package:food_delivery_app/models/food_item.dart';
import 'package:food_delivery_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/screens/cart_screen.dart'; // Ensure this import is here

class FoodDetailScreen extends StatefulWidget {
  final FoodItem foodItem;

  const FoodDetailScreen({super.key, required this.foodItem});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1; // Default quantity

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the CartProvider without listening for rebuilds unless needed by this widget's direct UI.
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent background for a sleek look
        elevation: 0, // Removes the shadow under the app bar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black), // Back arrow icon
          onPressed: () {
            Navigator.pop(context); // Pops this FoodDetailScreen off the navigation stack
          },
        ),
        actions: [
          // Favorite button
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.red),
            onPressed: () {
              print('Favorite tapped!');
            },
          ),
          // Displays the food item's price
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '\$${widget.foodItem.price.toStringAsFixed(2)}', // Formats price to two decimal places
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Allows the content to scroll if it exceeds screen height
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start (left)
          children: [
            Center(
              child: Hero(
                // Hero animation for a smooth transition of the image between screens
                tag: widget.foodItem.id, // Unique tag for the Hero animation
                child: Image.asset(
                  widget.foodItem.imageUrl, // Displays the food item image
                  height: 250,
                  fit: BoxFit.contain, // Ensures the image fits within its bounds
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.foodItem.name, // Displays the food item name
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10), // Spacing
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20), // Star icon for rating
                      Text(
                        '${widget.foodItem.rating} (${widget.foodItem.reviews} reviews)', // Displays rating and reviews
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Spacer(), // Pushes the next widget to the right
                      // Quantity controls (decrement, display, increment)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 20),
                              onPressed: _decrementQuantity, // Decreases quantity
                            ),
                            Text(
                              '$_quantity', // Displays current quantity
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              onPressed: _incrementQuantity, // Increases quantity
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30), // Spacing
                  const Text(
                    'Details:', // Section title
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10), // Spacing
                  Text(
                    widget.foodItem.description, // Displays food item description
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5, // Line height
                    ),
                    textAlign: TextAlign.justify, // Justifies text alignment
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30), // Bottom spacing
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0), // Padding around the bottom navigation buttons
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  cartProvider.addItem(widget.foodItem, _quantity); // Adds item to cart
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${_quantity}x ${widget.foodItem.name} added to cart!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor, // Button background color
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                child: const Text(
                  'Add to cart',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 15), // Spacing between buttons
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  cartProvider.addItem(widget.foodItem, _quantity); // Add to cart first
                  // *** CRITICAL FIX HERE ***
                  // Navigate to CartScreen and explicitly tell it that it was 'pushed'
                  // by passing isPushedRoute: true. This ensures the back button appears.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(isPushedRoute: true),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300], // Light grey background
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Check out',
                  style: TextStyle(color: Colors.black87, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}