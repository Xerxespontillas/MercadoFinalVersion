import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'organization_selected_purchase.dart';

class OrganizationMyPurchases extends StatefulWidget {
  const OrganizationMyPurchases({super.key});
  static const routeName = '/organization-my-purchases';

  @override
  // ignore: library_private_types_in_public_api
  _OrganizationMyPurchasesState createState() =>
      _OrganizationMyPurchasesState();
}

class _OrganizationMyPurchasesState extends State<OrganizationMyPurchases> {
  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black, // Set the color of the back icon to black
        ),
        title: const Text('My Purchase',
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
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index];
              var items = order['items'];

              var deliveryFee = 50.0; // Assuming a fixed delivery fee

              return InkWell(
                onTap: () {
                  if (order.data() is Map) {
                    var sellerId = order['sellerId'];
                    var orderDate = order['date'];
                    bool orderConfirmed = order['orderConfirmed'];
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => OrganizationSelectedPurchase(
                            order: order.data() as Map,
                            items: items,
                            deliveryFee: deliveryFee,
                            sellerId: sellerId,
                            orderDate: orderDate,
                            orderConfirmed: orderConfirmed,
                            orderId: order.id)));
                  }
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Date: ${order['date']}'),
                        Text('Order ID: ${order.id}'),
                        Text('Seller: ${order['sellerName']}'),
                        ...items.map<Widget>((item) => ListTile(
                              leading: Image.network(
                                item['productImage'],
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  // Return any widget you want to be displayed instead of the network image like an asset image or an icon
                                  return const Icon(Icons.error);
                                },
                              ),
                              title: Text(item['productName']),
                              subtitle: Text('Price: ${item['productPrice']}'),
                              trailing:
                                  Text('Quantity: ${item['productQuantity']}'),
                            )),
                        Text('Delivery Fee: $deliveryFee'),
                        Text('Total Payment: ${items.fold(0.0, (total, item) {
                              var itemSubtotal = item['productPrice'] *
                                  item['productQuantity'];
                              var discountPercent =
                                  item['discount'] as int? ?? 0;
                              var minItems = item['minItems'] as int? ?? 0;
                              if (item['productQuantity'] >= minItems) {
                                var discountAmount =
                                    itemSubtotal * discountPercent / 100;
                                itemSubtotal -= discountAmount;
                              }
                              return total + itemSubtotal;
                            }) + deliveryFee}'),
                      ],
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
