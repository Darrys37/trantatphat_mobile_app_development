class UserAddress {
  final String id;
  final String fullName;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;

  UserAddress({
    required this.id,
    required this.fullName,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.isDefault,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}
