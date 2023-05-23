import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Customer {
  final String name;

  Customer({
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'displayName': name,
    };
  }
}

class CustomersProvider extends ChangeNotifier {
  String _currentCustomerDocId = '';

  String get currentCustomerDocId => _currentCustomerDocId;

  set currentCustomerDocId(String value) {
    _currentCustomerDocId = value;
    notifyListeners();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final CollectionReference<Map<String, dynamic>> customersCollection =
      FirebaseFirestore.instance.collection('customers');

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  customersProvider() {
    authProviderCustomers();
  }

  authProviderCustomers() {
    // Check if the user is already authenticated when the app starts up
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _isAuthenticated = user != null;
      if (_isAuthenticated) {
        // Fetch current farmers data from Firestore for the authenticated user
        DocumentSnapshot<Map<String, dynamic>> customersSnapshot =
            await customersCollection.doc(user!.uid).get();

        if (customersSnapshot.exists) {
          Map<String, dynamic> farmersData = customersSnapshot.data()!;
          _currentCustomers = Customer(
            name: farmersData['displayName'],
          );
        }
      } else {
        _currentCustomers = null;
      }
      notifyListeners();
    });
  }

  Future<Customer?> getCurrentCustomers() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> farmersSnapshot =
          await customersCollection.doc(user.uid).get();

      if (farmersSnapshot.exists) {
        Map<String, dynamic> farmersData = farmersSnapshot.data()!;
        _currentCustomers = Customer(
          name: farmersData['displayName'],
        );

        return _currentCustomers;
      }
    }
    return null;
  }

  Customer? _currentCustomers;
  Customer? get currentCustomers => _currentCustomers;
  void setCurrentCustomers(Customer? customers) {
    _currentCustomers = customers;
    notifyListeners();
  }

  Future<void> addFarmers(Customer farmers, String uid) async {
    await customersCollection.doc(uid).set(farmers.toMap());
    notifyListeners();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
