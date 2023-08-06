import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../authentication/user/login_screen.dart';
import 'farmer_list.dart';
import 'organization_list.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  static const routeName = '/admin-screen';

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromARGB(0, 66, 180, 119),
          centerTitle: true,
          actions: [
            IconButton(
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
              ),
            ),
          ],
          title: const Text(
            'Admin',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Inter',
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black, size: 30),
        ),
        body: Column(
          children: [
            Container(
              color:
                  Colors.grey, // Set the background color of the TabBar to grey
              child: TabBar(
                unselectedLabelColor: Colors.white,
                indicatorColor: Colors.black,
                labelColor: Colors.black,
                tabs: [
                  Tab(
                    icon: Image.asset(
                        'assets/images/farmer.png'), // Custom agriculture icon
                  ),
                  Tab(
                    icon: Image.asset(
                        'assets/images/organization.png'), // Custom groups icon
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  FarmerList(),
                  OrganizationList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
