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

          return ListView.builder(
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
                                        cartProvider
                                            .removeItemQuantity(cartItem.id);
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
                          cartProvider.addItemQuantity(cartItem.id, context);
                        },
                      ),
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
