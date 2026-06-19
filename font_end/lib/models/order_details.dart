class OrderItemModel {
  final String productId;
  final String? image;
  final String productName;
  final String brand;
  final String color;
  final String size;
  final int units;
  final double price;

  OrderItemModel({
    required this.productId,
    this.image,
    required this.productName,
    required this.brand,
    required this.color,
    required this.size,
    required this.units,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] ?? '',
      image: json['image'],
      productName: json['productName'] ?? '',
      brand: json['brand'] ?? '',
      color: json['color'] ?? '',
      size: json['size'] ?? '',
      units: json['units'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class OrderDetailsModel {
  final String id;
  final String trackingNumber;
  final int quantity;
  final double totalAmount;
  final String date;
  final String status;
  final String? shippingAddress;
  final String? paymentMethod;
  final String? deliveryMethod;
  final String? discount;
  final List<OrderItemModel> items;

  OrderDetailsModel({
    required this.id,
    required this.trackingNumber,
    required this.quantity,
    required this.totalAmount,
    required this.date,
    required this.status,
    this.shippingAddress,
    this.paymentMethod,
    this.deliveryMethod,
    this.discount,
    required this.items,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<OrderItemModel> itemsList = list.map((i) => OrderItemModel.fromJson(i)).toList();

    return OrderDetailsModel(
      id: json['id'] ?? '',
      trackingNumber: json['trackingNumber'] ?? '',
      quantity: json['quantity'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      shippingAddress: json['shippingAddress'],
      paymentMethod: json['paymentMethod'],
      deliveryMethod: json['deliveryMethod'],
      discount: json['discount'],
      items: itemsList,
    );
  }
}
