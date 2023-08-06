import 'package:flutter/material.dart';
import 'package:merkado/screens/organization_screens/org_confirmed_orders.dart';
import 'package:merkado/screens/organization_screens/org_order_history.dart';
import 'package:merkado/screens/organization_screens/org_pending_screens.dart';

class OrgCustomerOrders extends StatefulWidget {
  const OrgCustomerOrders({super.key});
  static const routeName = '/org-customer-orders';

  @override
  // ignore: library_private_types_in_public_api
  _OrgCustomerOrdersState createState() => _OrgCustomerOrdersState();
}

class _OrgCustomerOrdersState extends State<OrgCustomerOrders> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
                  Tab(icon: Icon(Icons.history) // Custom groups icon
                      ),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  OrgCustomerPendingOrders(),
                  OrgCustomerConfirmedOrders(),
                  OrgCustomerOrderHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
