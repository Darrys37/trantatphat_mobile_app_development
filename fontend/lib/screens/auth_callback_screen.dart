import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthCallbackScreen extends StatelessWidget {
  const AuthCallbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy token từ URL parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleCallback(context);
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Đang xử lý đăng nhập...'),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCallback(BuildContext context) async {
    try {
      // Lấy query parameters từ URL
      final uri = Uri.parse(Uri.base.toString());
      final accessToken = uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh_token'];

      if (accessToken != null && refreshToken != null) {
        // Lưu token
        final storageService = StorageService();
        await storageService.saveTokens(accessToken, refreshToken);

        // Navigate to Home
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        // Không có token, quay về Login
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      // Lỗi, quay về Login
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}