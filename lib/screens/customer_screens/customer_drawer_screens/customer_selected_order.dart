import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                          'Seller: ${order['sellerName']}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        InkWell(
                          child: Icon(Icons.message),
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 150, // Adjust this height to suit your needs
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (ctx, i) => ListTile(
                          leading: Image.network(items[i]['productImage']),
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
                              const Icon(Icons.info_outline,
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
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('customersOrders')
                                          .doc(userId)
                                          .collection('orders')
                                          .doc(orderId)
                                          .delete();
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Order Cancelled Successfully!'),
                                          duration: Duration(seconds: 2),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).pushNamed(
                                          CustomerMyOrders.routeName);
                                    } catch (e) {
                                      // You can handle any error here
                                    }
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
        );
      },
    );
  }
}
