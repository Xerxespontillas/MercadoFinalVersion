import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../authentication/user/login_screen.dart';

class OrgSettingsScreen extends StatefulWidget {
  const OrgSettingsScreen({super.key});
  static const routeName = '/org-edit-profile';

  @override
  State<OrgSettingsScreen> createState() => _OrgSettingsScreenState();
}

late ConnectivityResult _connectivityResult;

class _OrgSettingsScreenState extends State<OrgSettingsScreen> {
  TextEditingController? _displayNameController;
  TextEditingController? _phoneNumberController;
  TextEditingController? _addressController;

  String? _displayName;
  String? _phoneNumber;
  String? _address;

  Future<DocumentSnapshot> fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return await FirebaseFirestore.instance
          .collection('organizations')
          .doc(currentUser.uid)
          .get();
    }
    throw Exception('User not logged in');
  }

  void updateData() {
    fetchUserData().then((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _displayName = userData['displayName'];
          _phoneNumber = userData['phoneNumber'];
          _address = userData['address'];

          // Set the text editing controllers to the current values

          _displayNameController?.text = _displayName!;
          _phoneNumberController?.text = _phoneNumber!;
          _addressController?.text = _address!;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize the text editing controllers
    _displayNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();

    // Fetch the user data and update the state variables
    updateData();

    Connectivity().checkConnectivity().then((result) {
      setState(() {
        _connectivityResult = result;
        if (_connectivityResult == ConnectivityResult.none) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("No Internet Connection"),
                content: const Text(
                    "Please check your internet connection and try again."),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
        }
      });
    });
  }

  void _updateProfile() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('organizations')
            .doc(currentUser.uid)
            .update({
          'displayName': _displayNameController?.text.trim(),
          'phoneNumber': _phoneNumberController?.text.trim(),
          'address': _addressController?.text.trim(),
        });
        // Update the displayName field in Firebase Authentication
        await currentUser
            .updateDisplayName(_displayNameController?.text.trim() ?? '');
        // Reload the user object after updating the profile
        await currentUser.reload();
        // Call updateData() to reflect the updated profile data in the local state variables
        updateData();
      } catch (e) {
        // Show an error message if there was a problem updating the profile data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${e.toString()}')),
        );
      }
    }
  }

  Future<String?> _showPasswordDialog() {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Verify Identity')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please verify your identiy by entering your current password before making changes to your account.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 15),
              TextFormField(
                obscureText: true,
                controller: controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Your Password is required';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String password = controller.text;
                User? currentUser = FirebaseAuth.instance.currentUser;

                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Please enter your password to save changes.')),
                  );
                  return;
                }

                if (currentUser != null) {
                  AuthCredential credential = EmailAuthProvider.credential(
                      email: currentUser.email!, password: password);

                  try {
                    await currentUser.reauthenticateWithCredential(credential);
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop(password);
                  } catch (e) {
                    // Show error message if reauthentication fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incorrect password')),
                    );
                  }
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _displayNameController?.dispose();
    _phoneNumberController?.dispose();
    _addressController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      ElevatedButton(
                        child: const Text('Logout'),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          // ignore: use_build_context_synchronously
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            LoginScreen.routeName,
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.logout_outlined,
              size: 20,
            ),
          ),
        ],
      ),
      body: Center(
          child: Column(
        children: [
          TextFormField(
            controller: _displayNameController,
            onChanged: (value) {
              setState(() {
                _displayName = value;
              });
            },
          ),
          TextFormField(
            controller: _phoneNumberController,
            onChanged: (value) {
              setState(() {
                _phoneNumber = value;
              });
            },
          ),
          TextFormField(
            controller: _addressController,
            onChanged: (value) {
              setState(() {
                _address = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              // Get the current user
              User? currentUser = FirebaseAuth.instance.currentUser;

              _showPasswordDialog().then((password) {
                if (password != null) {
                  AuthCredential credential = EmailAuthProvider.credential(
                      email: currentUser?.email ?? '', password: password);
                  currentUser
                      ?.reauthenticateWithCredential(credential)
                      .then((_) {
                    // If the user entered the correct password, update the profile
                    _updateProfile();
                    updateData();

                    // Show a snackbar message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated')),
                    );
                  });
                }
              });
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20), // Set the desired radius here
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(60, 15, 60, 15),
              child: Text(
                "Save",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
