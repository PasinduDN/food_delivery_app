// food_delivery_app/lib/widgets/home_page_content.dart
import 'package:flutter/material.dart';
import 'package:food_delivery_app/screens/food_detail_screen.dart';
import 'package:food_delivery_app/widgets/food_card.dart';
import 'package:food_delivery_data/food_delivery_data.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final FoodRepository _foodRepository = FoodRepository();
  List<FoodItem> _displayedFoods = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;

  // Sample categories (ensure these match your Firestore categories exactly!)
  // Using a full list of example categories.
  final List<String> _categories = [
    'All', 'Pizza', 'Burger', 'Chicken', 'Drinks', 'Desserts',
    'Indian', 'Seafood', 'Curry', 'Fast Food', 'Vegetarian', 'Vegan', 'Appetizers' // Example additions
  ];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _fetchAndApplyFilters();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndApplyFilters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _displayedFoods = [];
    });
    try {
      final List<FoodItem> fetchedFoods = await _foodRepository.getAllFoods(
        category: _selectedCategory != 'All' ? _selectedCategory : null,
      );

      if (_searchController.text.isNotEmpty) {
        _displayedFoods = fetchedFoods.where((food) {
          return food.name.toLowerCase().contains(_searchController.text.toLowerCase());
        }).toList();
      } else {
        _displayedFoods = fetchedFoods;
      }

      setState(() {
        // State update will trigger rebuild
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load foods: ${e.toString().split(':')[1].trim()}';
        print('Error fetching foods: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    _fetchAndApplyFilters();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear(); // Clear search when category changes for cleaner filter
    });
    _fetchAndApplyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Text(
              'Hay!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Let's get your order",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search our delicious foods',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {
                      print('Filter tapped');
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // --- UPDATED: Category Bar using Wrap instead of SizedBox with ListView.builder ---
          Padding( // Added Padding to ensure categories wrap within screen bounds
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust padding as needed
            child: Wrap(
              spacing: 8.0, // Horizontal space between chips
              runSpacing: 8.0, // Vertical space between lines of chips
              children: _categories.map((category) {
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  onSelected: (selected) {
                    if (selected) {
                      _onCategorySelected(category);
                    }
                  },
                  labelStyle: TextStyle(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey[400]!,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 1, // Adds a slight shadow to chips
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20), // Spacing after categories
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Popular Foods',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 220,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _displayedFoods.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.isNotEmpty || _selectedCategory != 'All'
                                  ? 'No matching foods found for your search/category.'
                                  : 'No foods available. Please add some in Firestore with category fields.',
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            itemCount: _displayedFoods.length,
                            itemBuilder: (context, index) {
                              final food = _displayedFoods[index];
                              return FoodCard(
                                foodItem: food,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FoodDetailScreen(foodItem: food),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(15),
                image: const DecorationImage(
                  image: AssetImage('assets/images/discount_bg.png'),
                  fit: BoxFit.cover,
                  opacity: 0.2,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'This summer',
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                        const Text(
                          '10% Discount credit',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/food_plate_small.jpg',
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    const Icon(Icons.card_giftcard, color: Colors.orange, size: 30),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text(
                        '1000 XP to your next treasure',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}