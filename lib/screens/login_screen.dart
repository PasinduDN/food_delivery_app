import 'package:flutter/material.dart';
import 'package:food_delivery_app/screens/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Allows scrolling if content overflows
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
            children: [
              const SizedBox(height: 60), // Top spacing
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous screen
                  },
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Image.asset(
                  'assets/images/hello_food_logo.png', // We'll add this logo
                  height: 80,
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                'Login to your account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              // Phone Number Input
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone),
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              // Password Input
              TextField(
                obscureText: true, // Hides input for password
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  suffixIcon: const Icon(Icons.visibility_off), // Eye icon
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    print('Forgot password?');
                    // TODO: Navigate to Forgot Password screen
                  },
                  child: const Text(
                    'Forgot your password?',
                    style: TextStyle(color: Colors.orange, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Sign In Button
              SizedBox(
                width: double.infinity, // Make button fill width
                child: ElevatedButton(
                  onPressed: () {
                    print('Sign In button pressed!');
                    // TODO: Implement actual login logic
                    // For now, let's navigate to the Home Screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink, // From UI
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text(
                    'SIGN IN',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(child: Text('Or')),
              const SizedBox(height: 20),
              // Social Media Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialButton(Icons.facebook, Colors.blue[700]!),
                  _buildSocialButton(Icons.g_mobiledata, Colors.red[700]!), // Using a generic G icon
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      print('Sign Up from login');
                      // TODO: Navigate to Sign Up screen
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

  // Helper method to build social media buttons
  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 40),
        onPressed: () {
          print('Social button pressed!');
        },
      ),
    );
  }
}