import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/farmer_screens/models/product.dart';
import '../providers/auth_provider.dart';

class CustomerOrderedProducts with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  Future<void> fetchProducts() async {
    final List<Product> loadedProducts = [];

    // Get the logged in user from the AuthProvider
    User? user = AuthProvider().getCurrentUser();

    if (user == null) {
      return;
    }

    // Get the id of the logged in user
    String userId = user.uid;

    await FirebaseFirestore.instance
        .collection('customersOrders')
        .doc(userId)
        .collection('orders')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        loadedProducts.add(Product(
          id: doc.id,
          productName: doc['productName'],
          productDetails: doc['productDetails'],
          image: doc['image'],
          price: doc['price'],
          quantity: doc['quantity'],
          maxQuantity: doc['quantity'],
          sellerName: doc['sellerName'],
          sellerId: doc['sellerUserId'],
          discount: doc['discount'],
          minItems: doc['minItems'],
        ));
      }
    });

    _items = loadedProducts;
    notifyListeners();
  }
}
