import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trantatphat/models/product.dart';
import 'package:trantatphat/models/review.dart';
import 'package:trantatphat/auth_service.dart';

class ProductService {
  // Dùng chung IP với AuthService để gọi xuống Spring Boot
  static const String baseUrl = "http://192.168.1.201:8080/api/products";

  Future<List<Product>> fetchNewProducts() async {
    final url = Uri.parse('$baseUrl/new');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Product.fromJson(item)).toList();
      }
    } catch (e) {
      print("Lỗi tải sản phẩm mới: $e");
    }
    return [];
  }

  Future<List<Product>> fetchSaleProducts() async {
    final url = Uri.parse('$baseUrl/sale');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Product.fromJson(item)).toList();
      }
    } catch (e) {
      print("Lỗi tải sản phẩm giảm giá: $e");
    }
    return [];
  }

  Future<List<Product>> fetchTopRatedProductsByCategory(String categoryName) async {
    final url = Uri.parse('$baseUrl/category/$categoryName/top-rated');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Product.fromJson(item)).toList();
      }
    } catch (e) {
      print("Lỗi tải sản phẩm theo danh mục và rating: $e");
    }
    return [];
  }

  // Lấy đánh giá của sản phẩm
  Future<List<Review>> fetchReviews(String productId) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.201:8080/api/reviews/$productId'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Review.fromJson(json)).toList();
      } else {
        print('Error fetching reviews: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception fetching reviews: $e');
      return [];
    }
  }

  // Lấy đánh giá của người dùng hiện tại
  Future<List<Review>> fetchUserReviews() async {
    if (AuthService.jwtToken == null) return [];
    
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.201:8080/api/reviews/user'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Review.fromJson(json)).toList();
      } else {
        print('Error fetching user reviews: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception fetching user reviews: $e');
      return [];
    }
  }

  Future<Review?> addOrUpdateReview(String productId, double rating, String content, List<String> images) async {
    final url = Uri.parse('http://192.168.1.201:8080/api/reviews');
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (AuthService.jwtToken != null) "Authorization": "Bearer ${AuthService.jwtToken!}"
        },
        body: jsonEncode({
          "productId": productId,
          "rating": rating,
          "content": content,
          "images": images,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return Review.fromJson(body);
      } else {
        print("Error creating review: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception creating review: $e");
      return null;
    }
  }

  Future<bool> hasUserReviewed(String productId) async {
    if (AuthService.jwtToken == null) return false;
    final url = Uri.parse('http://192.168.1.201:8080/api/reviews/check/$productId');
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}"
        },
      );
      if (response.statusCode == 200) {
        return response.body == 'true';
      }
    } catch (e) {
      print("Error checking review status: $e");
    }
    return false;
  }
}
