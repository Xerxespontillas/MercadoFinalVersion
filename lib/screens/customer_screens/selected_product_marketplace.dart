import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:photo_view/photo_view.dart';

import '../farmer_screens/models/product.dart';

import '../organization_screens/organization_screen_controller.dart';

class SelectedProductMarketplace extends StatefulWidget {
  static const routeName = '/selected-product-marketplace';

  const SelectedProductMarketplace({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SelectedProductMarketplaceState createState() =>
      _SelectedProductMarketplaceState();
}

class _SelectedProductMarketplaceState
    extends State<SelectedProductMarketplace> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String userType = '';
  late Product product;
  late TextEditingController _productNameController;
  late TextEditingController _priceController;
  late TextEditingController _productDetailsController;

  File? _image;
  late int quantity = product.quantity;

  // Firestore instance

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    product = ModalRoute.of(context)!.settings.arguments as Product;
    quantity = product.quantity;
    _productNameController = TextEditingController(text: product.productName);
    _priceController = TextEditingController(text: product.price.toString());
    _productDetailsController =
        TextEditingController(text: product.productDetails);
  }

  @override
  void initState() {
    super.initState();
    getUserType();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> getUserType() async {
    final orgDocSnapshot = await _firestore
        .collection('organizations')
        .doc(currentUser!.uid)
        .get();
    final farmerDocSnapshot =
        await _firestore.collection('farmers').doc(currentUser!.uid).get();
    final customerDocSnapshot =
        await _firestore.collection('customers').doc(currentUser!.uid).get();

    if (orgDocSnapshot.exists) {
      setState(() {
        userType = 'organization';
      });
    } else if (farmerDocSnapshot.exists) {
      setState(() {
        userType = 'farmer';
      });
    } else if (customerDocSnapshot.exists) {
      setState(() {
        userType = 'customer';
      });
    }
  }

  void showDeleteDialog(BuildContext context, String sellerId,
      String sellerName, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                CollectionReference farmerProducts =
                    FirebaseFirestore.instance.collection('FarmerProducts');
                CollectionReference orgProducts =
                    FirebaseFirestore.instance.collection('OrgProducts');
                DocumentReference allProducts = FirebaseFirestore.instance
                    .collection('AllProducts')
                    .doc(productId);

                // Delete from AllProducts
                var docSnapshot = await allProducts.get();
                if (docSnapshot.exists) {
                  await docSnapshot.reference.delete();
                } else {
                  print("Product not found in AllProducts collection");
                }

                // Check if the product exists in FarmerProducts
                docSnapshot = await farmerProducts
                    .doc(sellerId)
                    .collection(sellerName)
                    .doc(productId)
                    .get();

                if (docSnapshot.exists) {
                  // Delete the document
                  await docSnapshot.reference.delete();
                } else {
                  // Check if the product exists in OrgProducts
                  docSnapshot = await orgProducts
                      .doc(sellerId)
                      .collection(sellerName)
                      .doc(productId)
                      .get();
                  if (docSnapshot.exists) {
                    // Delete the document
                    await docSnapshot.reference.delete();
                  } else {
                    print(
                        "Product not found in either FarmerProducts or OrgProducts collection");
                  }
                }

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const OrgScreenController()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Selected Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.02), // 2% of screen width
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GestureDetector(
                    onTap: () {
                      // ignore: unnecessary_null_comparison
                      if (_image != null || product.image != null) {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: PhotoView(
                              imageProvider: _image != null
                                  ? FileImage(_image!)
                                  : NetworkImage(product.image)
                                      as ImageProvider<Object>?,
                            ),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => const Dialog(
                            child: Icon(
                              Icons.cloud_upload,
                              size: 80,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: _image == null
                          // ignore: unnecessary_null_comparison
                          ? (product.image != null
                              ? Image.network(product.image)
                              : const Icon(
                                  Icons.cloud_upload,
                                  size: 80,
                                ))
                          : Image.file(_image!),
                    ),
                  ),
                ),
              ),

              SizedBox(width: screenSize.width * 0.02), // 2% of screen width
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(
                            4.0), // Add border radius if desired
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                                8.0), // Add padding for icon spacing
                            decoration: const BoxDecoration(
                              border: Border(
                                // Add border only on the right side of the icon container
                                right: BorderSide(color: Colors.black),
                              ),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.penToSquare,
                              color: Colors.black, // Set desired icon color
                            ),
                          ),
                          SizedBox(
                              width: screenSize.width *
                                  0.01), // 1% of screen width
                          Expanded(
                            child: TextFormField(
                              controller: _productNameController,
                              decoration: const InputDecoration(
                                hintText: 'Product Name',
                                border: InputBorder
                                    .none, // Remove the default border
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal:
                                        8.0), // Adjust padding as needed
                              ),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(
                            4.0), // Add border radius if desired
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                                8.0), // Add padding for icon spacing
                            decoration: const BoxDecoration(
                              border: Border(
                                // Add border only on the right side of the icon container
                                right: BorderSide(color: Colors.black),
                              ),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.pesoSign,
                              color: Colors.black, // Set desired icon color
                            ),
                          ),
                          SizedBox(
                              width: screenSize.width *
                                  0.01), // 1% of screen width
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType
                                  .number, // Set the keyboard type to number
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter
                                    .digitsOnly, // Allow only digits (numbers)
                              ],
                              decoration: const InputDecoration(
                                hintText: 'Price',
                              ),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(
                            4.0), // Add border radius if desired
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                                8.0), // Add padding for icon spacing
                            decoration: const BoxDecoration(
                              border: Border(
                                // Add border only on the right side of the icon container
                                right: BorderSide(color: Colors.black),
                              ),
                            ),
                            child: const Icon(
                              Icons
                                  .shopping_cart, // Replace with the desired icon
                              color: Colors.black, // Set desired icon color
                            ),
                          ),
                          SizedBox(
                              width: screenSize.width *
                                  0.03), // 1% of screen width
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.02), // 2% of screen height
// Product details text field
          Expanded(
            child: TextField(
              controller: _productDetailsController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Enter Product details',
              ),
              readOnly: true,
            ),
          ),
          SizedBox(height: screenSize.height * 0.02), // 2% of screen height

          if (userType == 'organization') ...[
            SizedBox(height: screenSize.height * 0.02),
            ElevatedButton(
              onPressed: () {
                showDeleteDialog(
                    context, product.sellerId, product.sellerName, product.id);
              },
              child: const Text('Delete'),
            ),
          ],
        ]),
      ),
    );
  }
}
