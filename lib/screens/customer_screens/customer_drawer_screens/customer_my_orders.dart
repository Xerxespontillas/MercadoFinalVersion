import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'customer_selected_order.dart';

class CustomerMyOrders extends StatefulWidget {
  const CustomerMyOrders({super.key});
  static const routeName = '/customer-my-orders';

  @override
  // ignore: library_private_types_in_public_api
  _CustomerMyOrdersState createState() => _CustomerMyOrdersState();
}

class _CustomerMyOrdersState extends State<CustomerMyOrders> {
  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black, // Set the color of the back icon to black
        ),
        title: const Text('Pending Orders',
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customersOrders')
            .doc(userId)
            .collection('orders')
            //.orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }
          print([
            'itemCount',
            snapshot.data!.docs.length,
          ]);
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index];
              var items = order['items'];
              print('items');
              print(items);
              var deliveryFee = 0.0; // Assuming a fixed delivery feer

              bool orderConfirmed = order['orderConfirmed'] ?? false;
              bool orderCancelled = order['orderCancelled'] ?? false;

              print(items);
              return Visibility(
                visible: !orderConfirmed && !orderCancelled,
                child: InkWell(
                  onTap: () {
                    if (order.data() is Map) {
                      var sellerId = order['sellerId'] ?? '';
                      var orderDate = order['date'];
                      print(['order.id', order.id]);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CustomerSelectedOrder(
                              order: order.data() as Map,
                              items: items,
                              deliveryFee: deliveryFee,
                              sellerId: sellerId,
                              orderDate: orderDate,
                              orderConfirmed: orderConfirmed,
                              //orderCancelled: orderCancelled,
                              orderId: order.id)));
                    }
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order date: ${order['date']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Order ID: ${order.id}'),
                          Text('Seller: ${order['sellerName']}'),
                          items is List
                              ? ListTile(
                                  leading: Image.network(
                                    items[0]['productImage'] ?? '',
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? stackTrace) {
                                      // Return any widget you want to be displayed instead of the network image like an asset image or an icon
                                      return const Icon(Icons.error);
                                    },
                                  ),
                                  title: Text(
                                    items[0]['productName'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                      'Price: ${items[0]['productPrice']}'),
                                  trailing: Text(
                                      'Quantity: ${items[0]['productQuantity']}'),
                                )
                              : ListTile(
                                  leading: Image.network(
                                    items['productImage'] ?? '',
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? stackTrace) {
                                      // Return any widget you want to be displayed instead of the network image like an asset image or an icon
                                      return const Icon(Icons.error);
                                    },
                                  ),
                                  title: Text(items['productName']),
                                  subtitle:
                                      Text('Price: ${items['productPrice']}'),
                                  trailing: Text(
                                      'Quantity: ${items['productQuantity']}'),
                                ),
                          Text('Delivery Fee: $deliveryFee'),
                          Text(
                            'Total Payment: ${items.fold(0.0, (total, item) => total + item['productPrice'] * item['productQuantity']) + deliveryFee}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
