import 'package:flutter/material.dart';

class UserCustomBottomNavBar extends StatelessWidget {
  final Function(int) onTabTapped;
  final int currentIndex;

  const UserCustomBottomNavBar({
    super.key,
    required this.onTabTapped,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: onTabTapped,
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_work, size: 40),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.message,
            size: 40,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings, size: 40),
          label: '',
        ),
      ],
    );
  }
}
