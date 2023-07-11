import 'package:flutter/material.dart';
import 'package:merkado/screens/customer_screens/customer_history.dart';

import 'customer_drawer_screens/customer_my_orders.dart';

class TabControllers extends StatefulWidget {
  const TabControllers({super.key});
  static const routeName = '/customer-tab-controller';

  @override
  State<TabControllers> createState() => _TabControllersState();
}

class _TabControllersState extends State<TabControllers> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme:
              const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pending_actions)),
              Tab(icon: Icon(Icons.history)),
            ],
          ),
          title: const Center(
            child: Text('My Purchase'),
          ),
          automaticallyImplyLeading: true,
        ),
        body: const TabBarView(
          children: [
            CustomerMyOrders(),
            CustomerHistory(),
          ],
        ),
      ),
    );
  }
}
