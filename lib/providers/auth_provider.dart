// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String message = '';

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    // Check if the user is already authenticated when the app starts up
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _isAuthenticated = user != null;
      notifyListeners();
    });
  }

  Future<void> register({
    required GlobalKey<FormState> formKey,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController fullNameController,
    required TextEditingController addressController,
    required TextEditingController phoneNumberController,
    required TextEditingController roleController,
    required TextEditingController orgController,
  }) async {
    try {
      // Validate the form inputs
      if (!formKey.currentState!.validate()) {
        return;
      }

      // Perform the registration
      final String email = emailController.text.trim();
      final String password = passwordController.text;
      final String fullName = fullNameController.text;
      final String address = addressController.text;
      final String phoneNumber = phoneNumberController.text;
      final String role = roleController.text;

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Registration successful
      User? user = userCredential.user;
      if (user != null) {
        // Additional user data can be saved to Firestore
        Map<String, dynamic> userData = {
          'email': email,
          'displayName': fullName,
          'address': address,
          'phoneNumber': phoneNumber,
          'role': role,
        };
        String collectionName = '';

        if (role == 'Customer') {
          collectionName = 'customers';
        } else if (role == 'Farmer') {
          collectionName = 'farmers';
        } else if (role == 'Organization') {
          collectionName = 'organizations';
          userData['organizationName'] = orgController.text;
        }

        await _firestore.collection(collectionName).doc(user.uid).set({
          ...userData,
          if (role == 'Customer') 'isCustomer': true,
          if (role == 'Farmer') 'isFarmer': true,
          if (role == 'Organization') 'isOrganization': true,
        });

        // Show a success message or navigate to the next screen
      }
    } catch (e) {
      // Registration failed
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> login({
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required BuildContext context,
  }) async {
    try {
      String email = emailController.text.trim();
      String password = passwordController.text;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        String collectionName = '';

        // Determine the user's role type
        DocumentSnapshot userData =
            await _firestore.collection('customers').doc(user.uid).get();
        if (userData.exists) {
          collectionName = 'customers';
        } else {
          userData = await _firestore.collection('farmers').doc(user.uid).get();
          if (userData.exists) {
            collectionName = 'farmers';
          } else {
            userData = await _firestore
                .collection('organizations')
                .doc(user.uid)
                .get();
            if (userData.exists) {
              collectionName = 'organizations';
            }
          }
        }

        if (collectionName.isNotEmpty) {
          // Navigate to the appropriate screen based on the user's role type
          if (collectionName == 'customers') {
            // Navigate to the customer screen
            // ignore: use_build_context_synchronously
            Navigator.pushReplacementNamed(context, '/home_page',
                arguments: userData);
          } else if (collectionName == 'farmers') {
            // Navigate to the farmer screen
            // ignore: use_build_context_synchronously
            Navigator.pushReplacementNamed(context, '/farmer_home',
                arguments: userData);
          } else if (collectionName == 'organizations') {
            // Navigate to the organization screen
            // ignore: use_build_context_synchronously
            Navigator.pushReplacementNamed(context, '/org_home',
                arguments: userData);
          } else {
            // Handle the case when no role type is found
            print('No valid role type found for the user.');
          }
        } else {
          // Handle the case when no user data is found
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Login Error'),
                content: const Text('Incorrect email or password.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      // Handle login errors
      print('Login failed: $e');
      // Show dialog for login failure
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Error'),
            content: const Text(
              'Invalid email or password.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
