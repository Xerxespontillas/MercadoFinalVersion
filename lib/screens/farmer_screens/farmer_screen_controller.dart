import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../authentication/user/login_screen.dart';
import '../../widgets/bottom_navigation_bar.dart';

//screens
import '../farmer_screens/farmer_homescreen.dart';
import '../farmer_screens/farmer_new_post.dart';

class FarmerScreenController extends StatefulWidget {
  static const routeName = '/farmer-home';
  const FarmerScreenController({Key? key}) : super(key: key);

  @override
  _FarmerScreenControllerState createState() => _FarmerScreenControllerState();
}

class _FarmerScreenControllerState extends State<FarmerScreenController> {
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      HomePage(),
      NewProductPost(),
      Center(child: Text('Messaging Page')),
      Center(child: Text('Settings Page')),
    ];

    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        onTabTapped: onTabTapped,
        currentIndex: _currentIndex,
      ),
    );
  }
}
