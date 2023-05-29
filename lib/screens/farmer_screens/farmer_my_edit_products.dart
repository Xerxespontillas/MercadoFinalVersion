import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'farmer_screen_controller.dart';
import 'models/product.dart';

class FarmerMyEditProducts extends StatefulWidget {
  static const routeName = '/farmer-my-edit-products';

  const FarmerMyEditProducts({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FarmerMyEditProductsState createState() => _FarmerMyEditProductsState();
}

class _FarmerMyEditProductsState extends State<FarmerMyEditProducts> {
  late Product product;
  late TextEditingController _productNameController;
  late TextEditingController _priceController;
  late TextEditingController _productDetailsController;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  late int quantity = product.quantity;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  void increaseQuantity() {
    setState(() {
      quantity += 1;
    });
  }

  void decreaseQuantity() {
    if (quantity > 0) {
      setState(() {
        quantity -= 1;
      });
    }
  }

  Future<void> deleteProductFromFarmerProducts(
      String productId, FirebaseAuth auth, FirebaseFirestore firestore) async {
    User? user = auth.currentUser;
    if (user != null) {
      String displayName = await getSellerName(auth, _firestore);
      await _firestore
          .collection('FarmerProducts')
          .doc(user.uid)
          .collection(displayName)
          .doc(productId)
          .delete();
    }
  }

  void _deleteProductFromDatabase(Product productToDelete) async {
    // Get a reference to the Firestore database
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Delete the product document from the 'AllProducts' collection
    await firestore.collection('AllProducts').doc(productToDelete.id).delete();

    // Delete the product document from the 'FarmerProducts' collection
    await deleteProductFromFarmerProducts(
        productToDelete.id, _auth, _firestore);

    // Check if the State object is still mounted before showing the SnackBar or navigating to a different screen
    if (mounted) {
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );

      // Navigate back to the previous screen
      Navigator.of(context).pop();
    }
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

  Future<void> _updateProductInDatabaseWithImage(
      Product productToUpdate) async {
    setState(() {});

    String productName = _productNameController.text;
    String productDetails = _productDetailsController.text;
    double price = double.parse(_priceController.text);

    // Create a map of the data we want to upload
    Map<String, dynamic> data = {
      "productName": productName,
      "productDetails": productDetails,
      "price": price,
      "quantity": quantity,
      "sellerName": await getSellerName(_auth, _firestore),
    };

    if (_image != null) {
      var snapshot = await _storage
          .ref('AllProducts/${_image!.path.split('/').last}')
          .putFile(_image!);
      var downloadUrl = await snapshot.ref.getDownloadURL();

      data['image'] = downloadUrl;
    }

    // Update the product document in the 'AllProducts' collection
    await _firestore
        .collection('AllProducts')
        .doc(productToUpdate.id)
        .update(data);

    // Update the product document in the 'FarmerProducts' collection
    await updateProductInFarmerProducts(
        productToUpdate.id, data, _auth, _firestore);

    setState(() {});

    // Show a success message
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product updated successfully!')),
    );

    // ignore: use_build_context_synchronously
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const FarmerScreenController()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> updateProductInFarmerProducts(
      String productId,
      Map<String, dynamic> productData,
      FirebaseAuth auth,
      FirebaseFirestore firestore) async {
    User? user = auth.currentUser;
    if (user != null) {
      String displayName = await getSellerName(auth, _firestore);
      await _firestore
          .collection('FarmerProducts')
          .doc(user.uid)
          .collection(displayName)
          .doc(productId)
          .update(productData);
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Edit Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.02), // 2% of screen width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      onTap: () async {
                        final XFile? selectedImage = await _picker.pickImage(
                            source: ImageSource.gallery);

                        if (selectedImage != null) {
                          _image = File(selectedImage.path);
                          setState(() {});
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
                                FontAwesomeIcons.dollarSign,
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

                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: increaseQuantity,
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: decreaseQuantity,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: screenSize.height * 0.02), // 2%
            // Product details text field
            Expanded(
              child: TextField(
                controller: _productDetailsController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Enter Product details',
                ),
              ),
            ),
            SizedBox(height: screenSize.height * 0.02), // 2% of screen height

            // ADD ITEM NOW and CANCEL buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _updateProductInDatabaseWithImage(product);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('SAVE CHANGES'),
                ),
                SizedBox(
                    height: screenSize.height *
                        0.02), // 2% of screen height spacing
                ElevatedButton(
                  onPressed: () {
                    _deleteProductFromDatabase(product);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const FarmerScreenController()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('DELETE PRODUCT'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
