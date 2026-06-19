import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static String? jwtToken;
  static String? userName;
  static String? userEmail;
  static String? userPhotoUrl;
  // THAY ĐỔI IP NÀY THÀNH IP MẠNG WI-FI THẬT CỦA MÁY TÍNH BẠN (Xem lại ipconfig)
  static const String baseUrl = "http://192.168.1.201:8080/api/auth";

  static Future<void> signOut() async {
    jwtToken = null;
    userName = null;
    userEmail = null;
    userPhotoUrl = null;
  }

  // 1. Logic gọi API Đăng ký tài khoản
  Future<String?> register(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return "SUCCESS"; // Thành công
      } else {
        return response.body; // Trả về thông báo lỗi từ Spring Boot
      }
    } catch (e) {
      return "Không thể kết nối không dây tới Server. Hãy kiểm tra Wi-Fi hoặc IP!";
    }
  }

  // 2. Logic gọi API Đăng nhập truyền thống
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Trả về cục dữ liệu chứa Token JWT
      } else {
        print("Đăng nhập thất bại: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      return null;
    }
  }

  Future<dynamic> loginWithGoogle(String idToken) async {
    final url = Uri.parse('$baseUrl/google/login'); // Endpoint mới
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": idToken}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Map chứa JWT
      } else {
        // Trả về chuỗi lỗi (Ví dụ: "Tài khoản chưa được đăng ký...")
        return response.body;
      }
    } catch (e) {
      return "Lỗi kết nối không dây khi đăng nhập Google: $e";
    }
  }

  Future<dynamic> registerWithGoogle(String idToken) async {
    final url = Uri.parse('$baseUrl/google/register'); // Endpoint mới
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": idToken}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Thành công
      } else {
        return response.body; // Trả về lỗi
      }
    } catch (e) {
      return "Lỗi kết nối không dây khi đăng ký Google: $e";
    }
  }

  Future<dynamic> loginWithFacebook(String accessToken) async {
    final url = Uri.parse('$baseUrl/facebook/login'); 
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": accessToken}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return response.body;
      }
    } catch (e) {
      return "Lỗi kết nối không dây khi đăng nhập Facebook: $e";
    }
  }

  Future<dynamic> registerWithFacebook(String accessToken) async {
    final url = Uri.parse('$baseUrl/facebook/register'); 
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": accessToken}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return response.body;
      }
    } catch (e) {
      return "Lỗi kết nối không dây khi đăng ký Facebook: $e";
    }
  }
}