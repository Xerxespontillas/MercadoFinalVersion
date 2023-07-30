// ignore_for_file: avoid_print, use_build_context_synchronously, camel_case_types

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:merkado/screens/customer_screens/user_location_screen.dart';
import 'package:provider/provider.dart';

import '../../../providers/cart_provider.dart';
import '../../farmer_screens/models/product.dart';
import '../user_chat_screen.dart';
import '../user_org_chat_screen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// ignore: must_be_immutable
class CustomerSelectedOrder extends StatefulWidget {
  bool isPurchase = false;
  static const routeName = '/customer-my-selected-order';
  final Map order;
  final List items;
  final double deliveryFee;
  final String orderId;
  final String sellerId;
  final bool orderConfirmed;
  //final bool orderCancelled;
  final String orderDate;
  String discountDescription = '';
  String image = '';
  double total = 0;
  double totalDiscount = 0.0;

  CustomerSelectedOrder({
    Key? key,
    required this.order,
    required this.items,
    required this.deliveryFee,
    required this.orderId,
    required this.sellerId,
    required this.orderConfirmed,
    //required this.orderCancelled,
    required this.orderDate,
    this.isPurchase = false,
    this.image = '',
    this.total = 0,
    this.totalDiscount = 0.0,
    this.discountDescription = '',
  }) : super(key: key);

  @override
  State<CustomerSelectedOrder> createState() => _CustomerSelectedOrderState();
}

class _CustomerSelectedOrderState extends State<CustomerSelectedOrder> {
  String userId = '';

  Future<String> getSellerImageUrl() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('farmers')
        .doc(widget.sellerId)
        .get();
    return snapshot['profilePicture'];
  }

  // Future<List?> getItems(String orderId) async {
  @override
  Widget build(BuildContext context) {
    userId = FirebaseAuth.instance.currentUser!.uid;
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
          body: SingleChildScrollView(
            child: Padding(
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
                            'Seller: ${widget.order['sellerName'] ?? ''}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          InkWell(
                            child: const Icon(Icons.pin_drop_outlined),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, UserLocationScreen.routeName);
                            },
                          ),
                          InkWell(
                            child: const Icon(Icons.message),
                            onTap: () {
                              if (widget.order['sellerType'] == 'Farmer') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserChatScreen(
                                      userId: FirebaseAuth
                                          .instance.currentUser!.uid,
                                      userType: UserType.customers,
                                      displayName: widget.order['sellerName'],
                                      farmerId: widget.order['sellerId'],
                                    ),
                                  ),
                                );
                              } else if (widget.order['sellerType'] ==
                                  'Organization') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrgChatScreen(
                                      userId: FirebaseAuth
                                          .instance.currentUser!.uid,
                                      orgType: OrgType.customers,
                                      displayName: widget.order['sellerName'],
                                      orgId: widget.order['sellerId'],
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
                        'Order Date: ${widget.orderDate}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Order ID: ${widget.orderId}',
                        //style: const TextStyle(
                        //fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const Text(
                        'Items :',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 150, // Adjust this height to suit your needs
                        child: widget.isPurchase
                            ? ListTile(
                                leading: Image.network(
                                  widget.order['image'] ?? '',
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    // Return any widget you want to be displayed instead of the network image like an asset image or an icon
                                    return const Icon(Icons.error);
                                  },
                                ),
                                title: Text(widget.order['productName'] ?? ''),
                                subtitle: Text(
                                    'Price: ${widget.order['price'] ?? ''}'),
                                trailing: Text(
                                    'Quantity: ${widget.order['quantity'] ?? ''}'),
                              )
                            : SizedBox(
                                height:
                                    150, // Adjust this height to suit your needs
                                child: ListView.builder(
                                  itemCount: widget.items.length,
                                  itemBuilder: (ctx, i) => ListTile(
                                    leading: Image.network(
                                      widget.items[i]['productImage'],
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        // Return any widget you want to be displayed instead of the network image like an asset image or an icon
                                        return const Icon(Icons.error);
                                      },
                                    ),
                                    title: Text(widget.items[i]['productName']),
                                    subtitle: Text(
                                        'Price: ${widget.items[i]['productPrice']}'),
                                    trailing: Text(
                                        'Quantity: ${widget.items[i]['productQuantity']}'),
                                  ),
                                ),
                              ),
                        // ),
                        // }),
                      ),
                      const Divider(),
                      Column(
                        children: [
                          Text(
                            'Delivery Fee: ${widget.deliveryFee}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Visibility(
                              visible: widget.isPurchase,
                              child: Text(
                                'Discount: -${widget.totalDiscount}',
                                style: const TextStyle(fontSize: 16),
                              )),
                          // Text(
                          //   widget.isPurchase
                          //       ? 'Discount: -${widget.totalDiscount}'
                          //       : '',
                          //   // style: const TextStyle(
                          //   //   fontSize: 18,
                          //   //   fontWeight: FontWeight.bold,
                          //   //   color: Colors.black,
                          //   // ),
                          // ),
                          const SizedBox(height: 10),
                          Text(
                            widget.isPurchase
                                ? 'Total  : ${(widget.total + widget.deliveryFee - widget.totalDiscount).toStringAsFixed(2)}'
                                : 'Total Payment: ${widget.items.fold(0.0, (total, item) {
                                      var itemSubtotal = item['productPrice'] *
                                          item['productQuantity'];
                                      var discountPercent =
                                          item['discount'] as int? ?? 0;
                                      var minItems =
                                          item['minItems'] as int? ?? 0;
                                      if (item['productQuantity'] >= minItems) {
                                        var discountAmount = itemSubtotal *
                                            discountPercent /
                                            100;
                                        itemSubtotal -= discountAmount;
                                      }
                                      return total + itemSubtotal;
                                    }) + widget.deliveryFee}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      StreamBuilder<bool>(
                          stream: FirebaseFirestore.instance
                              .collection('customersOrders')
                              .doc(userId)
                              .collection('orders')
                              .doc(widget.orderId)
                              .snapshots()
                              .map((snapshot) => snapshot['orderConfirmed']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            final bool orderConfirmed = snapshot.data ?? false;

                            return StreamBuilder<bool>(
                              stream: FirebaseFirestore.instance
                                  .collection('customersOrders')
                                  .doc(userId)
                                  .collection('orders')
                                  .doc(widget.orderId)
                                  .snapshots()
                                  .map(
                                      (snapshot) => snapshot['orderCancelled']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                final bool orderCancelled =
                                    snapshot.data ?? false;

                                return widget.isPurchase
                                    ? _purchaseCard(context, widget.order)
                                    : _orderStatus(
                                        orderConfirmed: orderConfirmed,
                                        orderCancelled: orderCancelled,
                                        userId: userId,
                                        orderId: widget.orderId,
                                        sellerId: widget.sellerId);
                              },
                            );
                          }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _purchaseCard(context, item) {
    try {
      CartItem cartItem = CartItem.fromMap(item);

      return Container(
        alignment: Alignment.topRight,
        child: SizedBox(
          width: 100,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(
                  color: Colors.black,
                  width: 100.0,
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: () async {
              await placeOrderSingle(context, cartItem);
              Navigator.of(context).pop();
            },
            child: const Text('Buy'),
          ),
        ),
      );
    } catch (e, stk) {
      print([e, stk]);
      return const SizedBox();
    }
  }

  getOrderItems(userId, orderId) async {
    var snapshot = FirebaseFirestore.instance
        .collection('customersOrders')
        .doc(userId)
        .collection('orders')
        .where('id', isEqualTo: orderId)
        .snapshots();
  }

  Future<void> placeOrderSingle(BuildContext context, CartItem item) async {
    try {
      await getOrderItems(this.userId, item.id);
      var sellerId = item.sellerId;
      var seller = item.sellerName;

      var userId = FirebaseAuth.instance.currentUser?.uid;
      var cartProvider = Provider.of<CartProvider>(context, listen: false);
      var productRef =
          FirebaseFirestore.instance.collection('AllProducts').doc(item.id);
      var productSnapshot = await productRef.get();

      if (!productSnapshot.exists) {
        // If the product does not exist, show a dialog and clear the cart

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Product Unavailable'),
              content: const Text(
                  'There were recent changes of your selected products. Your cart will now be cleared and please add products to the cart again.'),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

        // Clear the cart
        cartProvider.removeItem(item);

        // Stop the function execution
        return;
      }

      var orderItems = [
        {
          'productId': item.id,
          'productName': item.productName,
          'productPrice': item.price,
          'productQuantity': item.quantity,
          'productDetails': item.productDetails,
          'productImage': item.image,
        }
      ];
      // Generate a unique order ID
      var orderId = FirebaseFirestore.instance.collection('dummy').doc().id;

      var farmersRef =
          FirebaseFirestore.instance.collection('farmers').doc(sellerId);
      var orgsRef =
          FirebaseFirestore.instance.collection('organizations').doc(sellerId);

      DocumentSnapshot farmerDoc = await farmersRef.get();
      DocumentSnapshot orgDoc = await orgsRef.get();

      String sellerType;

      if (farmerDoc.exists) {
        sellerType = 'Farmer';
      } else if (orgDoc.exists) {
        sellerType = 'Organization';
      } else {
        throw 'Seller ID not found in either farmers or organizations collections';
      }

      var docRef = FirebaseFirestore.instance
          .collection('customersOrders')
          .doc(userId)
          .collection('orders')
          .doc(orderId);

      await docRef.set({
        'sellerName': seller,
        'sellerId': sellerId,
        'items': orderItems,
        'orderConfirmed': false,
        'orderCancelled': false,
        'sellerType': sellerType,
        'date': DateFormat("MMMM, dd, yyyy")
            .format(DateTime.now()), // Add this line
      });

      // Decrease the stock of each product

      DocumentReference productRef_2;
      DocumentSnapshot productSnapshot_2;

      // Try to get the product from the 'FarmerProducts' collection
      productRef_2 = FirebaseFirestore.instance
          .collection('FarmerProducts')
          .doc(sellerId)
          .collection(seller)
          .doc(item.id);
      productSnapshot_2 = await productRef_2.get();

      // If the product doesn't exist in 'FarmerProducts', get it from 'OrgProducts'
      if (!productSnapshot_2.exists) {
        productRef_2 = FirebaseFirestore.instance
            .collection('OrgProducts')
            .doc(sellerId)
            .collection(seller)
            .doc(item.id);
      }

      await productRef_2.update({
        'quantity': FieldValue.increment(-item.quantity),
      });

      // Decrease the stock of each product

      var productReff =
          FirebaseFirestore.instance.collection('AllProducts').doc(item.id);

      await productReff.update({
        'quantity': FieldValue.increment(-item.quantity),
      });

      // Send the order ID and the ordered items to the seller
      // ignore: unused_local_variable

      DocumentReference sellerRef;
      final farmerDocc = await FirebaseFirestore.instance
          .collection('farmers')
          .doc(sellerId)
          .get();
      if (farmerDocc.exists) {
        sellerRef = FirebaseFirestore.instance
            .collection('farmers')
            .doc(sellerId)
            .collection('customerOrders')
            .doc(orderId);
      } else {
        sellerRef = FirebaseFirestore.instance
            .collection('organizations')
            .doc(sellerId)
            .collection('customerOrders')
            .doc(orderId);
      }

      await sellerRef.set({
        'items': orderItems,
        'orderConfirmed': false,
        //'orderCancelled': false,
        'buyerId': userId,
        'buyerName': await getBuyerName(_auth, _firestore),
        'buyerType': await getBuyerType(_auth, _firestore),
        'date': DateFormat("MMMM, dd, yyyy").format(DateTime.now()),
      });

      cartProvider.removeItem(item);
    } catch (e, stk) {
      print(['place order', e, stk]);
      print('item');
    }
  }

  Future<String> getBuyerType(
      FirebaseAuth auth, FirebaseFirestore firestore) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc;
      // Check if the user is a customer
      userDoc = await _firestore.collection('customers').doc(user.uid).get();
      if (userDoc.exists) {
        return (userDoc.data() as Map<String, dynamic>)['role'] ?? '';
      }
      // Check if the user is a farmer
      userDoc = await _firestore.collection('farmers').doc(user.uid).get();
      if (userDoc.exists) {
        return (userDoc.data() as Map<String, dynamic>)['role'] ?? '';
      }
      // Check if the user is a organization
      userDoc =
          await _firestore.collection('organizations').doc(user.uid).get();
      if (userDoc.exists) {
        return (userDoc.data() as Map<String, dynamic>)['role'] ?? '';
      }
    }
    return '';
  }

  Future<String> getBuyerName(
      FirebaseAuth auth, FirebaseFirestore firestore) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc;
      // Check if the user is a customer
      userDoc = await _firestore.collection('customers').doc(user.uid).get();
      if (userDoc.exists) {
        return (userDoc.data() as Map<String, dynamic>)['displayName'] ?? '';
      }
      // Check if the user is a farmer
      userDoc = await _firestore.collection('farmers').doc(user.uid).get();
      if (userDoc.exists) {
        return (userDoc.data() as Map<String, dynamic>)['displayName'] ?? '';
      }
      // Check if the user is a organization
      userDoc =
          await _firestore.collection('organizations').doc(user.uid).get();
      if (userDoc.exists) {
        return (userDoc.data() as Map<String, dynamic>)['displayName'] ?? '';
      }
    }
    return '';
  }
}

class _orderStatus extends StatelessWidget {
  const _orderStatus({
    // ignore: unused_element
    super.key,
    required this.orderConfirmed,
    required this.orderCancelled,
    required this.userId,
    required this.orderId,
    required this.sellerId,
  });

  final bool orderConfirmed;
  final bool orderCancelled;
  final String userId;
  final String orderId;
  final String sellerId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          orderConfirmed
              ? const Icon(Icons.check, color: Colors.green)
              : orderCancelled
                  ? const Icon(Icons.cancel, color: Colors.red)
                  : const Icon(Icons.info_outline, color: Colors.orange),
          Text(
            orderCancelled
                ? 'Order Status: Declined Order'
                : !orderConfirmed
                    ? 'Order Status: waiting for confirmation'
                    : 'Order Status: Order Confirmed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: orderCancelled
                  ? Colors.red
                  : !orderConfirmed
                      ? Colors.orange
                      : Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          if (!orderConfirmed && !orderCancelled)
            ElevatedButton(
              onPressed: () {
                _queryToDb();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order has been cancelled.'),
                    backgroundColor: Colors.red,
                  ),
                );

                //CustomerMyOrders.routeName);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('CANCEL'),
            ),
        ],
      ),
    );
  }

  Future<void> _queryToDb() async {
    await FirebaseFirestore.instance
        .collection('customersOrders')
        .doc(userId)
        .collection('orders')
        .doc(orderId)
        .delete();

    // Here is how to delete the orderId from farmers collection
    await FirebaseFirestore.instance
        .collection('farmers')
        .doc(sellerId)
        .collection('customerOrders')
        .doc(orderId)
        .delete();
  }
}
