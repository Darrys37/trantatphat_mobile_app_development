class PaymentCard {
  final String id;
  final String cardHolderName;
  final String cardNumber;
  final String expiryDate;
  final String brand;
  final bool isDefault;

  PaymentCard({
    required this.id,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.brand,
    required this.isDefault,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'],
      cardHolderName: json['cardHolderName'] ?? '',
      cardNumber: json['cardNumber'] ?? '',
      expiryDate: json['expiryDate'] ?? '',
      brand: json['brand'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}
