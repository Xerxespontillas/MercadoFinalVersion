import 'package:flutter/material.dart';
import 'package:merkado/screens/customer_screens/cart_screen.dart';
import 'package:merkado/screens/customer_screens/customer_drawer_screens/customer_my_orders.dart';
import 'package:merkado/screens/customer_screens/tab_controllers.dart';

class CustomerAppDrawer extends StatelessWidget {
  const CustomerAppDrawer({Key? key}) : super(key: key);

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
            title: const Text('My Purchase'),
            onTap: () {
              Navigator.of(context).pushNamed(TabControllers.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('My Cart'),
            onTap: () {
              Navigator.of(context).pushNamed(CartScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
