import 'package:flutter/material.dart';
// import 'package:food_delivery_app/models/food_item.dart';
import 'package:food_delivery_data/food_delivery_data.dart'; // Import from your shared package

class FoodCard extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback onTap; // Function to call when card is tapped

  const FoodCard({
    super.key,
    required this.foodItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Call the provided onTap function
      child: Card(
        margin: const EdgeInsets.only(right: 15.0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: 150, // Fixed width for the card
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    foodItem.imageUrl,
                    height: 90,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                foodItem.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // Add ellipsis if text is too long
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  Text(
                    '${foodItem.rating} (${foodItem.reviews})',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                '\$${foodItem.price.toStringAsFixed(2)}', // Format price to 2 decimal places
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}