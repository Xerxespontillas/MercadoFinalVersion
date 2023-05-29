import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerSelectedOrder extends StatelessWidget {
  static const routeName = '/customer-my-selected-order';
  final Map order;
  final List items;
  final double deliveryFee;
  final String orderId;
  final String sellerId;

  const CustomerSelectedOrder({
    Key? key,
    required this.order,
    required this.items,
    required this.deliveryFee,
    required this.orderId,
    required this.sellerId,
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
    return FutureBuilder<String>(
      future: getSellerImageUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final imageUrl = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('Your Orders', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent,
          ),
          body: Padding(
            padding: EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(16.0),
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
                    SizedBox(height: 10),
                    Text('Seller: ${order['sellerName']}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    SizedBox(height: 10),
                    Divider(),
                    Text('Order ID: $orderId',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Divider(),
                    Text('Items:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Column(
                      children: items
                          .map<Widget>((item) => ListTile(
                                leading: Image.network(item['productImage']),
                                title: Text(item['productName']),
                                subtitle:
                                    Text('Price: ${item['productPrice']}'),
                                trailing: Text(
                                    'Quantity: ${item['productQuantity']}'),
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    Text('Delivery Fee: $deliveryFee',
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Text(
                      'Total Payment: ${items.fold(0.0, (total, item) => total + item['productPrice'] * item['productQuantity']) + deliveryFee}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          Text(
                            'Order Status: Waiting for confirmation of Seller',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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
