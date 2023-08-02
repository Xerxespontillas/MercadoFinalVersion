import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:merkado/screens/farmer_screens/farmer_location_screen.dart';
import 'package:merkado/screens/organization_screens/organization_location_screen.dart';

import '../screens/customer_screens/tab_controllers.dart';
import '../screens/farmer_screens/farmer_drawer_screens/farmer_customer_order.dart';

import '../screens/farmer_screens/farmer_new_post.dart';
import '../screens/organization_screens/organization_customer_orders.dart';

class FarmerAppDrawer extends StatelessWidget {
  const FarmerAppDrawer({Key? key}) : super(key: key);

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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black45,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () async {
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
                  child: const Text(
                    'Tap to Initialize Location.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Customer Orders'),
            onTap: () async {
              String userType = await _getUserType();
              if (userType == 'farmer') {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushNamed(FarmerCustomerOrders.routeName);
                // ignore: avoid_print
                print("NI SUD SA Farmer");
              } else if (userType == 'organization') {
                // ignore: avoid_print
                print("NI SUD SA ORGANIZATION");
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushNamed(OrgCustomerOrders.routeName);
              } else {
                // Handle unknown user type...
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopify_outlined),
            title: const Text('My Purchases'),
            onTap: () async {
              // String userType = await _getUserType();
              Navigator.of(context).pushNamed(TabControllers.routeName);
              // if (userType == 'farmer') {

              //   // ignore: use_build_context_synchronously
              //   // Navigator.of(context).pushNamed(FarmerMyPurchases.routeName);
              //   // ignore: avoid_print
              //   print("NI SUD SA Farmer");
              // } else if (userType == 'organization') {
              //   Navigator.of(context).pushNamed(TabControllers.routeName);
              //   // ignore: avoid_print
              //   print("NI SUD SA ORGANIZATION");
              //   // ignore: use_build_context_synchronously
              //   // Navigator.of(context)
              //       // .pushNamed(OrganizationMyPurchases.routeName);
              // } else {
              //   // Handle unknown user type...
              // }
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Product'),
            onTap: () {
              Navigator.of(context).pushNamed(FarmerNewProductPost.routeName);
            },
          ),
        ],
      ),
    );
  }
}
