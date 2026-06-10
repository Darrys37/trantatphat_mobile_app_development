import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../config/api_config.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _storageService = StorageService();
  
  late final GoogleSignIn _googleSignIn;
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _initGoogleSignIn();
  }

  void _initGoogleSignIn() {
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: kIsWeb 
          ? null 
          : '402633860564-hhgbn1koj0hr0d3hpjdctdqegcof3nfn.apps.googleusercontent.com',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showError('Login failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================== LOGIN GOOGLE ==================
  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // ⭐ FIX 1: signOut trước để luôn hiện màn chọn tài khoản
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/oauth2/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': googleUser.email,
          'fullName': googleUser.displayName ?? 'Google User',
          'providerId': googleUser.id,
          'accessToken': googleAuth.accessToken,
          'idToken': googleAuth.idToken,
          'provider': 'GOOGLE',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storageService.saveTokens(data['accessToken'], data['refreshToken']);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        _showError('Backend error: ${response.body}');
      }
    } catch (e) {
      _showError('Google login error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================== LOGIN FACEBOOK ==================
  Future<void> _loginWithFacebook() async {
    if (kIsWeb) {
      final Uri url = Uri.parse('${ApiConfig.baseUrl}/oauth2/authorization/facebook');
      await launchUrl(url, webOnlyWindowName: '_blank');
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // ⭐ FIX 2: Bỏ 'email' khỏi permissions, chỉ dùng 'public_profile'
      await FacebookAuth.instance.logOut(); // signOut trước
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile'],
      );

      if (result.status != LoginStatus.success) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final userData = await FacebookAuth.instance.getUserData(
        fields: "name,picture.width(200)",  // ⭐ Bỏ email khỏi fields
      );

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/oauth2/facebook'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': '${userData['id']}@facebook.com', // ⭐ Dùng id thay email
          'fullName': userData['name'] ?? 'Facebook User',
          'providerId': userData['id'],
          'accessToken': result.accessToken!.tokenString,
          'provider': 'FACEBOOK',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storageService.saveTokens(data['accessToken'], data['refreshToken']);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        _showError('Backend error: ${response.body}');
      }
    } catch (e) {
      _showError('Facebook login error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text('Login', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                CustomTextField(
                  label: 'Email',
                  hint: 'example@gmail.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!value.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your password';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?', style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(text: 'LOGIN', onPressed: _login, isLoading: _isLoading),
                const SizedBox(height: 40),
                const Center(child: Text('Or login with', style: TextStyle(color: Colors.grey))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialButton(
                      icon: 'assets/images/gg.jpg',
                      text: 'Google',
                      onPressed: _loginWithGoogle,
                    ),
                    const SizedBox(width: 16),
                    SocialButton(
                      icon: 'assets/images/fb.png',
                      text: 'Facebook',
                      onPressed: _loginWithFacebook,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}