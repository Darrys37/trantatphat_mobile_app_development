class Review {
  final String? id;
  final String? productId;
  final String? productName;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String content;
  final DateTime? createdAt;
  final List<String> images;
  final int helpfulCount;

  Review({
    this.id,
    this.productId,
    this.productName,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.content,
    this.createdAt,
    required this.images,
    required this.helpfulCount,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      userName: json['userName'] ?? 'Unknown User',
      userAvatar: json['userAvatar'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      helpfulCount: json['helpfulCount'] ?? 0,
    );
  }
}
