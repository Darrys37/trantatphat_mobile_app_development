import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    } else {
      // Điện thoại thật (Android/iOS) → IP LAN
      return 'http://172.16.7.232:8080/api';
    }
  }

  // Auth
  static String get signup       => '$baseUrl/auth/signup';
  static String get login        => '$baseUrl/auth/login';
  static String get logout       => '$baseUrl/auth/logout';
  static String get refreshToken => '$baseUrl/auth/refresh';
  static String get profile      => '$baseUrl/user/profile';

  static String get googleLogin   => '$baseUrl/oauth2/authorization/google';
  static String get facebookLogin => '$baseUrl/oauth2/authorization/facebook';

  // Shop — ✅ FIX: không có /api prefix vì baseUrl đã có rồi
  static String get products     => '$baseUrl/shop/products';
  static String get categories   => '$baseUrl/shop/categories';

  // Favorites: GET/POST/DELETE /shop/favorites/{customerId}/{productId}
  static String favorites(String customerId) =>
      '$baseUrl/shop/favorites/$customerId';
  static String favoriteItem(String customerId, String productId) =>
      '$baseUrl/shop/favorites/$customerId/$productId';
  static String favoriteCheck(String customerId, String productId) =>
      '$baseUrl/shop/favorites/$customerId/$productId/check';

  // Reviews
  static String reviewsForProduct(String productId) =>
      '$baseUrl/shop/reviews/product/$productId';
  static String submitReview(String customerId, String productId) =>
      '$baseUrl/shop/reviews/$customerId/$productId';
  static String markHelpful(String reviewId) =>
      '$baseUrl/shop/reviews/$reviewId/helpful';
}