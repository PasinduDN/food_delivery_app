// food_delivery_app/lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:food_delivery_app/screens/home_screen.dart'; // Ensure this import is correct
import 'package:food_delivery_app/screens/welcome_screen.dart'; // To navigate back to Welcome
// *** NEW: Import your shared package to use AuthService ***
import 'package:food_delivery_data/food_delivery_data.dart'; // Import your shared package
import 'package:food_delivery_app/screens/signup_screen.dart';

// Change from StatelessWidget to StatefulWidget to manage text input controllers and authentication state
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers to get text from the input fields for email and password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instantiate your AuthService from the shared package.
  // This service will handle all communication with Firebase Authentication.
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    // It's crucial to dispose of TextEditingControllers when the widget is removed
    // to prevent memory leaks.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- NEW METHOD: Handles the sign-in process with Firebase ---
  Future<void> _signIn() async {
    // Show a loading indicator (optional, but good UX)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signing in...'), duration: Duration(seconds: 1)),
    );

    try {
      // Call the signInWithEmailAndPassword method from your AuthService
      // This will attempt to authenticate the user with Firebase.
      await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(), // Get email from text field, trim whitespace
        _passwordController.text.trim(), // Get password from text field, trim whitespace
      );

      // If authentication is successful, navigate to the HomeScreen.
      // Navigator.pushReplacement removes the current route (LoginScreen) from the stack,
      // so the user cannot go back to the login screen using the back button.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      // If sign-in fails (e.g., wrong password, user not found), display an error message
      // to the user using a SnackBar.
      // The .split(':')[1].trim() is a basic way to get just the error message part from Firebase exceptions.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: ${e.toString().split(':')[1].trim()}')),
      );
    }
  }

  // --- NEW METHOD: Handles the sign-up process with Firebase (Placeholder) ---
  // You would implement the UI for this separately, but this function shows how to call AuthService.
  Future<void> _signUp() async {
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signing up...'), duration: Duration(seconds: 1)),
    );
    try {
      await _authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign Up Successful! Please log in.')),
      );
      // After successful signup, you might want to automatically sign them in
      // or redirect them to the login screen.
      _signIn(); // Optionally sign them in immediately
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign Up Failed: ${e.toString().split(':')[1].trim()}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Allows the content to scroll if it overflows (useful for smaller screens or keyboard pop-ups)
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Padding around the entire content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the left
            children: [
              const SizedBox(height: 60), // Top spacing
              Align(
                alignment: Alignment.centerLeft, // Aligns IconButton to the left
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios), // Back arrow icon
                  onPressed: () {
                    // Navigate back to the WelcomeScreen by popping the current route.
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 30), // Spacing
              Center(
                // Centers the image horizontally
                child: Image.asset(
                  'assets/images/hello_food_logo.png', // The app's logo image
                  // Note: Your dummy_data.dart used 'masala_curry.jpg' for login_screen.dart,
                  // but 'hello_food_logo.png' is more appropriate for a login page logo.
                  // Ensure this asset exists and is listed in pubspec.yaml.
                  height: 80,
                ),
              ),
              const SizedBox(height: 50), // Spacing
              const Text(
                'Login to your account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30), // Spacing
              // Email Input Field
              TextField(
                controller: _emailController, // Link this TextField to the _emailController
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email), // Email icon (changed from phone)
                  labelText: 'Email', // Label text for the input field (changed from phone number)
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners for the border
                  ),
                  filled: true, // Fills the background of the input field
                  fillColor: Colors.grey[200], // Light grey background color
                ),
                keyboardType: TextInputType.emailAddress, // Optimizes keyboard for email input
              ),
              const SizedBox(height: 20), // Spacing
              // Password Input Field
              TextField(
                controller: _passwordController, // Link this TextField to the _passwordController
                obscureText: true, // Hides the entered text (for passwords)
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock), // Lock icon
                  labelText: 'Password', // Label text
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  suffixIcon: const Icon(Icons.visibility_off), // Eye icon to toggle visibility
                ),
              ),
              const SizedBox(height: 10), // Spacing
              Align(
                alignment: Alignment.centerRight, // Aligns TextButton to the right
                child: TextButton(
                  onPressed: () {
                    print('Forgot password?');
                    // TODO: Navigate to a Forgot Password screen if implemented
                  },
                  child: const Text(
                    'Forgot your password?',
                    style: TextStyle(color: Colors.orange, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 30), // Spacing
              // Sign In Button
              SizedBox(
                width: double.infinity, // Makes the button take full width
                child: ElevatedButton(
                  onPressed: _signIn, // Call the _signIn method when button is pressed
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink, // Button background color
                    padding: const EdgeInsets.symmetric(vertical: 18), // Vertical padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                    ),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text(
                    'SIGN IN',
                    style: TextStyle(color: Colors.white), // White text color
                  ),
                ),
              ),
              const SizedBox(height: 20), // Spacing
              const Center(child: Text('Or')), // "Or" separator text
              const SizedBox(height: 20), // Spacing
              // Social Media Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distributes buttons evenly
                children: [
                  _buildSocialButton(Icons.facebook, Colors.blue[700]!), // Facebook button
                  _buildSocialButton(Icons.g_mobiledata, Colors.red[700]!), // Google button
                ],
              ),
              const SizedBox(height: 40), // Spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Centers the text and button
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                      print('Sign Up from login');
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
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

  // Helper method to build reusable social media buttons (circular containers with icons)
  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Circular shape
        border: Border.all(color: Colors.grey[300]!), // Light grey border
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 40), // Icon inside the button
        onPressed: () {
          print('Social button pressed!');
        },
      ),
    );
  }
}