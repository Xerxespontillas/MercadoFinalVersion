import 'package:flutter/material.dart';
import 'package:merkado/screens/customer_screens/customer_completed_orders.dart';
import 'package:merkado/screens/customer_screens/customer_confirmed_screens.dart';
import 'package:merkado/screens/customer_screens/customer_history.dart';
import 'package:merkado/screens/farmer_screens/farmer_drawer_screens/farmer_customer_order.dart';

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
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Colors.white, // Set the color of the back icon to black
          ),
          title: const Text(
            'My Purchases',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Colors
                  .black, // Set the background color of the TabBar to grey
              child: const TabBar(
                unselectedLabelColor: Colors.white,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                tabs: [
                  Tab(
                      icon: Icon(Icons
                          .pending_actions_outlined) // Custom agriculture icon
                      ),
                  Tab(
                      icon: Icon(
                          Icons.playlist_add_check_sharp) // Custom groups icon
                      ),
                  Tab(icon: Icon(Icons.library_add_check) // Custom groups icon
                      ),
                  Tab(icon: Icon(Icons.history) // Custom groups icon
                      ),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  CustomerMyOrders(),
                  CustomerConfirmedOrders(),
                  CustomersCompletedOrders(),
                  CustomerHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
