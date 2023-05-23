import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Farmers {
  final String fullName;
  final String address;

  Farmers({
    required this.fullName,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'displayName': fullName,
      'address': address,
    };
  }
}

class FarmersProvider extends ChangeNotifier {
  String _currentFarmerDocId = '';

  String get currentFarmerDocId => _currentFarmerDocId;

  set currentFarmersDocId(String value) {
    _currentFarmerDocId = value;
    notifyListeners();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final CollectionReference<Map<String, dynamic>> farmersCollection =
      FirebaseFirestore.instance.collection('farmers');

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  FarmersProvider() {
    authProviderFarmers();
  }

  authProviderFarmers() {
    // Check if the user is already authenticated when the app starts up
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _isAuthenticated = user != null;
      if (_isAuthenticated) {
        // Fetch current farmers data from Firestore for the authenticated user
        DocumentSnapshot<Map<String, dynamic>> farmersSnapshot =
            await farmersCollection.doc(user!.uid).get();

        if (farmersSnapshot.exists) {
          Map<String, dynamic> farmersData = farmersSnapshot.data()!;
          _currentFarmers = Farmers(
              fullName: farmersData['displayName'],
              address: farmersData['address']);
        }
      } else {
        _currentFarmers = null;
      }
      notifyListeners();
    });
  }

  Future<Farmers?> getCurrentFarmers() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> farmersSnapshot =
          await farmersCollection.doc(user.uid).get();

      if (farmersSnapshot.exists) {
        Map<String, dynamic> farmersData = farmersSnapshot.data()!;
        _currentFarmers = Farmers(
            fullName: farmersData['displayName'],
            address: farmersData['address']);
        return _currentFarmers;
      }
    }
    return null;
  }

  Farmers? _currentFarmers;
  Farmers? get currentFarmers => _currentFarmers;
  void setCurrentFarmers(Farmers? farmers) {
    _currentFarmers = farmers;
    notifyListeners();
  }

  Future<void> addFarmers(Farmers farmers, String uid) async {
    await farmersCollection.doc(uid).set(farmers.toMap());
    notifyListeners();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
