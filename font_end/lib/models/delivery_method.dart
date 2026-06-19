class DeliveryMethod {
  final String id;
  final String name;
  final String duration;
  final double price;
  final String logoUrl;

  DeliveryMethod({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.logoUrl,
  });

  factory DeliveryMethod.fromJson(Map<String, dynamic> json) {
    return DeliveryMethod(
      id: json['id'],
      name: json['name'] ?? '',
      duration: json['duration'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      logoUrl: json['logoUrl'] ?? '',
    );
  }
}
