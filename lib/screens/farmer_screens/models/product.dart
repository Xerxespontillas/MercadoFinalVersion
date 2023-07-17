import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String productName;
  final String productDetails;
  final double price;
  late final int quantity;
  final int maxQuantity;

  final String sellerName;
  final String sellerId;
  final String image;

  Product({
    required this.id,
    required this.productName,
    required this.productDetails,
    required this.price,
    required this.quantity,
    required this.maxQuantity,
    required this.sellerName,
    required this.sellerId,
    required this.image,
  });

  // Add this method
  Product.fromDocumentSnapshot(DocumentSnapshot doc)
      : id = doc.id,
        productName = doc['productName'],
        productDetails = doc['productDetails'],
        price = doc['price'],
        quantity = doc['quantity'],
        maxQuantity = doc['quantity'],
        sellerName = doc['sellerName'],
        sellerId = doc['sellerUserId'],
        image = doc['image'];

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      productName: map['productName'],
      productDetails: map['productDetails'],
      price: map['price'],
      quantity: map['quantity'],
      maxQuantity: map['maxQuantity'],
      sellerName: map['sellerName'],
      sellerId: map['sellerId'],
      image: map['image'],
    );
  }
}

class CartItem extends Product {
  @override
  // ignore: overridden_fields
  int quantity;

  CartItem({
    required String id,
    required String productName,
    required String productDetails,
    required double price,
    required this.quantity,
    required int maxQuantity,
    required String sellerName,
    required String sellerId,
    required String image,
  }) : super(
          id: id,
          productName: productName,
          productDetails: productDetails,
          price: price,
          quantity: quantity,
          maxQuantity: maxQuantity,
          sellerName: sellerName,
          sellerId: sellerId,
          image: image,
        );
  // Add this method
  CartItem.fromDocumentSnapshot(DocumentSnapshot doc)
      : quantity = doc['quantity'],
        super.fromDocumentSnapshot(doc);

  factory CartItem.fromMap(Map<dynamic, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      productName: map['productName'] ?? '',
      productDetails: map['productDetails'] ?? '',
      price: map['price'] ?? 0.0,
      quantity: map['quantity'] ?? 0.0,
      maxQuantity: map['maxQuantity'] ?? 0.0,
      sellerName: map['sellerName'] ?? '',
      sellerId: map['sellerId'] ?? '',
      image: map['image'] ?? '',
    );
  }
  static Map<String, dynamic> toMap(CartItem item) {
    return {
      'id': item.id,
      'productName': item.productName,
      'productDetails': item.productDetails,
      'price': item.price,
      'quantity': item.quantity,
      'maxQuantity': item.maxQuantity,
      'sellerName': item.sellerName,
      'sellerId': item.sellerId,
      'image': item.image
    };
  }
}
