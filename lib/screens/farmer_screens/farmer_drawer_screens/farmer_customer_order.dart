import 'package:flutter/material.dart';
import 'package:merkado/screens/farmer_screens/farmer_completed_orders.dart';
import 'package:merkado/screens/farmer_screens/farmer_confirmed_screen.dart';
import 'package:merkado/screens/farmer_screens/farmer_order_history_screen.dart';
import 'package:merkado/screens/farmer_screens/farmer_pending_screen.dart';

class FarmerCustomerOrders extends StatefulWidget {
  const FarmerCustomerOrders({super.key});
  static const routeName = '/farmer-customer-order';

  @override
  // ignore: library_private_types_in_public_api
  _FarmerCustomerOrdersState createState() => _FarmerCustomerOrdersState();
}

class _FarmerCustomerOrdersState extends State<FarmerCustomerOrders> {
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
            'Customer Orders',
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
                  FarmerPendingCustomerOrders(),
                  FarmerConfirmedCustomerOrders(),
                  FarmerCompletedCustomersOrders(),
                  FarmerCustomerOrderHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
