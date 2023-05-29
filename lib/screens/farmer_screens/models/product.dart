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
}
