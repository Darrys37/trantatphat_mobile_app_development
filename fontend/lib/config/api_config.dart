import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    } else {
      // Điện thoại thật (Android/iOS) → IP LAN
      return 'http://10.200.68.254:8080/api';
    }
  }

  static String get signup => '$baseUrl/auth/signup';
  static String get login => '$baseUrl/auth/login';
  static String get logout => '$baseUrl/auth/logout';
  static String get refreshToken => '$baseUrl/auth/refresh';
  static String get profile => '$baseUrl/user/profile';
  
  static String get googleLogin => '$baseUrl/oauth2/authorization/google';
  static String get facebookLogin => '$baseUrl/oauth2/authorization/facebook';
}