import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:photo_view/photo_view.dart';

import '../farmer_screens/models/product.dart';

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
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Selected Product'),
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

            SizedBox(height: screenSize.height * 0.02), // 2%
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

            // ADD ITEM NOW and CANCEL buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                    height: screenSize.height *
                        0.02), // 2% of screen height spacing
              ],
            ),
          ],
        ),
      ),
    );
  }
}
