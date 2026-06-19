class OrderModel {
  final String id;
  final String trackingNumber;
  final int quantity;
  final double totalAmount;
  final String date;
  final String status;

  OrderModel({
    required this.id,
    required this.trackingNumber,
    required this.quantity,
    required this.totalAmount,
    required this.date,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      trackingNumber: json['trackingNumber'] ?? '',
      quantity: json['quantity'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      date: json['date'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
