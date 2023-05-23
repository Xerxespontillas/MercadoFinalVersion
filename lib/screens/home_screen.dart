import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'authentication/user/login_screen.dart';
import 'user_location_screen.dart';

class HomePageScreen extends StatefulWidget {
  static const routeName = '/home-page';

  const HomePageScreen({Key? key}) : super(key: key);

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome, Customer!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Put your customer screen content here',
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, UserLocationScreen.routeName);
              },
              child: const Text('User\'s Location'),
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
