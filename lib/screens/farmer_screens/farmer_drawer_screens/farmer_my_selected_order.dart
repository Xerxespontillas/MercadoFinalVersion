import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:merkado/screens/farmer_screens/farmer_drawer_screens/farmer_my_products.dart';
import 'package:merkado/screens/farmer_screens/farmer_farmer_chat_screen.dart';

import '../farmer_chat_screen.dart';
import '../farmer_org_chat_screen.dart';
import 'farmer_customer_order.dart';

class FarmerMySelectedOrder extends StatelessWidget {
  static const routeName = '/farmer-my-selected-order';
  final Map order;
  final List items;
  final double deliveryFee;
  final String orderId;
  final String buyerId;
  final bool orderConfirmed;
  //final bool orderCancelled;
  final String orderDate;

  const FarmerMySelectedOrder({
    Key? key,
    required this.order,
    required this.items,
    required this.deliveryFee,
    required this.orderId,
    required this.buyerId,
    required this.orderConfirmed,
    //required this.orderCancelled,
    required this.orderDate,
  }) : super(key: key);

  Future<String?> getBuyerImageUrl() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('customers')
        .doc(buyerId)
        .get();
    if (snapshot.exists) {
      return snapshot.data()?['profilePicture'];
    } else {
      final farmerSnapshot = await FirebaseFirestore.instance
          .collection('farmers')
          .doc(buyerId)
          .get();
      if (farmerSnapshot.exists && farmerSnapshot.data() != null) {
        return farmerSnapshot.data()?['profilePicture'];
      } else {
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<String?>(
      stream: getBuyerImageUrl().asStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final imageUrl = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(
              color: Colors.black, // Set the color of the back icon to black
            ),
            title: const Text('Customer Orders',
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null)
                      Center(
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(imageUrl),
                          radius: 60,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Buyer: ${order['buyerName']}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        InkWell(
                          child: const Icon(Icons.message),
                          onTap: () {
                            if (order['buyerType'] == 'Customer') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FarmerChatScreen(
                                    userId:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    userType: FarmerType.customers,
                                    displayName: order['buyerName'],
                                    customerId: order['buyerId'],
                                  ),
                                ),
                              );
                            } else if (order['buyerType'] == 'Farmer') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FarmerToFarmerChatScreen(
                                    userId:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    userType: FarmersType.farmer,
                                    displayName: order['buyerName'],
                                    customerId: order['buyerId'],
                                  ),
                                ),
                              );
                            } else if (order['buyerType'] == 'Organization') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FarmerToOrgChatScreen(
                                    userId:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    userType: FarmerToOrgType.farmer,
                                    displayName: order['buyerName'],
                                    orgId: order['buyerId'],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    Text(
                      'Order date: $orderDate',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Order ID: $orderId',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const Text(
                      'Items:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 150, // Adjust this height to suit your needs
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (ctx, i) => ListTile(
                          leading: Image.network(
                            items[i]['productImage'],
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              // Return any widget you want to be displayed instead of the network image like an asset image or an icon
                              return const Icon(Icons.error);
                            },
                          ),
                          title: Text(items[i]['productName']),
                          subtitle: Text('Price: ${items[i]['productPrice']}'),
                          trailing:
                              Text('Quantity: ${items[i]['productQuantity']}'),
                        ),
                      ),
                    ),
                    const Divider(),
                    Text(
                      'Delivery Fee: $deliveryFee',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Total Payment: ${items.fold(0.0, (total, item) => total + item['productPrice'] * item['productQuantity']) + deliveryFee}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    StreamBuilder<bool>(
                        stream: FirebaseFirestore.instance
                            .collection('farmers')
                            .doc(userId)
                            .collection('customerOrders')
                            .doc(orderId)
                            .snapshots()
                            .map((snapshot) => snapshot['orderConfirmed']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          final bool orderConfirmed = snapshot.data ?? false;

                          return StreamBuilder<bool>(
                            stream: FirebaseFirestore.instance
                                .collection('farmers')
                                .doc(userId)
                                .collection('customerOrders')
                                .doc(orderId)
                                .snapshots()
                                .map((snapshot) => snapshot['orderCancelled']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              final bool orderCancelled =
                                  snapshot.data ?? false;

                              return Center(
                                child: Column(
                                  children: [
                                    orderConfirmed
                                        ? const Icon(Icons.check,
                                            color: Colors.green)
                                        : orderCancelled
                                            ? const Icon(Icons.cancel,
                                                color: Colors.red)
                                            : const Icon(Icons.info_outline,
                                                color: Colors.orange),
                                    Text(
                                      orderCancelled
                                          ? 'Order Status: Declined Order'
                                          : !orderConfirmed
                                              ? 'Order Status: waiting for confirmation'
                                              : 'Order Status: Order Confirmed',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: orderCancelled
                                            ? Colors.red
                                            : !orderConfirmed
                                                ? Colors.orange
                                                : Colors.green,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (!orderConfirmed && !orderCancelled)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('customersOrders')
                                                  .doc(buyerId)
                                                  .collection('orders')
                                                  .doc(orderId)
                                                  .update(
                                                      {'orderCancelled': true});

                                              // Here is how to delete the orderId from farmers collection
                                              await FirebaseFirestore.instance
                                                  .collection('farmers')
                                                  .doc(userId)
                                                  .collection('customerOrders')
                                                  .doc(orderId)
                                                  .update(
                                                      {'orderCancelled': true});

                                              // ignore: use_build_context_synchronously
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Order has been cancelled.'),
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 255, 0, 0),
                                                ),
                                              );
                                              // ignore: use_build_context_synchronously
                                              Navigator.of(context)
                                                  .pushReplacementNamed(
                                                      //FarmerMyProducts
                                                      FarmerCustomerOrders
                                                          .routeName);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            child: const Text('Decline Order'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('farmers')
                                                  .doc(userId)
                                                  .collection('customerOrders')
                                                  .doc(orderId)
                                                  .update(
                                                      {'orderConfirmed': true});

                                              await FirebaseFirestore.instance
                                                  .collection('customersOrders')
                                                  .doc(buyerId)
                                                  .collection('orders')
                                                  .doc(orderId)
                                                  .update(
                                                      {'orderConfirmed': true});

                                              // ignore: use_build_context_synchronously
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Order has been confirmed.'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green),
                                            child: const Text('Confirm Order'),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
