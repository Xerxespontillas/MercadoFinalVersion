import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'farmer_my_selected_order.dart';

class FarmerMyOrders extends StatefulWidget {
  const FarmerMyOrders({super.key});
  static const routeName = '/farmer-my-order';

  @override
  // ignore: library_private_types_in_public_api
  _FarmerMyOrdersState createState() => _FarmerMyOrdersState();
}

class _FarmerMyOrdersState extends State<FarmerMyOrders> {
  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('farmers')
            .doc(userId)
            .collection('customerOrders')
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
                    bool orderConfirmed = order['orderConfirmed'];
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => FarmerMySelectedOrder(
                            order: order.data() as Map,
                            items: items,
                            deliveryFee: deliveryFee,
                            buyerId: buyerId,
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
                              title: Text(item['productName']),
                              subtitle: Text('Price: ${item['productPrice']}'),
                              trailing:
                                  Text('Quantity: ${item['productQuantity']}'),
                            )),
                        Text('Delivery Fee: $deliveryFee'),
                        Text(
                            'Total Payment: ${items.fold(0.0, (total, item) => total + item['productPrice'] * item['productQuantity']) + deliveryFee}'),
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
