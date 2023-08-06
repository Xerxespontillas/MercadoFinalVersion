// previos code
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrgCustomerOrderHistory extends StatefulWidget {
  const OrgCustomerOrderHistory({super.key});
  static const routeName = '/customer-my-orders';

  @override
  // ignore: library_private_types_in_public_api
  _OrgCustomerOrderHistoryState createState() =>
      _OrgCustomerOrderHistoryState();
}

class _OrgCustomerOrderHistoryState extends State<OrgCustomerOrderHistory> {
  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Order History',
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('organizations')
            .doc(userId)
            .collection('customerOrders')
            .where('orderCompleted',
                isEqualTo: true) // Filter only pending orders
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
              var deliveryFee = 0.0; // Assuming a fixed delivery fee

              final bool orderCompleted = order['orderCompleted'] ?? false;
              final bool orderCancelled = order['orderCancelled'] ?? false;

              // If both orderCancelled and orderConfirmed are false, don't display the item
              if (!orderCompleted && !orderCancelled) {
                return Container();
              }

              return InkWell(
                child: Card(
                  shape: orderCompleted
                      ? const RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.green,
                            width: 5,
                          ),
                        )
                      : const RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.red,
                            width: 5,
                          ),
                        ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom:
                                  20.0), // Adjust the bottom padding as needed
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Order date: ${order['date']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Text('Order ID: ${order.id}'),
                        Text('Buyer: ${order['buyerName']}'),
                        Text(
                          orderCancelled
                              ? 'Status: Declined'
                              : 'Status: Confirmed',
                          style: TextStyle(
                            color: orderCancelled ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...items.map<Widget>((item) => ListTile(
                              leading: Image.network(
                                item['productImage'],
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
                                            item['productSeller'],
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  Text(item['productName']),
                                ],
                              ),
                              subtitle: Text('Price: ${item['productPrice']}'),
                              trailing:
                                  Text('Quantity: ${item['productQuantity']}'),
                            )),
                        Text('Delivery Fee: $deliveryFee'),
                        Text('Total Payment: ${items.fold(0.0, (total, item) {
                              var itemSubtotal = item['productPrice'] *
                                  item['productQuantity'];
                              var discountPercent =
                                  int.parse(item['discount'] ?? '0');
                              var minItems = int.parse(item['minItems'] ?? '0');
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
