import 'package:flutter/material.dart';
import 'package:merkado/screens/farmer_screens/farmer_drawer_screens/farmer_my_products.dart';
import 'package:merkado/screens/farmer_screens/farmer_chat_list.dart';
import '../../widgets/bottom_navigation_bar.dart';

//screens
import '../farmer_screens/farmer_homescreen.dart';

class FarmerScreenController extends StatefulWidget {
  static const routeName = '/farmer-home';
  const FarmerScreenController({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
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
    final List<Widget> children = [
      const HomePage(),
      const FarmerMyProducts(),
      const FarmerListScreen(),
      const Center(child: Text('Settings Page')),
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
