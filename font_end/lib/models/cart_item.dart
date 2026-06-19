class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String productImageUrl;
  final double price;
  final String color;
  final String size;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.price,
    required this.color,
    required this.size,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productImageUrl: json['productImageUrl'] ?? '',
      price: (json['price'] as num).toDouble(),
      color: json['color'] ?? '',
      size: json['size'] ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }
}
