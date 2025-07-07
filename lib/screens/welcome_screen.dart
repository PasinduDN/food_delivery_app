import 'package:flutter/material.dart';
import 'package:food_delivery_app/screens/login_screen.dart';

// This screen will be the first thing users see.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold provides the basic visual structure for a Material Design app.
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Vertically center content
            crossAxisAlignment: CrossAxisAlignment.center, // Horizontally center content
            children: [
              // Placeholder for your image (the delivery guy)
              Image.asset(
                'assets/images/roasted_chicken.jpg', // We'll add this image later
                height: 250,
              ),
              const SizedBox(height: 40), // Space between image and title
              const Text(
                'Zomagok', // Your app name (from UI)
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10), // Space between title and subtitle
              const Text(
                'Food For All', // Your app slogan (from UI)
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20), // Space between slogan and description
              const Text(
                'Fast delivery with no stops that will enjoy with your family and friends.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 60), // Space before buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space buttons evenly
                children: [
                  // "I'm new here - Sign Up" Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Navigate to Sign Up screen
                        print('Sign Up pressed!');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange), // Border color
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                        ),
                      ),
                      child: const Text(
                        "I'm new here",
                        style: TextStyle(fontSize: 16, color: Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Space between buttons
                  // "Sign In" Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to Sign In screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, // Background color
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                        ),
                      ),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}