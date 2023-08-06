import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'org_org_chat_screen.dart';
import 'organization_chat_screen.dart';
import 'organization_farmer_chat_screen.dart';
import 'organization_my_products.dart';

class OrgMySelectedConfirmOrder extends StatelessWidget {
  static const routeName = '/organization-my-selected-confirmed-order';
  final Map order;
  final List items;
  final double deliveryFee;
  final String orderId;
  final String buyerId;
  final bool orderConfirmed;
  final String orderDate;

  const OrgMySelectedConfirmOrder({
    Key? key,
    required this.order,
    required this.items,
    required this.deliveryFee,
    required this.orderId,
    required this.buyerId,
    required this.orderConfirmed,
    required this.orderDate,
  }) : super(key: key);

  Future<String> getBuyerImageUrl() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('customers')
        .doc(buyerId)
        .get();
    return snapshot['profilePicture'];
  }

  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<String>(
      stream: getBuyerImageUrl().asStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final imageUrl = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(
              color: Colors.white, // Set the color of the back icon to black
            ),
            title: const Text('Customer Orders',
                style: TextStyle(
                    color: Colors.white,
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
                            if (order['buyerType'] == 'Farmer') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrgToFarmerChatScreen(
                                    userId:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    userType: OrgToFarmerType.farmer,
                                    displayName: order['buyerName'],
                                    farmerId: order['buyerId'],
                                  ),
                                ),
                              );
                            } else if (order['buyerType'] == 'Customer') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrganizationChatScreen(
                                    userId:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    userType: OrganizationType.customers,
                                    displayName: order['buyerName'],
                                    customerId: order['buyerId'],
                                  ),
                                ),
                              );
                            } else if (order['buyerType'] == 'Organization') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrgToOrgChatScreen(
                                    userId:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    userType: OrgToOrgType.customers,
                                    displayName: order['buyerName'],
                                    customerId: order['buyerId'],
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
                      'Order Date: $orderDate',
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
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Product Seller: ' +
                                        items[i]['productSeller'],
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                              Text(items[i]['productName']),
                            ],
                          ),
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
                      'Total Payment: ${items.fold(0.0, (total, item) {
                            var itemSubtotal =
                                item['productPrice'] * item['productQuantity'];
                            var discountPercent =
                                int.parse(item['discount'] ?? '0');
                            var minItems = int.parse(item['minItems'] ?? '0');
                            if (item['productQuantity'] >= minItems) {
                              var discountAmount =
                                  itemSubtotal * discountPercent / 100;
                              itemSubtotal -= discountAmount;
                            }
                            return total + itemSubtotal;
                          }) + deliveryFee}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    StreamBuilder<bool>(
                      stream: FirebaseFirestore.instance
                          .collection('organizations')
                          .doc(userId)
                          .collection('customerOrders')
                          .doc(orderId)
                          .snapshots()
                          .map((snapshot) => snapshot['orderCompleted']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        final bool orderCompleted = snapshot.data ?? false;
                        final bool orderCancelled = snapshot.data ?? false;

                        return Center(
                          child: Column(
                            children: [
                              if (orderCompleted && orderCancelled)
                                Column(
                                  children: [
                                    Icon(Icons.check, color: Colors.green),
                                    Text(
                                      'Order Status: Order Completed',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              else if (!orderCancelled && orderCompleted)
                                Column(
                                  children: [
                                    Icon(Icons.warning, color: Colors.red),
                                    Text(
                                      'Order Status: Order Cancelled',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Colors.orange),
                                    Text(
                                      'Order Status: Waiting to be Completed or Cancelled',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),

                              // if (!orderCompleted && orderCancelled)
                              //   orderCompleted
                              //       ? const Icon(Icons.check,
                              //           color: Colors.green)
                              //       : const Icon(Icons.info_outline,
                              //           color: Colors.orange),
                              // Text(
                              //   !orderCompleted
                              //       ? 'Waiting to be Completed or Cancelled'
                              //       : 'Order Status: Order Completed',
                              //   style: TextStyle(
                              //     fontSize: 16,
                              //     fontWeight: FontWeight.bold,
                              //     color: !orderCompleted
                              //         ? Colors.orange
                              //         : Colors.green,
                              //   ),
                              //   textAlign: TextAlign.center,
                              // ),
                              if (!orderCompleted || !orderCancelled)
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
                                            .delete();

                                        // Here is how to delete the orderId from farmers collection
                                        await FirebaseFirestore.instance
                                            .collection('organizations')
                                            .doc(userId)
                                            .collection('customerOrders')
                                            .doc(orderId)
                                            .delete();

                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Order has been cancelled.'),
                                            backgroundColor:
                                                Color.fromARGB(255, 255, 0, 0),
                                          ),
                                        );
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                OrganizationMyProducts
                                                    .routeName);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      child: const Text('Cancel Order'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('organizations')
                                            .doc(userId)
                                            .collection('customerOrders')
                                            .doc(orderId)
                                            .update({
                                          'orderCompleted': true,
                                          'orderCancelled': false
                                        });

                                        await FirebaseFirestore.instance
                                            .collection('customersOrders')
                                            .doc(buyerId)
                                            .collection('orders')
                                            .doc(orderId)
                                            .update({
                                          'orderCompleted': true,
                                          'orderCancelled': false
                                        });

                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Order has been completed.'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green),
                                      child: const Text('Order Completed'),
                                    ),
                                  ],
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
