// food_delivery_app/lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:food_delivery_app/widgets/home_page_content.dart';
import 'package:food_delivery_app/screens/cart_screen.dart';
import 'package:food_delivery_data/food_delivery_data.dart'; // Import your shared package for AuthService
import 'package:food_delivery_app/screens/welcome_screen.dart';
import 'package:food_delivery_app/screens/profile_screen.dart'; // NEW: Import ProfileScreen
import 'package:food_delivery_app/screens/order_history_screen.dart'; // NEW: Import OrderHistoryScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService(); // Instantiate AuthService

  // --- UPDATED: Define the list of screens/widgets for your tabs ---
  final List<Widget> _pages = [
    const HomePageContent(), // Index 0: The main food listing page
    const CartScreen(), // Index 1: The shopping cart page
    const OrderHistoryScreen(), // Index 2: The Order History screen (formerly Location placeholder)
    const ProfileScreen(), // Index 3: The User Profile screen (formerly Profile placeholder)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Handle user logout
  Future<void> _logout() async {
    try {
      await _authService.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        } else {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    // TODO: Implement opening a Drawer (side menu)
                    print('Menu tapped');
                  },
                ),
                const SizedBox(width: 10),
                const Text(
                  'Your, Town',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            // Profile icon (now links to the ProfileScreen tab)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  // We now use the bottom navigation to go to profile
                  setState(() {
                    _selectedIndex = 3; // Index for ProfileScreen
                  });
                },
              ),
            ),
            // Logout Button
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'), // NEW: Receipt icon for Orders
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}