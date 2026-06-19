import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:font_end/auth_service.dart';
import 'package:font_end/models/cart_item.dart';
import 'package:font_end/models/coupon.dart';

class CartService extends ChangeNotifier {
  static const String baseUrl = "http://192.168.1.201:8080/api/cart";
  List<CartItem> _items = [];
  Coupon? _appliedCoupon;
  List<Coupon> _availableCoupons = [];

  List<CartItem> get items => _items;
  Coupon? get appliedCoupon => _appliedCoupon;
  List<Coupon> get availableCoupons => _availableCoupons;

  double get totalAmount {
    double sum = _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
    if (_appliedCoupon != null) {
      if (_appliedCoupon!.discountType == 'PERCENTAGE') {
        sum = sum * (1 - _appliedCoupon!.discountValue / 100);
      } else {
        sum = sum - _appliedCoupon!.discountValue;
      }
      if (sum < 0) sum = 0;
    }
    return sum;
  }

  Future<void> fetchCart() async {
    if (AuthService.jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        _items = body.map((dynamic item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi tải giỏ hàng: $e");
    }
  }

  Future<bool> addToCart(String productId, String color, String size, int quantity) async {
    if (AuthService.jwtToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
        body: jsonEncode({
          "productId": productId,
          "color": color,
          "size": size,
          "quantity": quantity,
        }),
      );

      if (response.statusCode == 200) {
        await fetchCart(); // Refresh cart
        return true;
      }
    } catch (e) {
      print("Lỗi thêm vào giỏ: $e");
    }
    return false;
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (AuthService.jwtToken == null) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update/$cartItemId?quantity=$quantity'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );

      if (response.statusCode == 200) {
        await fetchCart(); // Refresh cart
      }
    } catch (e) {
      print("Lỗi cập nhật số lượng: $e");
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    if (AuthService.jwtToken == null) return;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/remove/$cartItemId'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );

      if (response.statusCode == 200) {
        await fetchCart(); // Refresh cart
      }
    } catch (e) {
      print("Lỗi xóa khỏi giỏ: $e");
    }
  }
  Future<void> fetchAppliedCoupon() async {
    if (AuthService.jwtToken == null) return;
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.201:8080/api/coupons/applied'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        _appliedCoupon = Coupon.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        notifyListeners();
      } else {
        _appliedCoupon = null;
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi tải mã giảm giá đã áp dụng: $e");
    }
  }

  Future<void> fetchAvailableCoupons() async {
    if (AuthService.jwtToken == null) return;
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.201:8080/api/coupons'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        _availableCoupons = body.map((dynamic item) => Coupon.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi tải danh sách mã giảm giá: $e");
    }
  }

  Future<bool> applyCoupon(String code) async {
    if (AuthService.jwtToken == null) return false;
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.201:8080/api/coupons/apply?code=$code'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );
      if (response.statusCode == 200) {
        await fetchAppliedCoupon();
        return true;
      }
    } catch (e) {
      print("Lỗi áp dụng mã giảm giá: $e");
    }
    return false;
  }

  Future<void> removeCoupon() async {
    if (AuthService.jwtToken == null) return;
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.1.201:8080/api/coupons/remove'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );
      if (response.statusCode == 200) {
        _appliedCoupon = null;
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi xóa mã giảm giá: $e");
    }
  }
}

final CartService cartService = CartService();
