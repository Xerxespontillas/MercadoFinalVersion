import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:merkado/screens/farmer_screens/farmer_location_screen.dart';

import '../authentication/user/login_screen.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/farmer-home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Future<void> _farmersLocation() async {
  //   final farmersProvider =
  //       Provider.of<FarmersProvider>(context, listen: false);
  //   final farmers = farmersProvider.currentFarmers;

  //   if (farmers != null) {
  //     await FirebaseFirestore.instance
  //         .collection('merchantLocations')
  //         .doc(farmers.fullName)
  //         .set({
  //       'address': farmers.address,
  //       'merchant': 'Farmer',
  //       'status': 'onUserMap',
  //     });
  //   }
  //   // ignore: use_build_context_synchronously
  //   Navigator.pushNamed(context, FarmerLocationScreen.routeName);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome, Farmer!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Put your farmer screen content here',
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, FarmerLocationScreen.routeName);
              },
              child: const Text('Farmer\'s Location'),
            ),
            Container(
              margin: const EdgeInsets.only(left: 30),
              child: IconButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          ElevatedButton(
                            child: const Text('Logout'),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              // ignore: use_build_context_synchronously
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                LoginScreen.routeName,
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(
                  Icons.logout_outlined,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
