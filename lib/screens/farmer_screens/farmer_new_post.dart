import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
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
  final TextEditingController _quantityController = TextEditingController();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  int quantity = 0;
  final TextEditingController _textController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _quantityController.text = '0'; // Initialize with 0 quantity
  }

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var farmerId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _addProductToDatabaseWithImage() async {
    // Check if any of the fields are empty
    if (_productNameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Some of the fields are empty. Please fill all the fields.'),
        ),
      );
      return;
    }

    // Check if the quantity is 0
    if (int.tryParse(_quantityController.text) == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantity should not be 0.'),
        ),
      );
      return;
    }

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload an image.'),
        ),
      );
      return;
    }

    setState(() {});

    String productName = _productNameController.text;
    String productDetails = _textController.text;
    double price = double.parse(_priceController.text);

    // Create a map of the data we want to upload
    Map<String, dynamic> data = {
      'productSeller': 'Farmer',
      "productName": productName,
      "productDetails": productDetails,
      "price": price,
      "quantity": int.tryParse(_quantityController.text),
      "sellerName": await getSellerName(_auth, _firestore),
      "sellerUserId": farmerId,
      "datePosted": DateFormat("MMMM, dd, yyyy").format(DateTime.now()),
      "discount": int.tryParse(_discountController.text) ?? 0,
      "minItems": int.tryParse(_minItemsController.text) ?? 0,
    };

    var snapshot = await _storage
        .ref('AllProducts/${_image!.path.split('/').last}')
        .putFile(_image!);
    var downloadUrl = await snapshot.ref.getDownloadURL();

    data['image'] = downloadUrl;

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
    int currentQuantity = int.parse(_quantityController.text);
    _quantityController.text = (currentQuantity + 1).toString();
  }

  void decreaseQuantity() {
    int currentQuantity = int.parse(_quantityController.text);
    if (currentQuantity > 0) {
      _quantityController.text = (currentQuantity - 1).toString();
    }
  }

  final _discountController = TextEditingController();
  final _minItemsController = TextEditingController();
  bool _isLoading = false;
  bool _isError = false;
  Widget _discountDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Add/Edit Discount'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [],
          ),
          SizedBox(
            height: 40,
          ),
          TextField(
            controller: _discountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Discount Percent (%)',
            ),
          ),
          TextField(
            controller: _minItemsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Minimum Number of Items',
            ),
          ),
          if (_isError)
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please fill in all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: const Text('OK'),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  if (_discountController.text.isEmpty ||
                      _minItemsController.text.isEmpty) {
                    setState(() {
                      _isError = true;
                    });
                  } else {
                    _isError = false;
                    Navigator.of(context).pop();
                  }
                },
          child:
              _isLoading ? const CircularProgressIndicator() : const Text('OK'),
        ),
      ],
    );
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
                      width: screenSize.width * 0.01), // 2% of screen width
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
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal:
                                              true), // Allow decimal numbers
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp(
                                        r'^\d+\.?\d{0,5}')), // Allow numbers with up to two decimal places
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
                                      0.01), // 1% of screen width
                              SizedBox(
                                width: 28,
                                child: TextField(
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter
                                        .digitsOnly, // Allow only digits (numbers)
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      size: 10,
                                    ),
                                    onPressed: increaseQuantity,
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  size: 10,
                                ),
                                onPressed: decreaseQuantity,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 38,
                          child: OutlinedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => _discountDialog(ctx),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              primary: Colors.black,
                              side: const BorderSide(color: Colors.black),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text('Add Discounts'),
                            ),
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
