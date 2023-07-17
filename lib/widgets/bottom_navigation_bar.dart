import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final Function(int) onTabTapped;
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.onTabTapped,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: onTabTapped,
      currentIndex: currentIndex,
      backgroundColor: Colors.greenAccent,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_outlined),
          label: 'My Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    );
  }
}
