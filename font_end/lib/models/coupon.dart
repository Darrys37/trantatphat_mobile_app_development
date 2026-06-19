class Coupon {
  final String id;
  final String code;
  final String title;
  final String description;
  final double discountValue;
  final String discountType; // "PERCENTAGE" or "FIXED"
  final int remainingDays;

  Coupon({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountValue,
    required this.discountType,
    required this.remainingDays,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      discountType: json['discountType'] ?? 'PERCENTAGE',
      remainingDays: json['remainingDays'] ?? 0,
    );
  }
}
