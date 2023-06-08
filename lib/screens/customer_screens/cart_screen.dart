import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../farmer_screens/models/product.dart';

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
                'productName': item.productName,
                'productPrice': item.price,
                'productQuantity': item.quantity,
                'productDetails': item.productDetails,
                'productImage': item.image,
              })
          .toList();

      // Generate a unique order ID
      var orderId = FirebaseFirestore.instance.collection('dummy').doc().id;

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
      });

      // Decrease the stock of each product
      for (var item in items) {
        var productRef = FirebaseFirestore.instance
            .collection('FarmerProducts')
            .doc(sellerId)
            .collection(seller)
            .doc(item.id);

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
      for (var item in items) {
        var sellerRef = FirebaseFirestore.instance
            .collection('farmers')
            .doc(sellerId)
            .collection('customerOrders')
            .doc(orderId);

        await sellerRef.set({
          'items': orderItems,
          'orderConfirmed': false,
          'buyerId': userId,
          'buyerName': await getBuyerName(_auth, _firestore),
        });
      }
    }

    // Clear the cart after placing the order
    cartProvider.clearCart();
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
          double grandTotal =
              itemsBySeller.values.fold(0.0, (total, sellerData) {
            var items = sellerData['items'] as List<CartItem>;
            var subtotal = items.fold(0.0,
                (itemTotal, item) => itemTotal + item.price * item.quantity);
            var deliveryFee = 50.0; // PHP 50 delivery fee per seller
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
                    var cartItem = cartItems.values.toList()[i];

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(cartItem.image),
                          backgroundColor: Colors.transparent,
                        ),
                        title: Text(cartItem.productName),
                        subtitle: Text(
                            'Total: Php.${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (cartItem.quantity == 1) {
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
                                                  cartItem.id);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  cartProvider.removeItemQuantity(cartItem.id);
                                }
                              },
                            ),
                            Text('${cartItem.quantity} x'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cartProvider.addItemQuantity(
                                    cartItem.id, context);
                              },
                            ),
                          ],
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
                          var subtotal = items.fold(
                              0.0,
                              (total, item) =>
                                  total + item.price * item.quantity);
                          var deliveryFee =
                              50.0; // PHP 50 delivery fee per seller

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
                                    'Subtotal: Php.${subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    'Delivery Fee: Php.$deliveryFee',
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
