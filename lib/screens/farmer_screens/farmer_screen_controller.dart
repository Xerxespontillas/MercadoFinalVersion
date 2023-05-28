import 'package:flutter/material.dart';

import 'farmer_drawer_screens/farmer_my_products.dart';
import 'farmer_chat_list.dart';

import '../../widgets/bottom_navigation_bar.dart';

//screens
import '../farmer_screens/farmer_homescreen.dart';
import 'farmer_settings_screen.dart';

class FarmerScreenController extends StatefulWidget {
  static const routeName = '/farmer-home';
  const FarmerScreenController({Key? key}) : super(key: key);

  @override
  FarmerScreenControllerState createState() => FarmerScreenControllerState();
}

class FarmerScreenControllerState extends State<FarmerScreenController> {
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      const HomePage(),
      const FarmerMyProducts(),
      const FarmerListScreen(),
      const FarmerSettingsScreen(),
    ];

    return Scaffold(
      body: children[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        onTabTapped: onTabTapped,
        currentIndex: _currentIndex,
      ),
    );
  }
}
