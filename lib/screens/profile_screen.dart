// food_delivery_app/lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_data/food_delivery_data.dart';
import 'package:image_picker/image_picker.dart'; // NEW: Import image_picker
import 'dart:io'; // Required for File

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepository = UserRepository();
  final StorageService _storageService = StorageService(); // NEW: Instantiate StorageService
  UserProfile? _userProfile;
  User? _firebaseUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _firebaseUser = FirebaseAuth.instance.currentUser;
    if (_firebaseUser != null) {
      // Listen to profile changes in real-time
      _userRepository.streamUserProfile(_firebaseUser!.uid).listen((profile) {
        if (mounted) {
          setState(() {
            _userProfile = profile;
            _isLoading = false;
          });
        }
      }).onError((error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load profile: ${error.toString().split(':')[1].trim()}';
            _isLoading = false;
          });
        }
      });
    } else {
      _isLoading = false;
    }
  }

  // NEW: Function to pick and upload image
  Future<void> _pickAndUploadImage() async {
    if (_firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to upload a photo.')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70); // Pick from gallery

    if (pickedFile != null) {
      setState(() {
        _isLoading = true; // Show loading indicator during upload
        _errorMessage = null;
      });
      try {
        final String filePath = pickedFile.path;
        final String fileName = '${_firebaseUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg'; // Unique path in storage
        final String downloadUrl = await _storageService.uploadFile(filePath, 'profile_pictures/$fileName');

        // Update user profile in Firestore with the new photo URL
        final updatedProfile = UserProfile(
          uid: _userProfile!.uid,
          email: _userProfile!.email,
          displayName: _userProfile!.displayName,
          photoUrl: downloadUrl, // Save the new URL
        );
        await _userRepository.saveUserProfile(updatedProfile);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_firebaseUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Text(
            'Please log in to view your profile.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center( // Center the profile picture and name
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickAndUploadImage, // Tap to upload image
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[300],
                                // Display network image if available, else a default icon
                                backgroundImage: _userProfile?.photoUrl != null && _userProfile!.photoUrl!.isNotEmpty
                                    ? NetworkImage(_userProfile!.photoUrl!) as ImageProvider<Object>?
                                    : null,
                                child: _userProfile?.photoUrl == null || _userProfile!.photoUrl!.isEmpty
                                    ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[600])
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _userProfile?.displayName ?? _firebaseUser!.email ?? 'Welcome!',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Account Information',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email:',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _firebaseUser!.email ?? 'N/A',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'User ID:',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _firebaseUser!.uid,
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              if (_userProfile?.displayName != null) ...[
                                const SizedBox(height: 15),
                                const Text(
                                  'Full Name:',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _userProfile!.displayName!,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('App Settings'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          print('App Settings tapped');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          print('Help tapped');
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}