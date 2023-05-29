import 'package:flutter/material.dart';

import '../screens/farmer_screens/models/product.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _cartItems = {};

  Map<String, CartItem> get cartItems {
    return {..._cartItems};
  }

  int get cartItemCount {
    return _cartItems.length;
  }

  int get itemCount {
    return _cartItems.length;
  }

  void clearCart() {
    _cartItems = {};
    notifyListeners();
  }

  Map<String, Map<String, dynamic>> get itemsBySeller {
    final Map<String, Map<String, dynamic>> itemsBySeller = {};

    for (var cartItem in _cartItems.values) {
      if (itemsBySeller.containsKey(cartItem.sellerName)) {
        itemsBySeller[cartItem.sellerName]!['items'].add(cartItem);
      } else {
        itemsBySeller[cartItem.sellerName] = {
          'sellerId': cartItem.sellerId,
          'items': [cartItem],
        };
      }
    }

    return itemsBySeller;
  }

  void addItemQuantity(String productId, BuildContext context) {
    final cartItem = _cartItems[productId];
    if (cartItem != null && cartItem.quantity < cartItem.maxQuantity) {
      _cartItems[productId]!.quantity++;
    } else {
      _showNoStockDialog(context);
    }
    notifyListeners();
  }

  void _showNoStockDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Out of Stock'),
          content: const Text('There are no more stocks for this item.'),
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
  }

  void removeItemQuantity(String productId) {
    if (_cartItems[productId]!.quantity > 1) {
      _cartItems[productId]!.quantity--;
    } else {
      _cartItems.remove(productId);
    }
    notifyListeners();
  }

  void addItem(Product product, BuildContext context) {
    if (_cartItems.containsKey(product.id)) {
      if (_cartItems[product.id]!.quantity <
          _cartItems[product.id]!.maxQuantity) {
        _cartItems.update(
          product.id,
          (existingCartItem) => CartItem(
            id: existingCartItem.id,
            productName: existingCartItem.productName,
            productDetails: existingCartItem.productDetails,
            price: existingCartItem.price,
            quantity: existingCartItem.quantity + 1,
            maxQuantity: existingCartItem.maxQuantity,
            sellerName: existingCartItem.sellerName,
            sellerId: existingCartItem.sellerId,
            image: existingCartItem.image,
          ),
        );
      } else {
        _showNoStockDialog(context);
      }
    } else {
      _cartItems.putIfAbsent(
        product.id,
        () => CartItem(
          id: product.id,
          productName: product.productName,
          productDetails: product.productDetails,
          price: product.price,
          quantity: 1,
          maxQuantity: product.maxQuantity,
          sellerName: product.sellerName,
          sellerId: product.sellerId,
          image: product.image,
        ),
      );
    }
    notifyListeners();
  }
}
