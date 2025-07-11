import 'package:flutter/foundation.dart'; // For ChangeNotifier
// import 'package:food_delivery_app/models/food_item.dart';
import 'package:food_delivery_data/food_delivery_data.dart';

// Represents an item added to the cart
class CartItem {
  final FoodItem foodItem;
  int quantity;

  CartItem({required this.foodItem, this.quantity = 1});

  // Calculate total price for this cart item
  double get totalPrice => foodItem.price * quantity;
}

// This class manages the state of our shopping cart
class CartProvider with ChangeNotifier {
  final List<CartItem> _items = []; // Internal list of cart items

  // Getter to expose a copy of cart items (prevent external modification)
  List<CartItem> get items => [..._items];

  // Get total number of unique items in cart
  int get itemCount => _items.length;

  // Get the total number of all items (quantity considered)
  int get totalItemsCount {
    int count = 0;
    for (var item in _items) {
      count += item.quantity;
    }
    return count;
  }

  // Get the total price of all items in the cart
  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  // Add item to cart or increase quantity if it exists
  void addItem(FoodItem foodItem, int quantity) {
    final existingItemIndex = _items.indexWhere((item) => item.foodItem.id == foodItem.id);

    if (existingItemIndex >= 0) {
      // Item already in cart, just update quantity
      _items[existingItemIndex].quantity += quantity;
    } else {
      // New item, add it to the list
      _items.add(CartItem(foodItem: foodItem, quantity: quantity));
    }
    notifyListeners(); // Tell widgets listening to this provider to rebuild
  }

  // Remove an item entirely from the cart
  void removeItem(String foodItemId) {
    _items.removeWhere((item) => item.foodItem.id == foodItemId);
    notifyListeners();
  }

  // Increase quantity of a specific item
  void increaseQuantity(String foodItemId) {
    final existingItemIndex = _items.indexWhere((item) => item.foodItem.id == foodItemId);
    if (existingItemIndex >= 0) {
      _items[existingItemIndex].quantity++;
      notifyListeners();
    }
  }

  // Decrease quantity of a specific item
  void decreaseQuantity(String foodItemId) {
    final existingItemIndex = _items.indexWhere((item) => item.foodItem.id == foodItemId);
    if (existingItemIndex >= 0) {
      if (_items[existingItemIndex].quantity > 1) {
        _items[existingItemIndex].quantity--;
      } else {
        // If quantity goes to 0, remove the item
        _items.removeAt(existingItemIndex);
      }
      notifyListeners();
    }
  }

  // Clear the entire cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}