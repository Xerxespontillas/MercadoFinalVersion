import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FarmerMyOrder extends StatefulWidget {
  static const routeName = '/farmer-my-order';
  const FarmerMyOrder({super.key});

  @override
  State<FarmerMyOrder> createState() => _FarmerMyOrderState();
}

class _FarmerMyOrderState extends State<FarmerMyOrder> {
  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('farmers')
            .doc(userId)
            .collection('customerOrders')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index];
              var items = order['items'];

              return Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID: ${order.id}'),
                      Text('Buyer: ${order['buyerName']}'),
                      ...items.map<Widget>((item) => ListTile(
                            leading: Image.network(item['productImage']),
                            title: Text(item['productName']),
                            subtitle: Text('Price: ${item['productPrice']}'),
                            trailing:
                                Text('Quantity: ${item['productQuantity']}'),
                          )),
                    ],
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
