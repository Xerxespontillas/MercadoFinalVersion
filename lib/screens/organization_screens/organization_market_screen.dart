import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merkado/screens/customer_screens/widgets/customer_app_drawer.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../customer_screens/cart_screen.dart';
import '../farmer_screens/models/product.dart';

class OrgMarketScreen extends StatefulWidget {
  const OrgMarketScreen({Key? key}) : super(key: key);
  static const routeName = '/Org-market';

  @override
  State<OrgMarketScreen> createState() => _OrgMarketScreenState();
}

class _OrgMarketScreenState extends State<OrgMarketScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // User? currentUser = _auth.currentUser; // Get the current user
  String search = '';
  int cartCount = 0;

  @override
  Widget build(BuildContext context) {
    final String? currentUserDisplayName = Provider.of<AuthProvider>(context)
        .getCurrentUser()
        ?.displayName; // Get the current user display name
    return Scaffold(
      endDrawer: Container(
        color: Colors.black, // Set the background color to black
        child: const CustomerAppDrawer(),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Market Place',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '   looking for something? ',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 20, // Adjust the icon size as needed
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color:
                              Colors.black, // Choose your desired border color
                          width: 2.0, // Adjust the border width as needed
                        ),
                        borderRadius: BorderRadius.circular(
                            12.0), // Adjust the border radius as needed
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 12.0), // Adjust padding as needed
                    ),
                  ),
                ),
              ),
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) => Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 30, 10),
                      child: IconButton(
                        icon: const Icon(
                          Icons.shopping_cart,
                          size: 40,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(CartScreen.routeName);
                        },
                      ),
                    ),
                    Positioned(
                      right: 30,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          cartProvider.itemCount.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            alignment: AlignmentDirectional
                .centerStart, // Aligns the child to the start (left)
            child: const Text(
              'Top selling',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 30),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('AllProducts')
                  .where('sellerName',
                      isEqualTo:
                          currentUserDisplayName) // Filter by current user's display name
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot productData = snapshot.data!.docs[index];
                    return InkWell(
                      highlightColor: Colors.green,
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      productData['productName'],
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  Image.network(
                                    productData['image'],
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? stackTrace) {
                                      // Return any widget you want to be displayed instead of the network image like an asset image or an icon
                                      return const Icon(Icons.error);
                                    },
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(productData['productDetails']),
                                    const SizedBox(height: 4),
                                    Text(
                                        "Quantity: ${productData['quantity']}"),
                                    const SizedBox(height: 4),
                                    Text(
                                        "Price: ₱ ${NumberFormat('#,##0.00').format(productData['price'])}"),
                                    const SizedBox(height: 4),
                                    Text(
                                        "Seller Name:\n${productData['sellerName']}"),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Provider.of<CartProvider>(context,
                                          listen: false)
                                      .addItem(
                                    Product(
                                      id: productData.id,
                                      productSeller:
                                          productData['productSeller'],
                                      productName: productData['productName'],
                                      productDetails:
                                          productData['productDetails'],
                                      price: productData['price'].toDouble(),
                                      quantity: productData['quantity'],
                                      maxQuantity: productData['quantity'],
                                      sellerName: productData['sellerName'],
                                      sellerId: productData['sellerUserId'],
                                      image: productData['image'],
                                      discount: productData['discount'],
                                      minItems: productData['minItems'],
                                    ),
                                    context, // pass the context here
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text(
                                          "Item successfully added to cart"),
                                    ),
                                  );
                                },
                                child: InkWell(
                                  child: Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                      ),
                                      child: Row(
                                        children: [
                                          Text('Add to cart',
                                              style: TextStyle(fontSize: 12)),
                                          SizedBox(width: 5),
                                          Icon(
                                            Icons.add_shopping_cart,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
