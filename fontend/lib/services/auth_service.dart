import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storageService = StorageService();

  Future<AuthResponse> signup(String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.signup),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);
      await _storageService.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      return authResponse;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to signup');
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);
      await _storageService.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      return authResponse;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to login');
    }
  }

  Future<void> logout() async {
    final token = await _storageService.getAccessToken();
    if (token != null) {
      await http.post(
        Uri.parse(ApiConfig.logout),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    }
    await _storageService.clearTokens();
  }

  Future<String?> getAccessToken() async {
    return await _storageService.getAccessToken();
  }
}