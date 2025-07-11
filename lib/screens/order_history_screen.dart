// food_delivery_app/lib/screens/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get current user ID
import 'package:food_delivery_data/food_delivery_data.dart'; // For Order and OrderRepository
import 'package:food_delivery_app/screens/order_detail_screen.dart'; // Import OrderDetailScreen

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderRepository _orderRepository = OrderRepository(); // Instantiate OrderRepository
  Stream<List<Order>>? _ordersStream; // Changed from Future to Stream
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // Get current user on init
    if (_currentUser != null) {
      _ordersStream = _orderRepository.getUserOrders(_currentUser!.uid); // Get the Stream of orders
    } else {
      // If no user, ensure stream is handled gracefully by StreamBuilder (null stream)
      _ordersStream = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order History', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // As this is a tab screen
        ),
        body: const Center(
          child: Text(
            'Please log in to view your order history.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // As this is a tab screen
      ),
      body: StreamBuilder<List<Order>>(
        stream: _ordersStream, // Pass the Stream here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading indicator
          } else if (snapshot.hasError) {
            // Updated error message display
            return Center(child: Text('Error loading orders: ${snapshot.error.toString().split(':')[1].trim()}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No orders placed yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          } else {
            final orders = snapshot.data!; // Get the list of orders from the snapshot
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return GestureDetector( // Make the card tappable
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(order: order), // Navigate to detail screen
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order ID: ${order.id.substring(0, 8)}...', // Show a truncated ID
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Status: ${order.status.toUpperCase()}', style: TextStyle(color: order.status == 'pending' ? Colors.orange : Colors.green, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          // This section should be correct with the spread operator '...'
                          ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                children: [
                                  Text('${item.quantity}x ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Expanded(child: Text(item.foodItem.name)),
                                  Text('\$${item.itemTotalPrice.toStringAsFixed(2)}'),
                                ],
                              ),
                            )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('\$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}