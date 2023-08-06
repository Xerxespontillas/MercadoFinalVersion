import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/farmer_screens/farmer_location_screen.dart';
import '../screens/organization_screens/organization_location_screen.dart';

class OrgCustomBottomNavBar extends StatelessWidget {
  final Function(int) onTabTapped;
  final int currentIndex;

  const OrgCustomBottomNavBar({
    super.key,
    required this.onTabTapped,
    required this.currentIndex,
  });
  Future<String> _getUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    final farmersSnapshot = await FirebaseFirestore.instance
        .collection('farmers')
        .doc(user!.uid)
        .get();
    if (farmersSnapshot.exists) {
      return 'farmer';
    } else {
      final orgSnapshot = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(user.uid)
          .get();
      if (orgSnapshot.exists) {
        return 'organization';
      } else {
        return 'unknown';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Your omnipresent button
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  String userType = await _getUserType();
                  if (userType == 'farmer') {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context)
                        .pushNamed(FarmerLocationScreen.routeName);
                    // ignore: avoid_print
                    print("NI SUD SA Farmer");
                  } else if (userType == 'organization') {
                    // ignore: avoid_print
                    print("NI SUD SA ORGANIZATION");
                    // ignore: use_build_context_synchronously
                    Navigator.of(context)
                        .pushNamed(OrganizationLocationScreen.routeName);
                  } else {
                    // Handle unknown user type...
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors
                      .green), // Set the button's background color to green
                ),
                child: const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Align icon to the left
                  children: [
                    Icon(Icons.gps_fixed_rounded), // Button icon on the left
                    SizedBox(
                        width:
                            8), // Add some spacing between the icons and text
                    Text(
                      'Tap to initialize your location', // Button text
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration
                            .underline, // Add underline decoration
                        decorationColor:
                            Colors.white, // Customize underline color
                        decorationThickness:
                            1.5, // Customize underline thickness
                      ),
                    ), // Button text
                  ],
                ),
              ),
            ),
          ],
        ),
        BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: currentIndex,
          backgroundColor: Colors.greenAccent,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey[600],
          items: [
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
              icon: Image.asset(
                'assets/images/organization.png',
                width: 25,
                height: 25,
              ), // Custom groups icon

              label: 'Farmers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
      ],
    );
  }
}
