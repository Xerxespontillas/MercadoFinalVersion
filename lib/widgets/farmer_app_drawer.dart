import 'package:flutter/material.dart';

import '../screens/farmer_screens/farmer_drawer_screens/farmer_my_order.dart';

import '../screens/farmer_screens/farmer_new_post.dart';

class FarmerAppDrawer extends StatelessWidget {
  const FarmerAppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black45,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('My Orders'),
            onTap: () {
              Navigator.of(context).pushNamed(FarmerMyOrders.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('New Post'),
            onTap: () {
              Navigator.of(context).pushNamed(FarmerNewProductPost.routeName);
            },
          ),
        ],
      ),
    );
  }
}
