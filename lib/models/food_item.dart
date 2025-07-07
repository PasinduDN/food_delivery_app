class FoodItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double rating;
  final int reviews;
  final String description; // For detail screen

  FoodItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.rating = 0.0, // Default value
    this.reviews = 0,   // Default value
    this.description = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
  });
}