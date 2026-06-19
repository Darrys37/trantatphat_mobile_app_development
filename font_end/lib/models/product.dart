class Product {
  final String? id;
  final String name;
  final String? brand;
  final double? price;
  final double? salePrice;
  final String? imageUrl;
  final double? rating;
  final int? reviewCount;
  final String? description;

  Product({
    this.id,
    required this.name,
    this.brand,
    this.price,
    this.salePrice,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.description,
  });

  static const List<String> _brands = [
    'Zara', 'H&M', 'Mango', 'Chanel', 'Dior', 
    'Gucci', 'Prada', 'Louis Vuitton', 'Hermès', 
    'Burberry', 'Balenciaga', 'Fendi', 'Valentino'
  ];

  factory Product.fromJson(Map<String, dynamic> json) {
    String idStr = json['id']?.toString() ?? '';
    int idHash = idStr.hashCode;
    String assignedBrand = _brands[idHash.abs() % _brands.length];

    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      brand: json['brand'] ?? assignedBrand,
      price: json['comparePrice'] != null ? (json['comparePrice'] as num).toDouble() : (json['price'] != null ? (json['price'] as num).toDouble() : null),
      salePrice: json['salePrice'] != null ? (json['salePrice'] as num).toDouble() : null,
      imageUrl: json['imageUrl'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['reviewCount'],
      description: json['description'],
    );
  }
}
