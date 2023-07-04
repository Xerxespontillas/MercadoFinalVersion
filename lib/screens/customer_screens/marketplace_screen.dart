import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merkado/screens/customer_screens/selected_product_marketplace.dart';
import 'package:merkado/screens/customer_screens/widgets/customer_app_drawer.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../widgets/farmer_app_drawer.dart';
import '../farmer_screens/models/product.dart';
import 'cart_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);
  static const routeName = '/marketplace-screen';

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String search = '';
  int cartCount = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> isUserFarmer(String userId) async {
    final DocumentSnapshot farmerDoc = await FirebaseFirestore.instance
        .collection('farmers')
        .doc(userId)
        .get();

    final DocumentSnapshot organizationDoc = await FirebaseFirestore.instance
        .collection('organizations')
        .doc(userId)
        .get();

    if (farmerDoc.exists || organizationDoc.exists) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: FutureBuilder<bool>(
        future: isUserFarmer(FirebaseAuth.instance.currentUser!.uid),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox
                .shrink(); // return an empty widget while loading
          } else {
            if (snapshot.data == true) {
              // Render FarmerAppDrawer for farmer users
              return Container(
                color: Colors.black, // Set the background color to black
                child: const FarmerAppDrawer(),
              );
            } else {
              // Render CustomerAppDrawer for customer users
              return Container(
                color: Colors.black, // Set the background color to black
                child: const CustomerAppDrawer(),
              );
            }
          }
        },
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
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black, size: 30),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        search = value;
                      });
                    },
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
            child: const Center(
              child: Text(
                'All Products',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 25),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('AllProducts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<DocumentSnapshot> allProducts = snapshot.data!.docs;
                final filteredProducts = _filterProducts(allProducts, search,
                    FirebaseAuth.instance.currentUser!.uid);

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot productData = filteredProducts[index];
                    // Print the data of the product document

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          SelectedProductMarketplace.routeName,
                          arguments: Product.fromDocumentSnapshot(productData),
                        );
                      },
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
                                  SizedBox(
                                    width: 110,
                                    child: Align(
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
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Image.network(
                                      productData['image'],
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        // Return any widget you want to be displayed instead of the network image like an asset image or an icon
                                        return const Icon(Icons.image,
                                            size: 100);
                                      },
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(
                                      "Posted on: ${productData['datePosted']}",
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        //fontSize: 20,
                                      ),
                                    ),
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
                              GestureDetector(
                                onTap: () {
                                  Provider.of<CartProvider>(context,
                                          listen: false)
                                      .addItem(
                                    Product(
                                      id: productData.id,
                                      productName: productData['productName'],
                                      productDetails:
                                          productData['productDetails'],
                                      price: productData['price'].toDouble(),
                                      quantity: productData['quantity'],
                                      maxQuantity: productData['quantity'],
                                      sellerName: productData['sellerName'],
                                      sellerId: productData['sellerUserId'],
                                      image: productData['image'],
                                    ),
                                    context, // pass the context here
                                  );
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 90),
                                  child: Container(
                                    height: 25,
                                    width: 88,
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: Row(
                                      children: const [
                                        Text('Add to cart',
                                            style: TextStyle(fontSize: 10)),
                                        SizedBox(width: 5),
                                        Icon(
                                          Icons.add_shopping_cart,
                                          size: 18,
                                        ),
                                      ],
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

// Filtering function
List<DocumentSnapshot> _filterProducts(
    List<DocumentSnapshot> products, String searchText, String userId) {
  // ignore: unnecessary_null_comparison
  if (searchText == null || searchText.trim().isEmpty) {
    return products.where((product) {
      final data = product.data() as Map<String, dynamic>;
      final int quantity = (data['quantity'] ?? 0) as int;
      final String sellerUserId = data['sellerUserId'] ?? '';
      return quantity > 0 && sellerUserId != userId;
    }).toList();
  }

  final searchTextLower = searchText.toLowerCase();

  return products.where((product) {
    final data = product.data() as Map<String, dynamic>;
    final String productName = data['productName'] ?? '';
    final String sellerName = data['sellerName'] ?? '';
    final int quantity = (data['quantity'] ?? 0) as int;
    final String sellerUserId = data['sellerUserId'] ?? '';

    final productNameLower = productName.toLowerCase();
    final sellerNameLower = sellerName.toLowerCase();

    return (productNameLower.contains(searchTextLower) ||
            sellerNameLower.contains(searchTextLower)) &&
        quantity > 0 &&
        sellerUserId != userId;
  }).toList();
}
