import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Clear Cart'),
                    content:
                        Text('Do you want to clear the items in your cart?'),
                    actions: <Widget>[
                      ElevatedButton(
                        child: Text('No'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: Text('Yes'),
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
            return Center(
              child: Text(
                "No added products, Choose a product in the marketplace",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          var cartItems = cartProvider.cartItems;
          var itemsBySeller = cartProvider.itemsBySeller;

          // Calculate total price for all cart items
          double totalPrice = cartItems.values
              .map((item) => item.price * item.quantity)
              .reduce((value, element) => value + element);

          // Calculate the total for all sellers
          double grandTotal = itemsBySeller.values.fold(0.0, (total, items) {
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
                      margin: EdgeInsets.all(8),
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
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                if (cartItem.quantity == 1) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Remove Item'),
                                        content: Text(
                                            'Do you want to remove this item from the cart?'),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            child: Text('No'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          ElevatedButton(
                                            child: Text('Yes'),
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
                              icon: Icon(Icons.add),
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
                    Padding(
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
                          var items = itemsBySeller[seller]!;
                          var subtotal = items.fold(
                              0.0,
                              (total, item) =>
                                  total + item.price * item.quantity);
                          var deliveryFee =
                              50.0; // PHP 50 delivery fee per seller

                          return Card(
                            margin: EdgeInsets.all(5),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Seller Name: $seller',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),

                                  // Your item list here
                                  Divider(),
                                  Text(
                                    'Subtotal: Php.${subtotal.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    'Delivery Fee: Php.$deliveryFee',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Divider(),
                                  Text(
                                    'Total: Php.${(subtotal + deliveryFee).toStringAsFixed(2)}',
                                    style: TextStyle(
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
                      padding: EdgeInsets.symmetric(vertical: 1.0),
                      child: Text(
                        'Grand Total: Php.${grandTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Implement your function here
                            },
                            child: Text('Place Order'),
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
