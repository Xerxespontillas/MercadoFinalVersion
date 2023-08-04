import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const routeName = '/splash-screen';

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  // User type variables
  bool isCustomer = false;
  bool isFarmer = false;
  bool isOrganization = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Animation has completed, navigate to the appropriate screen based on user type
        navigateToUserScreen();
      }
    });
  }

  void navigateToUserScreen() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Retrieve additional user data from Firestore or other sources
      // For example, you can retrieve the user's role from Firestore

      String role = '';

      // Example: Retrieving user role from respective collections
      DocumentSnapshot customerData = await FirebaseFirestore.instance
          .collection('customers')
          .doc(currentUser.uid)
          .get();
      if (customerData.exists) {
        role = 'Customer';
      } else {
        DocumentSnapshot farmerData = await FirebaseFirestore.instance
            .collection('farmers')
            .doc(currentUser.uid)
            .get();
        if (farmerData.exists) {
          role = 'Farmer';
        } else {
          DocumentSnapshot organizationData = await FirebaseFirestore.instance
              .collection('organizations')
              .doc(currentUser.uid)
              .get();
          if (organizationData.exists) {
            role = 'Organization';
          }
        }
      }

      if (role == 'Customer') {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/home-page');
      } else if (role == 'Farmer') {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/farmer-home');
      } else if (role == 'Organization') {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/org-home');
      } else {
        // Handle the case when no user type is found
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/login-user');
      }
    } else {
      // No authenticated user found, navigate to the login screen
      Navigator.pushReplacementNamed(context, '/login-user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: FadeTransition(
                  opacity: _animation,
                  child: Image.asset(
                    'assets/images/merkado_logo.png',
                    width: 180,
                    height: 180,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: FadeTransition(
                  opacity: _animation,
                  child: const Text(
                    'MERCADO',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
