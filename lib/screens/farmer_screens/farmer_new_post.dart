import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewProductPost extends StatefulWidget {
  const NewProductPost({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NewProductPostState createState() => _NewProductPostState();
}

class _NewProductPostState extends State<NewProductPost> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  int quantity = 0;
  final TextEditingController _textController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addProductToDatabaseWithImage() async {
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
    };

    if (_image != null) {
      var snapshot = await _storage
          .ref('AllProducts/${_image!.path.split('/').last}')
          .putFile(_image!);
      var downloadUrl = await snapshot.ref.getDownloadURL();

      data['image'] = downloadUrl;
    }

    // Use the Firestore instance to add the data
    await _firestore.collection('AllProducts').add(data);

    setState(() {});
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
        title: const Text('New Post'),
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
                            ? const Icon(
                                Icons.cloud_upload,
                                size: 80,
                              )
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
                    // Handle button press here
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
    );
  }
}
