import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'auth_service.dart'; // 1. Nhúng file logic mạng không dây vào đây
import 'login_screen.dart'; // Nhúng vào để phục vụ chuyển màn hình nếu cần
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Bộ điều khiển để lấy dữ liệu từ các ô nhập
  final TextEditingController _nameController = TextEditingController(text: '');
  final TextEditingController _emailController = TextEditingController(text: '');
  final TextEditingController _passwordController = TextEditingController();

  // Khởi tạo lớp dịch vụ gọi API Spring Boot
  final AuthService _authService = AuthService();

  // Biến trạng thái dùng để hiển thị vòng xoay loading khi đang gọi API
  bool _isLoading = false;

  // 2. HÀM XỬ LÝ LOGIC ĐĂNG KÝ TÀI KHOẢN KHI ẤN NÚT
  void _handleSignUp() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Kiểm tra nhanh dữ liệu đầu vào (Validation)
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields!', Colors.orange);
      return;
    }

    if (!email.contains('@')) {
      _showSnackBar('Invalid email format!', Colors.orange);
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Password must be at least 6 characters!', Colors.orange);
      return;
    }

    // Bật vòng xoay loading
    setState(() {
      _isLoading = true;
    });

    // Gọi API Đăng ký không dây xuống server Spring Boot máy tính
    String? responseResult = await _authService.register(name, email, password);

    // Tắt vòng xoay loading
    setState(() {
      _isLoading = false;
    });

    if (responseResult == "SUCCESS") {
      // ĐĂNG KÝ THÀNH CÔNG
      _showSnackBar('Account registered successfully!', Colors.green);
      
      // Chờ hiển thị SnackBar xong rồi tự động chuyển hướng người dùng về màn hình Login
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      });
    } else {
      // ĐĂNG KÝ THẤT BẠI (Email đã tồn tại hoặc lỗi mất kết nối Wi-Fi)
      _showSnackBar(responseResult ?? 'Registration failed! Network error.', Colors.red);
    }
  }

  // HÀM XỬ LÝ ĐĂNG KÝ BẰNG GOOGLE
  void _handleGoogleSignUp() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: "366965497145-gc70qllj776gq37d7c62k2hdut1jb6sm.apps.googleusercontent.com",
      scopes: ['email', 'profile'],
    );

    try {
      // Bắt buộc hiển thị bảng chọn tài khoản
      try {
        await googleSignIn.signOut();
      } catch (e) {
        print("Lỗi khi đăng xuất cũ: $e");
      }
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Hiển thị hộp thoại xác nhận trước khi tiếp tục
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
            title: const Text('Confirm Account Creation'),
            content: Text('Are you sure you want to create an account with ${googleUser.email}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('No', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Yes', style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
      );

      // Nếu người dùng chọn Không hoặc bấm ra ngoài hộp thoại
      if (confirm != true) {
        try {
          await googleSignIn.signOut(); // Đăng xuất lại để dọn dẹp
        } catch (e) {
          print("Lỗi dọn dẹp đăng xuất: $e");
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        var result = await _authService.registerWithGoogle(idToken);

        setState(() { _isLoading = false; });

        if (result is Map) {
          _showSnackBar('Registration successful, please login!', Colors.green);
          
          // Chuyển sang màn hình Đăng nhập
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          });
        } else if (result is String) {
          _showSnackBar(result, Colors.red);
        } else {
          _showSnackBar('Server rejected Google authentication!', Colors.red);
        }
      } else {
        setState(() { _isLoading = false; });
      }
    } catch (error) {
      setState(() { _isLoading = false; });
      _showSnackBar('Google SDK error: $error', Colors.red);
    }
  }

  // HÀM XỬ LÝ ĐĂNG KÝ BẰNG FACEBOOK
  void _handleFacebookSignUp() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        
        setState(() { _isLoading = true; });

        var apiResult = await _authService.registerWithFacebook(accessToken.tokenString);

        setState(() { _isLoading = false; });

        if (apiResult is Map) {
          String name = apiResult['name'];
          _showSnackBar('Facebook registration successful! Welcome $name. Please login.', Colors.green);
          
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          });
        } else if (apiResult is String) {
          _showSnackBar(apiResult, Colors.red);
        } else {
          _showSnackBar('Server rejected Facebook authentication!', Colors.red);
        }
      } else if (result.status == LoginStatus.cancelled) {
        // Hủy
      } else {
        _showSnackBar('Facebook login error: ${result.message}', Colors.red);
      }
    } catch (error) {
      setState(() { _isLoading = false; });
      _showSnackBar('Facebook SDK error: $error', Colors.red);
    }
  }

  // Hàm tiện ích dùng để hiển thị thông báo nhanh (SnackBar)
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Màu nền xám trắng chuẩn ảnh
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Ẩn nút back mặc định nếu có
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                // Tiêu đề lớn "Sign up"
                const Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),

                // --- Ô NHẬP TÊN (NAME) ---
                _buildInputField(
                  label: 'Name',
                  controller: _nameController,
                  suffixIcon: const Icon(Icons.check, color: Colors.green, size: 22),
                ),
                const SizedBox(height: 16),

                // --- Ô NHẬP EMAIL ---
                _buildInputField(
                  label: 'Email',
                  controller: _emailController,
                ),
                const SizedBox(height: 16),

                // --- Ô NHẬP PASSWORD ---
                _buildInputField(
                  label: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                ),
                const SizedBox(height: 16),

                // --- DÒNG CHỮ CHUYỂN SANG MÀN HÌNH LOGIN ---
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      // Chuyển sang màn hình Đăng nhập (Login)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Icon(
                          Icons.arrow_right_alt,
                          color: Color(0xFFDB3022), // Mũi tên màu đỏ
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // --- NÚT SIGN UP ĐỎ ---
                Container(
                  width: double.infinity,
                  height: 48, // Độ cao vừa vặn của nút chính
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDB3022).withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    // Nếu hệ thống đang tải, khóa nút (null). Ngược lại, cho phép bấm.
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDB3022), // Màu đỏ chuẩn UI
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'SIGN UP',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const Spacer(), // Đẩy phần Mạng Xã Hội xuống cuối cùng

                // --- ĐĂNG KÝ BẰNG MẠNG XÃ HỘI ---
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Or sign up with social account',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                            isGoogle: true, 
                            onPressed: _isLoading ? () {} : _handleGoogleSignUp,
                          ),
                          const SizedBox(width: 20),
                          _buildSocialButton(
                            isGoogle: false, 
                            onPressed: _isLoading ? () {} : _handleFacebookSignUp,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
            ),
          ],
        ),
      ),
    );
  }

  // HÀM TẠO Ô NHẬP LIỆU (TEXTFIELD) CUSTOM ĐỔ BÓNG NHƯ TRONG ẢNH
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    Widget? suffixIcon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4), // Góc bo nhẹ 4px theo ảnh mẫu
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Đổ bóng khối cực kỳ nhẹ
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black38, // Chữ nhãn nhỏ mờ phía trên
              fontWeight: FontWeight.w400,
            ),
          ),
          TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true, // Thu gọn khoảng cách mặc định thừa thãi
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              border: InputBorder.none, // Tắt đường viền gạch dưới mặc định
              suffixIcon: suffixIcon,
              suffixIconConstraints: const BoxConstraints(
                minHeight: 24,
                minWidth: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HÀM TẠO NÚT BẤM GOOGLE / FACEBOOK
  Widget _buildSocialButton({required bool isGoogle, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 92,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isGoogle
              ? Image.asset(
                  'assets/gg.jpg', // Gọi đúng file ảnh từ thư mục assets của bạn
                  width: 24,        // Giới hạn kích thước vừa vặn với ô bấm
                  height: 24,
                  fit: BoxFit.contain,
                )
              : const Icon(
                  Icons.facebook, 
                  color: Color(0xFF3B5998), 
                  size: 32,
                ),
        ),
      ),
    );
  }
}