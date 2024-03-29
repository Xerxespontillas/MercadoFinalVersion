import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:merkado/screens/farmer_screens/farmer_drawer_screens/farmer_my_selected_order.dart';

class FarmerPendingCustomerOrders extends StatefulWidget {
  const FarmerPendingCustomerOrders({super.key});
  static const routeName = '/farmer-pending-customer-order';

  @override
  // ignore: library_private_types_in_public_api
  _FarmerPendingCustomerOrdersState createState() =>
      _FarmerPendingCustomerOrdersState();
}

class _FarmerPendingCustomerOrdersState
    extends State<FarmerPendingCustomerOrders> {
  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Pending Orders',
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('farmers')
            .doc(userId)
            .collection('customerOrders')
            .where('orderConfirmed', isEqualTo: false)
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

              return InkWell(
                onTap: () {
                  if (order.data() is Map) {
                    var buyerId = order['buyerId'];
                    var orderDate = order['date'];
                    bool orderConfirmed = order['orderConfirmed'];
                    //bool orderCancelled = order['orderCancelled'];
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => FarmerMySelectedOrder(
                            order: order.data() as Map,
                            items: items,
                            deliveryFee: deliveryFee,
                            orderDate: orderDate,
                            buyerId: buyerId,
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
                          'Order Date: ${order['date']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                              title: Text(
                                item['productName'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Price: ${item['productPrice']}'),
                              trailing:
                                  Text('Quantity: ${item['productQuantity']}'),
                            )),
                        Text('Delivery Fee: $deliveryFee'),
                        Text(
                          'Total Payment: ${items.fold(0.0, (total, item) {
                                var itemSubtotal = item['productPrice'] *
                                    item['productQuantity'];
                                var discountPercent =
                                    int.parse(item['discount'] ?? '0');
                                var minItems =
                                    int.parse(item['minItems'] ?? '0');
                                if (item['productQuantity'] >= minItems) {
                                  var discountAmount =
                                      itemSubtotal * discountPercent / 100;
                                  itemSubtotal -= discountAmount;
                                }
                                return total + itemSubtotal;
                              }) + deliveryFee}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
