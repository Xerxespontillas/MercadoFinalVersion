import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merkado/screens/customer_screens/widgets/customer_app_drawer.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../widgets/farmer_app_drawer.dart';
import '../farmer_screens/models/product.dart';
import 'cart_screen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<String> getUserType(
      FirebaseAuth auth, FirebaseFirestore firestore) async {
    User? user = auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await firestore.collection('customers').doc(user.uid).get();
      if (userDoc.exists) {
        return 'customer';
      }
      userDoc = await firestore.collection('farmers').doc(user.uid).get();
      if (userDoc.exists) {
        return 'farmer';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getUserType(FirebaseAuth.instance, FirebaseFirestore.instance),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show a loading spinner while waiting
          } else {
            String userType = snapshot.data ?? '';
            return Scaffold(
              endDrawer: Container(
                color: Colors.black, // Set the background color to black
                child: userType == 'customer'
                    ? const CustomerAppDrawer()
                    : const FarmerAppDrawer(),
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
                                  color: Colors
                                      .black, // Choose your desired border color
                                  width:
                                      2.0, // Adjust the border width as needed
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
                                  Navigator.of(context)
                                      .pushNamed(CartScreen.routeName);
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
                          fontSize: 25),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream:
                            _firestore.collection('AllProducts').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final List<DocumentSnapshot> allProducts =
                              snapshot.data!.docs;

                          return FutureBuilder<List<DocumentSnapshot>>(
                            future: _filterProducts(allProducts,
                                search), // use _filterProducts future here
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              final List<DocumentSnapshot> filteredProducts =
                                  snapshot.data ?? [];

                              return ListView.builder(
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot productData =
                                      filteredProducts[index];
                                  return Container(
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    productData['productName'],
                                                    style: const TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Image.network(
                                                  productData['image'],
                                                  errorBuilder: (BuildContext
                                                          context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                    // Return any widget you want to be displayed instead of the network image like an asset image or an icon
                                                    return const Icon(
                                                        Icons.image,
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 20),
                                                Text(productData[
                                                    'productDetails']),
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
                                              var productQuantity =
                                                  productData['quantity'];
                                              if (productQuantity <= 0) {
                                                // The product is out of stock. Show a dialog and return early.
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Product out of stock'),
                                                      content: const Text(
                                                          'This product is currently out of stock and cannot be added to the cart.'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child:
                                                              const Text('Ok'),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                                return;
                                              }

                                              Provider.of<CartProvider>(context,
                                                      listen: false)
                                                  .addItem(
                                                Product(
                                                  id: productData.id,
                                                  productName: productData[
                                                      'productName'],
                                                  productDetails: productData[
                                                      'productDetails'],
                                                  price: productData['price']
                                                      .toDouble(),
                                                  quantity:
                                                      productData['quantity'],
                                                  maxQuantity:
                                                      productData['quantity'],
                                                  sellerName:
                                                      productData['sellerName'],
                                                  sellerId: productData[
                                                      'sellerUserId'],
                                                  image: productData['image'],
                                                ),
                                                context, // pass the context here
                                              );
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  0, 0, 0, 90),
                                              child: Container(
                                                height: 25,
                                                width: 88,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 0, 0, 0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                ),
                                                child: Row(
                                                  children: const [
                                                    Text('Add to cart',
                                                        style: TextStyle(
                                                            fontSize: 10)),
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
                                  );
                                },
                              );
                            },
                          );
                        }),
                  ),
                ],
              ),
            );
          }
        });
  }
}

Future<String> getSellerName(
    FirebaseAuth auth, FirebaseFirestore firestore) async {
  User? user = _auth.currentUser;
  if (user != null) {
    DocumentSnapshot? userDoc =
        await _firestore.collection('farmers').doc(user.uid).get();
    if (!userDoc.exists) {
      // If the document doesn't exist in the 'farmers' collection,
      // check the 'customers' collection.
      userDoc = await _firestore.collection('customers').doc(user.uid).get();
    }
    return (userDoc.data() as Map<String, dynamic>)['displayName'] ?? '';
  } else {
    return '';
  }
}

// Filtering function
Future<List<DocumentSnapshot>> _filterProducts(
    List<DocumentSnapshot> products, String searchText) async {
  // Fetch the current user's display name from Firestore
  String currentUserDisplayName = await getSellerName(_auth, _firestore);

  // ignore: unnecessary_null_comparison
  if (searchText == null || searchText.trim().isEmpty) {
    return products.where((product) {
      final data = product.data() as Map<String, dynamic>;
      final String sellerName = data['sellerName'] ?? '';
      final int quantity = data['quantity'] ?? 0;
      return quantity > 0 && sellerName != currentUserDisplayName;
    }).toList();
  }

  final searchTextLower = searchText.toLowerCase();

  return products.where((product) {
    final data = product.data() as Map<String, dynamic>;
    final String productName = data['productName'] ?? '';
    final String sellerName = data['sellerName'] ?? '';
    final int quantity = data['quantity'] ?? 0;

    final productNameLower = productName.toLowerCase();
    final sellerNameLower = sellerName.toLowerCase();

    return quantity > 0 &&
        sellerName != currentUserDisplayName &&
        (productNameLower.contains(searchTextLower) ||
            sellerNameLower.contains(searchTextLower));
  }).toList();
}
