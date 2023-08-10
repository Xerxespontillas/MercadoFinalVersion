// ignore_for_file: unused_field

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:merkado/providers/organization_products_provider.dart';
import 'package:merkado/screens/organization_screens/org_completed_orders.dart';
import 'package:merkado/screens/organization_screens/org_farmer_add_products.dart';

import 'package:provider/provider.dart';

class OrgFarmerProfile extends StatefulWidget {
  final Map<String, dynamic> farmerData;

  const OrgFarmerProfile({super.key, required this.farmerData});
  static const routeName = '/org-farmer-profile';

  @override
  State<OrgFarmerProfile> createState() => _OrgFarmerProfileState();
}

class _OrgFarmerProfileState extends State<OrgFarmerProfile> {
  TextEditingController? _displayNameController;
  TextEditingController? _phoneNumberController;
  TextEditingController? _addressController;

  String? _displayName;
  String? _phoneNumber;
  String? _address;

  String? _profilePictureUrl;
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
    _displayNameController = TextEditingController(
      text: widget.farmerData["displayName"],
    );
    _phoneNumberController = TextEditingController(
      text: widget.farmerData["phoneNumber"],
    );
    _addressController = TextEditingController(
      text: widget.farmerData["address"],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _displayNameController?.dispose();
    _phoneNumberController?.dispose();
    _addressController?.dispose();
  }

  Future<void> _updateFarmerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case when the user is not authenticated
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User is not authenticated."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;

    try {
      await firestore
          .collection("organizations")
          .doc(user.uid)
          .collection("OrgAddFarmers")
          .doc(widget.farmerData[
              "docId"]) // Assuming you have a field named "docId" in the farmerData map to uniquely identify the farmer document
          .update({
        "displayName": _displayNameController?.text ?? "",
        "phoneNumber": _phoneNumberController?.text ?? "",
        "address": _addressController?.text ?? "",
        // Add other fields you want to update
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Farmer data updated successfully!"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Handle errors, e.g., network errors, permissions, etc.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error updating farmer data."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<OrganizationProducts>(context);
    final products = productsData.items;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(0, 66, 180, 119),
        centerTitle: true,
        title: Text(
          widget.farmerData["displayName"] ?? "Unknown",
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black, size: 30),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
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
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                    child: Row(
                      children: [
                        const Text(
                          "Address:   ",
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
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                    child: Row(
                      children: [
                        const Text(
                          "Phone Number: ",
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
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        _updateFarmerData, // Call the function to update the farmer's data
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
                        "Update Details",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      OrgFarmerAddProducts.routeName,
                      arguments:
                          widget.farmerData, // Use widget.farmerData here
                    );
                  },
                  icon: const Icon(
                    Icons.add_business_rounded,
                    size: 40,
                  ),
                ),
                const Text(
                  'All Products',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Inter',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      OrgFarmerCompletedOrders.routeName,
                      arguments: widget.farmerData[
                          "displayName"], // Pass the displayName as arguments
                    );
                  },
                  icon: const Icon(
                    Icons.list_alt,
                    size: 40,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (ctx, i) {
                  // Check if the product belongs to the current farmer using sellerName
                  if (products[i].productSeller ==
                      widget.farmerData["displayName"]) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/organization-my-edit-products',
                              arguments: products[i],
                            );
                          },
                          child: ListTile(
                            leading: Image.network(
                              products[i].image,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                // Return any widget you want to be displayed instead of the network image like an asset image or an icon
                                return const Icon(Icons.shopping_bag);
                              },
                            ),
                            title: Text(products[i].productName),
                            subtitle: Text(products[i].productDetails),
                            trailing:
                                Text("Php.${products[i].price.toString()}"),
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  } else {
                    // Return an empty container if the product doesn't belong to the current farmer
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
