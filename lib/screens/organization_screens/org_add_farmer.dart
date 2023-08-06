import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class OrgAddFarmer extends StatefulWidget {
  const OrgAddFarmer({Key? key}) : super(key: key);
  static const routeName = '/add-farmer-screen';

  @override
  State<OrgAddFarmer> createState() => _OrgAddFarmerState();
}

class _OrgAddFarmerState extends State<OrgAddFarmer> {
  TextEditingController? _displayNameController;
  TextEditingController? _phoneNumberController;
  TextEditingController? _addressController;

  String? _displayName;
  String? _phoneNumber;
  String? _address;

  String? _profilePictureUrl;
  // ignore: unused_field
  File? _profilePicture;

  Future<void> _pickImage() async {
    final pickedImageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    setState(() {
      _profilePicture = File(pickedImageFile!.path);
    });
  }

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _displayNameController?.dispose();
    _phoneNumberController?.dispose();
    _addressController?.dispose();
  }

  void _showConfirmationSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Farmer added successfully!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _addFarmerDataToFirestore() async {
    final firestore = FirebaseFirestore.instance;

    // Get the current user's UID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case when the user is not authenticated
      return;
    }

    // Create a reference to the "OrgAddFarmers" collection under the user's UID
    final userCollectionRef = firestore
        .collection("organizations")
        .doc(user.uid)
        .collection("OrgAddFarmers");

    // Add the farmer data to the "OrgAddFarmers" collection
    await userCollectionRef.add({
      "displayName": _displayName,
      "phoneNumber": _phoneNumber,
      "address": _address,
      // Add other fields here
    });

    _showConfirmationSnackbar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 30,
        ),
        title: const Text(
          'Add Farmer',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Inter',
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 80, 0, 10),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.black,
                child: _profilePictureUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          _profilePictureUrl!,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return const Icon(Icons.person);
                          },
                          width: 100,
                          height: 100,
                          fit: BoxFit.fill,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(50),
                        ),
                        width: 100,
                        height: 100,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(
                      color: Colors.black,
                      width: 5.0,
                    ),
                  ),
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                ),
                child: const Text('Choose profile picture'),
              ),
              Row(
                children: [
                  const Text(
                    'Name:                  ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _displayNameController,
                      onChanged: (value) {
                        setState(() {
                          _displayName = value;
                        });
                      },
                      decoration: const InputDecoration(
                        suffixIcon: Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Address:             ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _addressController,
                      onChanged: (value) {
                        setState(() {
                          _address = value;
                        });
                      },
                      decoration: const InputDecoration(
                        suffixIcon: Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Cell Number:    ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneNumberController,
                      onChanged: (value) {
                        setState(() {
                          _phoneNumber = value;
                        });
                      },
                      decoration: const InputDecoration(
                        suffixIcon: Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addFarmerDataToFirestore,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(
                      color: Colors.green,
                      width: 5.0,
                    ),
                  ),
                  backgroundColor: Colors.green,
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(60, 15, 60, 15),
                  child: Text(
                    "Add Farmer",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(
                      color: Colors.red,
                      width: 5.0,
                    ),
                  ),
                  backgroundColor: Colors.red,
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(70, 15, 70, 15),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
