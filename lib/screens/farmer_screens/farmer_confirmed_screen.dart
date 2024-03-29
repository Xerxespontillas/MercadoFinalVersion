import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:merkado/screens/farmer_screens/farmer_selected_confirmed_order.dart';

class FarmerConfirmedCustomerOrders extends StatefulWidget {
  const FarmerConfirmedCustomerOrders({super.key});

  @override
  State<FarmerConfirmedCustomerOrders> createState() =>
      _FarmerConfirmedCustomerOrdersState();
}

class _FarmerConfirmedCustomerOrdersState
    extends State<FarmerConfirmedCustomerOrders> {
  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Confirmed Orders',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('farmers')
            .doc(userId)
            .collection('customerOrders')
            .where('orderCompleted', isEqualTo: false)

            // Filter only confirmed orders
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
                    var buyerId = order['buyerId'];
                    var orderDate = order['date'];
                    bool orderConfirmed = order['orderConfirmed'];
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FarmerMySelectedConfirmedOrder(
                        order: order.data() as Map,
                        items: items,
                        deliveryFee: deliveryFee,
                        buyerId: buyerId,
                        orderDate: orderDate,
                        orderConfirmed: orderConfirmed,
                        orderId: order.id,
                      ),
                    ));
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
                        Text('Buyer: ${order['buyerName']}'),
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
