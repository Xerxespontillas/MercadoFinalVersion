import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../farmer_screens/models/product.dart';
import 'customer_drawer_screens/customer_selected_order.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';

  const CartScreen({super.key});

  void placeOrder(BuildContext context) async {
    var cartProvider = Provider.of<CartProvider>(context, listen: false);
    var itemsBySeller = cartProvider.itemsBySeller;
    // Get the logged-in user's ID
    var userId = FirebaseAuth.instance.currentUser?.uid;

    for (var seller in itemsBySeller.keys) {
      var sellerData = itemsBySeller[seller]!;
      var items = sellerData['items'] as List<CartItem>;
      var sellerId = sellerData['sellerId'] as String;

      for (var item in items) {
        // Check if the product exists in the Firestore database
        var productRef =
            FirebaseFirestore.instance.collection('AllProducts').doc(item.id);
        var productSnapshot = await productRef.get();

        if (!productSnapshot.exists) {
          // If the product does not exist, show a dialog and clear the cart
          // ignore: use_build_context_synchronously
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
          cartProvider.clearCart();

          // Stop the function execution
          return;
        }
      }

      var orderItems = items
          .map((item) => {
                'productId': item.id,
                'productSeller': item.productSeller!,
                'productName': item.productName,
                'productPrice': item.price,
                'productQuantity': item.quantity,
                'productDetails': item.productDetails,
                'productImage': item.image,
                'discount': item.discount,
                'minItems': item.minItems,
              })
          .toList();

      // Generate a unique order ID
      var orderId = FirebaseFirestore.instance.collection('dummy').doc().id;

      var farmersRef =
          FirebaseFirestore.instance.collection('farmers').doc(sellerId);
      var orgsRef =
          FirebaseFirestore.instance.collection('organizations').doc(sellerId);

      DocumentSnapshot farmerDoc = await farmersRef.get();
      DocumentSnapshot orgDoc = await orgsRef.get();

      String sellerType;
      // String buyerType;

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
      for (var item in items) {
        DocumentReference productRef;
        DocumentSnapshot productSnapshot;

        // Try to get the product from the 'FarmerProducts' collection
        productRef = FirebaseFirestore.instance
            .collection('FarmerProducts')
            .doc(sellerId)
            .collection(seller)
            .doc(item.id);
        productSnapshot = await productRef.get();

        // If the product doesn't exist in 'FarmerProducts', get it from 'OrgProducts'
        if (!productSnapshot.exists) {
          productRef = FirebaseFirestore.instance
              .collection('OrgProducts')
              .doc(sellerId)
              .collection(seller)
              .doc(item.id);
        }

        await productRef.update({
          'quantity': FieldValue.increment(-item.quantity),
        });
      }

      // Decrease the stock of each product
      for (var item in items) {
        var productRef =
            FirebaseFirestore.instance.collection('AllProducts').doc(item.id);

        await productRef.update({
          'quantity': FieldValue.increment(-item.quantity),
        });
      }

      // Send the order ID and the ordered items to the seller
      // ignore: unused_local_variable
      for (var item in items) {
        DocumentReference sellerRef;
        final farmerDoc = await FirebaseFirestore.instance
            .collection('farmers')
            .doc(sellerId)
            .get();
        if (farmerDoc.exists) {
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
      }
    }

    // Clear the cart after placing the order
    cartProvider.clearCart();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black, // Set the color of the back icon to black
        ),
        title: const Text('Your Cart',
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text(
                        'Do you want to clear the items in your cart?'),
                    actions: <Widget>[
                      ElevatedButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Yes'),
                        onPressed: () {
                          Provider.of<CartProvider>(context, listen: false)
                              .clearCart();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (ctx, cartProvider, _) {
          if (cartProvider.itemCount == 0) {
            return const Center(
              child: Text(
                "No added products, Choose a product in the marketplace",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          var cartItems = cartProvider.cartItems;
          var itemsBySeller = cartProvider.itemsBySeller;

          // Calculate the total for all sellers
          var discountAmount = 0.0;
          double grandTotal =
              itemsBySeller.values.fold(0.0, (total, sellerData) {
            var items = sellerData['items'] as List<CartItem>;
            var subtotal = 0.0;
            if (items.isNotEmpty) {
              subtotal = items.fold(0.0, (itemTotal, item) {
                var itemSubtotal = item.price * item.quantity;
                var discountPercent = int.parse(item.discount);
                var minItems = int.parse(item.minItems);
                if (item.quantity >= minItems) {
                  discountAmount = itemSubtotal * discountPercent / 100;
                  itemSubtotal -= discountAmount;
                }
                return itemTotal + itemSubtotal;
              });
            }
            var deliveryFee = 0.0; // PHP 50 delivery fee per seller
            return total + subtotal + deliveryFee;
          });

          return Column(
            children: [
              // List of cart items
              Expanded(
                flex: 6,
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (ctx, i) {
                    var cartItemObject = cartItems.values.toList()[i];
                    var deliveryFee = 0.0; // Assuming a fixed delivery feer
                    return InkWell(
                      onTap: () {
                        var cartItem =
                            CartItem.toMap(cartItems.values.toList()[i]);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CustomerSelectedOrder(
                                order: cartItem,
                                items: const [],
                                deliveryFee: deliveryFee,
                                sellerId: cartItem['sellerId'] ?? 'id',
                                orderDate: cartItem['date'] ??
                                    DateTime.now().toIso8601String(),
                                orderConfirmed:
                                    cartItem['orderConfirmed'] ?? false,
                                isPurchase: true,
                                totalDiscount: discountAmount,
                                image: cartItemObject.image,
                                total: (cartItemObject.price *
                                    cartItemObject.quantity),

                                //orderCancelled: orderCancelled,
                                orderId: cartItem['id']),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(cartItemObject.image),
                            backgroundColor: Colors.transparent,
                          ),
                          title: Text(cartItemObject.productName),
                          subtitle: Text(
                              'Total: Php.${(cartItemObject.price * cartItemObject.quantity).toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (cartItemObject.quantity == 1) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Remove Item'),
                                          content: const Text(
                                              'Do you want to remove this item from the cart?'),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              child: const Text('No'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            ElevatedButton(
                                              child: const Text('Yes'),
                                              onPressed: () {
                                                cartProvider.removeItemQuantity(
                                                    cartItemObject.id);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    cartProvider
                                        .removeItemQuantity(cartItemObject.id);
                                  }
                                },
                              ),
                              Text('${cartItemObject.quantity} x'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  cartProvider.addItemQuantity(
                                      cartItemObject.id, context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Cart Summary
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'Cart Summary',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: itemsBySeller.keys.length,
                        itemBuilder: (ctx, i) {
                          var seller = itemsBySeller.keys.toList()[i];
                          var sellerData = itemsBySeller[seller]!;
                          var items = sellerData['items'] as List<CartItem>;
                          // print([
                          //   seller,
                          //   sellerData['discount'],
                          //   items[0].discount,
                          //   'asdfasd'
                          // ]);
                          var subtotalBeforeDiscount = items.fold(
                              0.0,
                              (total, item) =>
                                  total + item.price * item.quantity);

                          var subtotal = subtotalBeforeDiscount;
                          var deliveryFee =
                              0.0; // PHP 50 delivery fee per seller
                          var discountPercent = int.parse(items[0].discount);
                          var minItems = int.parse(items[0].minItems);
                          double discountAmount = 0.0;

                          if (items[0].quantity >= minItems) {
                            discountAmount = subtotal * discountPercent / 100;
                            subtotal -= discountAmount;
                          }
                          grandTotal += subtotal;

                          if (subtotal < 0) {
                            subtotal = 0;
                          }
                          print('adsf: adsf');
                          return Card(
                            margin: const EdgeInsets.all(5),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Seller Name: $seller',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),

                                  // Your item list here
                                  const Divider(),
                                  Text(
                                    'Subtotal: Php.${subtotalBeforeDiscount.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    'Delivery Fee: Php.$deliveryFee',
                                    style: const TextStyle(fontSize: 10),
                                  ),

                                  Text(
                                    (discountAmount < 0)
                                        ? 'Discount:  None'
                                        : 'Discount:  -Php $discountAmount',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  const Divider(),
                                  Text(
                                    'Total: Php.${(subtotal + deliveryFee).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      child: Text(
                        'Grand Total: Php.${grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 5.0,
                                ),
                              ),
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 0, 0),
                            ),
                            onPressed: () {
                              placeOrder(context);
                            },
                            child: const Text('Place Order'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
