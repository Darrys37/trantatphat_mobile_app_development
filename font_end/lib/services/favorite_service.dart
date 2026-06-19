import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:trantatphat/models/product.dart';
import 'package:trantatphat/auth_service.dart';

class FavoriteService {
  static const String baseUrl = "http://192.168.1.201:8080/api/favorites";

  // Global notifier to trigger UI updates across screens when favorites change
  static final ValueNotifier<int> favoritesChangedNotifier = ValueNotifier<int>(0);

  static void notifyFavoritesChanged() {
    favoritesChangedNotifier.value++;
  }

  // Lấy danh sách sản phẩm yêu thích
  Future<List<Product>> getFavorites() async {
    if (AuthService.jwtToken == null) return [];
    
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => Product.fromJson(item)).toList();
      } else {
        print("Lỗi lấy favorites: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception lấy favorites: $e");
    }
    return [];
  }

  // Thêm sản phẩm vào yêu thích
  Future<bool> addFavorite(String productId) async {
    if (AuthService.jwtToken == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$productId'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
          "Content-Type": "application/json",
        },
      );

      bool success = response.statusCode == 200 || response.statusCode == 201;
      if (success) notifyFavoritesChanged();
      return success;
    } catch (e) {
      print("Exception thêm favorite: $e");
    }
    return false;
  }

  // Xóa sản phẩm khỏi yêu thích
  Future<bool> removeFavorite(String productId) async {
    if (AuthService.jwtToken == null) return false;
    
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$productId'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
          "Content-Type": "application/json",
        },
      );

      bool success = response.statusCode == 200 || response.statusCode == 204;
      if (success) notifyFavoritesChanged();
      return success;
    } catch (e) {
      print("Exception xóa favorite: $e");
    }
    return false;
  }

  // Kiểm tra xem sản phẩm đã được yêu thích chưa
  Future<bool> checkFavorite(String productId) async {
    if (AuthService.jwtToken == null) return false;
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/check/$productId'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return response.body == 'true';
      }
    } catch (e) {
      print("Exception check favorite: $e");
    }
    return false;
  }
}
