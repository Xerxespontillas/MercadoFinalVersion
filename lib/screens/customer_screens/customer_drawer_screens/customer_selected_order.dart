import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:merkado/screens/customer_screens/user_location_screen.dart';

import '../user_chat_screen.dart';
import 'customer_my_orders.dart';

class CustomerSelectedOrder extends StatelessWidget {
  static const routeName = '/customer-my-selected-order';
  final Map order;
  final List items;
  final double deliveryFee;
  final String orderId;
  final String sellerId;
  final bool orderConfirmed;

  const CustomerSelectedOrder({
    Key? key,
    required this.order,
    required this.items,
    required this.deliveryFee,
    required this.orderId,
    required this.sellerId,
    required this.orderConfirmed,
  }) : super(key: key);

  Future<String> getSellerImageUrl() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('farmers')
        .doc(sellerId)
        .get();
    return snapshot['profilePicture'];
  }

  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<String>(
      stream: getSellerImageUrl().asStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final imageUrl = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(
              color: Colors.black, // Set the color of the back icon to black
            ),
            centerTitle: true,
            title: const Text(
              'Your Orders',
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
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
                            'Seller: ${order['sellerName']}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          InkWell(
                            child: const Icon(Icons.pin_drop_outlined),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, UserLocationScreen.routeName);
                            },
                          ),
                          InkWell(
                            child: const Icon(Icons.message),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserChatScreen(
                                    userId:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    userType: UserType.customers,
                                    displayName: order['sellerName'],
                                    farmerId: order['sellerId'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      Text(
                        'Order ID: $orderId',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const Text(
                        'Items:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                            subtitle:
                                Text('Price: ${items[i]['productPrice']}'),
                            trailing: Text(
                                'Quantity: ${items[i]['productQuantity']}'),
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
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      StreamBuilder<bool>(
                        stream: FirebaseFirestore.instance
                            .collection('customersOrders')
                            .doc(userId)
                            .collection('orders')
                            .doc(orderId)
                            .snapshots()
                            .map((snapshot) => snapshot['orderConfirmed']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          final bool orderConfirmed = snapshot.data ?? false;
                          return Center(
                            child: Column(
                              children: [
                                orderConfirmed
                                    ? const Icon(Icons.check,
                                        color: Colors.green)
                                    : const Icon(Icons.info_outline,
                                        color: Colors.orange),
                                Text(
                                  !orderConfirmed
                                      ? 'Order Status: Waiting for confirmation of Seller'
                                      : 'Order Status: Order Confirmed',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: !orderConfirmed
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (!orderConfirmed)
                                  ElevatedButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('customersOrders')
                                          .doc(userId)
                                          .collection('orders')
                                          .doc(orderId)
                                          .delete();

                                      // Here is how to delete the orderId from farmers collection
                                      await FirebaseFirestore.instance
                                          .collection('farmers')
                                          .doc(sellerId)
                                          .collection('customerOrders')
                                          .doc(orderId)
                                          .delete();

                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Order has been cancelled.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context)
                                          .pushReplacementNamed(
                                              CustomerMyOrders.routeName);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    child: const Text('CANCEL'),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
