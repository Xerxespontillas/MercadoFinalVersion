import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Organization {
  final String orgName;
  final String address;

  Organization({
    required this.orgName,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'organizationName': orgName,
      'address': address,
    };
  }
}

class OrganizationProvider extends ChangeNotifier {
  String _currentOrgDocId = '';

  String get currentOrgDocId => _currentOrgDocId;

  set currentBusDocId(String value) {
    _currentOrgDocId = value;
    notifyListeners();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final CollectionReference<Map<String, dynamic>> organizationCollection =
      FirebaseFirestore.instance.collection('organizations');

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  OrganizationProvider() {
    authProviderOrganization();
  }

  authProviderOrganization() {
    // Check if the user is already authenticated when the app starts up
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _isAuthenticated = user != null;
      if (_isAuthenticated) {
        // Fetch current organization data from Firestore for the authenticated user
        DocumentSnapshot<Map<String, dynamic>> organizationSnapshot =
            await organizationCollection.doc(user!.uid).get();

        if (organizationSnapshot.exists) {
          Map<String, dynamic> organizationData = organizationSnapshot.data()!;
          _currentOrganization = Organization(
              orgName: organizationData['organizationName'],
              address: organizationData['address']);
        }
      } else {
        _currentOrganization = null;
      }
      notifyListeners();
    });
  }

  Future<Organization?> getCurrentorganization() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> organizationSnapshot =
          await organizationCollection.doc(user.uid).get();

      if (organizationSnapshot.exists) {
        Map<String, dynamic> organizationData = organizationSnapshot.data()!;
        _currentOrganization = Organization(
            orgName: organizationData['organizationName'],
            address: organizationData['address']);
        return _currentOrganization;
      }
    }
    return null;
  }

  Organization? _currentOrganization;
  Organization? get currentOrganization => _currentOrganization;
  void setCurrentorganization(Organization? organization) {
    _currentOrganization = organization;
    notifyListeners();
  }

  Future<void> addorganization(Organization organization, String uid) async {
    await organizationCollection.doc(uid).set(organization.toMap());
    notifyListeners();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
