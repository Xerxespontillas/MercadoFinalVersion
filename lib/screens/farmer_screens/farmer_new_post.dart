import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../organization_screens/organization_screen_controller.dart';
import 'farmer_screen_controller.dart';

class FarmerNewProductPost extends StatefulWidget {
  static const routeName = '/farmer-new-post';
  const FarmerNewProductPost({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FarmerNewProductPostState createState() => _FarmerNewProductPostState();
}

class _FarmerNewProductPostState extends State<FarmerNewProductPost> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  int quantity = 0;
  final TextEditingController _textController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var farmerId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _addProductToDatabaseWithImage() async {
    if (_image == null) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Please upload an image.'),
      //   ),
      // );
      // return;
    }

    setState(() {});

    String productName = _productNameController.text;
    String productDetails = _textController.text;
    double price = double.parse(_priceController.text);

    // Create a map of the data we want to upload
    Map<String, dynamic> data = {
      "productName": productName,
      "productDetails": productDetails,
      "price": price,
      "quantity": quantity,
      "sellerName": await getSellerName(_auth, _firestore),
      "sellerUserId": farmerId,
    };

    // var snapshot = await _storage
    //     .ref('AllProducts/${_image!.path.split('/').last}')
    //     .putFile(_image!);
    // var downloadUrl = await snapshot.ref.getDownloadURL();

    // data['image'] = downloadUrl;

    // Generate a new document reference in 'products' collection to get a unique ID
    DocumentReference newDocRef = _firestore.collection('AllProducts').doc();

    // Use the unique ID from the new document reference as the productId
    String productId = newDocRef.id;

    // Add the product data to the 'AllProducts' collection with the productId
    await _firestore.collection('AllProducts').doc(productId).set(data);

    // Add the product data to the 'FarmerProducts' collection
    await addProductToDatabase(productId, data, _auth, _firestore);

    setState(() {});

    // ignore: use_build_context_synchronously
    await navigateBasedOnUserType(context, _auth, _firestore);
  }

  Future<void> navigateBasedOnUserType(BuildContext context, FirebaseAuth auth,
      FirebaseFirestore firestore) async {
    User? user = auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc;
      String userType;
      try {
        userDoc = await _firestore.collection('farmers').doc(user.uid).get();
        if (!userDoc.exists) {
          userDoc =
              await _firestore.collection('organizations').doc(user.uid).get();
          userType = 'organization';
        } else {
          userType = 'farmer';
        }
      } catch (e) {
        return;
      }

      if (userType == 'farmer') {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  const FarmerScreenController()), // replace with your FarmerScreenController
          (Route<dynamic> route) => false,
        );
      } else if (userType == 'organization') {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  const OrgScreenController()), // replace with your OrgScreenController
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  Future<void> addProductToDatabase(
      String productId,
      Map<String, dynamic> productData,
      FirebaseAuth auth,
      FirebaseFirestore firestore) async {
    User? user = auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc;
      String collectionPath;
      try {
        userDoc = await _firestore.collection('farmers').doc(user.uid).get();
        if (!userDoc.exists) {
          userDoc =
              await _firestore.collection('organizations').doc(user.uid).get();
          collectionPath = 'OrgProducts';
        } else {
          collectionPath = 'FarmerProducts';
        }
      } catch (e) {
        return;
      }
      String displayName =
          (userDoc.data() as Map<String, dynamic>)['displayName'] ?? '';
      await _firestore
          .collection(collectionPath)
          .doc(user.uid)
          .collection(displayName)
          .doc(productId)
          .set(productData);
    }
  }

  Future<String> getSellerName(
      FirebaseAuth auth, FirebaseFirestore firestore) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc;
      try {
        userDoc = await _firestore.collection('farmers').doc(user.uid).get();
        if (!userDoc.exists) {
          userDoc =
              await _firestore.collection('organizations').doc(user.uid).get();
        }
      } catch (e) {
        return '';
      }
      return (userDoc.data() as Map<String, dynamic>)['displayName'] ?? '';
    } else {
      return '';
    }
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

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('New Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.02), // 2% of screen width
        child: Form(
          key: _formKey,
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
                              ? const Icon(
                                  Icons.cloud_upload,
                                  size: 80,
                                )
                              : Image.file(_image!),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      width: screenSize.width * 0.02), // 2% of screen width
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a product name';
                                    }
                                    return null;
                                  },
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
                                quantity.toString(),
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
                  controller: _textController,
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
                    onPressed: _addProductToDatabaseWithImage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ADD ITEM NOW'),
                  ),
                  SizedBox(
                      height: screenSize.height *
                          0.02), // 2% of screen height spacing
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) =>
                                const FarmerScreenController()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('CANCEL'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
