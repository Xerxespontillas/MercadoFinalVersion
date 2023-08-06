import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/farmer_screens/models/product.dart';
import '../providers/auth_provider.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class FarmerProducts with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  Future<String> getSellerName(
      FirebaseAuth auth, FirebaseFirestore firestore) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('farmers').doc(user.uid).get();
      return (userDoc.data() as Map<String, dynamic>)['displayName'] ?? '';
    } else {
      return '';
    }
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

    String displayName = await getSellerName(_auth, _firestore);

    await FirebaseFirestore.instance
        .collection('FarmerProducts')
        .doc(userId)
        .collection(displayName)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        print(doc);
        loadedProducts.add(Product(
          productSeller: doc['productSeller'],
          id: doc.id,
          productName: doc['productName'],
          productDetails: doc['productDetails'],
          image: doc['image'],
          price: doc['price'],
          quantity: doc['quantity'],
          maxQuantity: doc['quantity'],
          sellerName: doc['sellerName'],
          sellerId: doc['sellerUserId'],
          minItems: doc['minItems'],
          discount: doc['discount'],
        ));
      }
    });

    _items = loadedProducts;
    notifyListeners();
  }
}
