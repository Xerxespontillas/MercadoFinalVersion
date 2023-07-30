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
  final minItems;
  final discount;
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
    required this.discount,
    required this.minItems,
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
        image = doc['image'],
        minItems = doc['minItems'],
        discount = doc['discount'];

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
      minItems: map['minItems'],
      discount: map['discount'],
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
    required String discount,
    required String minItems,
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
          minItems: minItems,
          discount: discount,
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
      minItems: map['minItems'] ?? 0,
      discount: map['discount'] ?? 0,
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
      'image': item.image,
      'minItems': item.minItems ?? 0,
      'discount': item.discount ?? 0,
    };
  }
}
