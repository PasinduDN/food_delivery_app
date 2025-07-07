import 'package:flutter/material.dart';
// HomePageContent holds the main UI elements of the home screen,
// including dummy_data and food_card.
import 'package:food_delivery_app/widgets/home_page_content.dart';
import 'package:food_delivery_app/screens/cart_screen.dart'; // The CartScreen for the tab

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Keeps track of the currently selected tab index

  // Define the list of screens/widgets that will be displayed
  // when a corresponding BottomNavigationBarItem is tapped.
  // The order here MUST match the order of BottomNavigationBarItems below.
  final List<Widget> _pages = [
    const HomePageContent(), // Index 0: The main food listing page
    const CartScreen(), // Index 1: The shopping cart page
    const Center(
      // Index 2: Placeholder for a Location/Map screen
      child: Text(
        'Location Screen Content (TODO)',
        style: TextStyle(fontSize: 24, color: Colors.grey),
      ),
    ),
    const Center(
      // Index 3: Placeholder for a User Profile screen
      child: Text(
        'Profile Screen Content (TODO)',
        style: TextStyle(fontSize: 24, color: Colors.grey),
      ),
    ),
  ];

  // This function is called when a tab icon in the BottomNavigationBar is tapped.
  void _onItemTapped(int index) {
    setState(() {
      // Update the selected index. This automatically tells IndexedStack
      // to display the corresponding widget from the _pages list.
      _selectedIndex = index;
    });
    // IMPORTANT: We do NOT use Navigator.push here for tab switching.
    // The IndexedStack handles the display change directly.
  }

  // This method intercepts the device's native back button press.
  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      // If not on the Home tab (index 0), switch to the Home tab instead of exiting.
      setState(() {
        _selectedIndex = 0;
      });
      return false; // Prevent the default back button action (don't pop the route)
    }
    // If already on the Home tab, allow the default back button action (exit app or pop HomeScreen).
    // In our current setup, since HomeScreen is the base after login, this will exit the app.
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the Scaffold with WillPopScope to control the native back button.
    return PopScope( // Use PopScope instead of WillPopScope for Flutter 3.16+
      canPop: false, // Prevent default pop behavior initially
      onPopInvoked: (didPop) async { // New callback for PopScope
        if (didPop) {
          return; // If the system already popped, do nothing.
        }
        if (_selectedIndex != 0) {
          // If not on the Home tab (index 0), switch to the Home tab.
          setState(() {
            _selectedIndex = 0;
          });
          // Do not pop the route, as we handled it internally.
        } else {
          // If already on the Home tab, allow the app to exit.
          // This will effectively pop the HomeScreen route.
          // In a real app, you might show an "Are you sure you want to exit?" dialog here.
          if (Navigator.canPop(context)) {
             Navigator.pop(context); // Pop HomeScreen if possible (e.g., if navigated from another screen like a modal)
          } else {
            // This is the true exit case. You might consider SystemNavigator.pop()
            // or a confirmation dialog. For simplicity, just allowing default pop.
            // Returning true from the old WillPopScope implied allowing pop.
            // With PopScope, you'd typically handle exit explicitly if needed.
          }
        }
      },
      child: Scaffold(
        // The AppBar remains consistent across all tabs, which is a common design.
        appBar: AppBar(
          automaticallyImplyLeading: false, // Ensures no default back button from outside
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu), // Hamburger menu icon
                  onPressed: () {
                    // TODO: Implement opening a Drawer (side menu) for app-wide navigation
                    print('Menu tapped');
                  },
                ),
                const SizedBox(width: 10), // Spacing
                const Text(
                  'Your, Town', // Placeholder for user's current town/location
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            // Action buttons on the right side of the AppBar
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.person), // User profile icon
                onPressed: () {
                  // TODO: Navigate to a dedicated user profile screen if desired
                  print('Profile tapped');
                },
              ),
            ),
          ],
          backgroundColor: Colors.transparent, // Makes the AppBar background transparent
          elevation: 0, // Removes the shadow below the AppBar for a flatter look
          flexibleSpace: Container(
            // Provides a custom background decoration for the AppBar area
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1), // Light orange tint
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30), // Rounded corners at the bottom
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
        ),
        // The `body` of the Scaffold now uses `IndexedStack` to manage the tab content.
        body: IndexedStack(
          index: _selectedIndex, // The index of the child to be displayed
          children: _pages, // The list of widgets (screens) for each tab
        ),
        // The BottomNavigationBar handles the tab switching UI.
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            // Each item corresponds to a widget in the _pages list
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Location',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex, // Highlights the currently selected item
          selectedItemColor: Theme.of(context).primaryColor, // Color for selected tab
          unselectedItemColor: Colors.grey, // Color for unselected tabs
          onTap: _onItemTapped, // Links taps to our state update method
        ),
      ),
    );
  }
}