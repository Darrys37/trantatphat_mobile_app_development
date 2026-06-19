import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:font_end/auth_service.dart';
import 'package:font_end/models/user_address.dart';
import 'package:font_end/models/payment_card.dart';
import 'package:font_end/models/delivery_method.dart';

class CheckoutService extends ChangeNotifier {
  static const String baseUrl = "http://192.168.1.201:8080/api/checkout";
  
  List<UserAddress> _addresses = [];
  List<PaymentCard> _paymentCards = [];
  List<DeliveryMethod> _deliveryMethods = [];
  bool useCashOnDelivery = false;

  List<UserAddress> get addresses => _addresses;
  List<PaymentCard> get paymentCards => _paymentCards;
  List<DeliveryMethod> get deliveryMethods => _deliveryMethods;

  UserAddress? get defaultAddress => _addresses.isNotEmpty 
      ? _addresses.firstWhere((a) => a.isDefault, orElse: () => _addresses.first) 
      : null;

  PaymentCard? get defaultPaymentCard => _paymentCards.isNotEmpty 
      ? _paymentCards.firstWhere((p) => p.isDefault, orElse: () => _paymentCards.first) 
      : null;

  void setCashOnDelivery(bool value) {
    useCashOnDelivery = value;
    notifyListeners();
  }

  Future<void> fetchCheckoutData() async {
    if (AuthService.jwtToken == null) return;
    try {
      final headers = {
        "Authorization": "Bearer ${AuthService.jwtToken!}",
      };

      final addrRes = await http.get(Uri.parse('$baseUrl/addresses'), headers: headers);
      final cardsRes = await http.get(Uri.parse('$baseUrl/payment-cards'), headers: headers);
      final delRes = await http.get(Uri.parse('$baseUrl/delivery-methods'), headers: headers);

      final responses = [addrRes, cardsRes, delRes];

      if (responses[0].statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(responses[0].bodyBytes));
        _addresses = body.map((item) => UserAddress.fromJson(item)).toList();
      }
      if (responses[1].statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(responses[1].bodyBytes));
        final List<PaymentCard> allCards = body.map((item) => PaymentCard.fromJson(item)).toList();
        final Map<String, PaymentCard> uniqueCards = {};
        for (var card in allCards) {
          uniqueCards[card.cardNumber] = card;
        }
        _paymentCards = uniqueCards.values.toList();
      }
      if (responses[2].statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(responses[2].bodyBytes));
        _deliveryMethods = body.map((item) => DeliveryMethod.fromJson(item)).toList();
      }
      notifyListeners();
    } catch (e) {
      print("Lỗi tải dữ liệu thanh toán: $e");
    }
  }

  Future<void> addPaymentCard(PaymentCard card) async {
    if (AuthService.jwtToken == null) return;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment-cards'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "cardHolderName": card.cardHolderName,
          "cardNumber": card.cardNumber,
          "expiryDate": card.expiryDate,
          "brand": card.brand,
          "isDefault": card.isDefault,
        }),
      );
      if (response.statusCode == 200) {
        await fetchCheckoutData();
      }
    } catch (e) {
      print("Lỗi thêm thẻ: $e");
    }
  }

  Future<void> setDefaultPaymentCard(String cardId) async {
    if (AuthService.jwtToken == null) return;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/payment-cards/$cardId/default'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );
      if (response.statusCode == 200) {
        await fetchCheckoutData();
      }
    } catch (e) {
      print("Lỗi đặt thẻ mặc định: $e");
    }
  }

  Future<void> addAddress(UserAddress address) async {
    if (AuthService.jwtToken == null) return;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addresses'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "fullName": address.fullName,
          "address": address.address,
          "city": address.city,
          "state": address.state,
          "zipCode": address.zipCode,
          "country": address.country,
          "isDefault": address.isDefault,
        }),
      );
      if (response.statusCode == 200) {
        await fetchCheckoutData();
      }
    } catch (e) {
      print("Lỗi thêm địa chỉ: $e");
    }
  }

  Future<void> updateAddress(String id, UserAddress address) async {
    if (AuthService.jwtToken == null) return;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/addresses/$id'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "fullName": address.fullName,
          "address": address.address,
          "city": address.city,
          "state": address.state,
          "zipCode": address.zipCode,
          "country": address.country,
          "isDefault": address.isDefault,
        }),
      );
      if (response.statusCode == 200) {
        await fetchCheckoutData();
      }
    } catch (e) {
      print("Lỗi sửa địa chỉ: $e");
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    if (AuthService.jwtToken == null) return;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/addresses/$addressId/default'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );
      if (response.statusCode == 200) {
        await fetchCheckoutData();
      }
    } catch (e) {
      print("Lỗi đặt địa chỉ mặc định: $e");
    }
  }

  Future<void> deleteAddress(String addressId) async {
    if (AuthService.jwtToken == null) return;
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/addresses/$addressId'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );
      if (response.statusCode == 200) {
        await fetchCheckoutData();
      }
    } catch (e) {
      print("Lỗi xóa địa chỉ: $e");
    }
  }

  Future<void> deletePaymentCard(String cardId) async {
    if (AuthService.jwtToken == null) return;
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/payment-cards/$cardId'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );
      if (response.statusCode == 200) {
        await fetchCheckoutData();
      }
    } catch (e) {
      print("Lỗi xóa thẻ: $e");
    }
  }

  Future<bool> submitOrder(String deliveryMethodId, double totalAmount) async {
    if (AuthService.jwtToken == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit-order'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "deliveryMethodId": deliveryMethodId,
          "orderTotal": totalAmount,
          "paymentMethod": useCashOnDelivery ? "Cash on Delivery" : (defaultPaymentCard?.cardNumber ?? "Credit Card"),
        }),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("Lỗi đặt hàng: $e");
    }
    return false;
  }

  Future<List<dynamic>> fetchOrders() async {
    if (AuthService.jwtToken == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("Lỗi lấy danh sách đơn hàng: $e");
    }
    return [];
  }

  Future<dynamic> fetchOrderDetails(String orderId) async {
    if (AuthService.jwtToken == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("Lỗi lấy chi tiết đơn hàng: $e");
    }
    return null;
  }

  Future<bool> cancelOrder(String orderId) async {
    if (AuthService.jwtToken == null) return false;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/cancel'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("Lỗi hủy đơn hàng: $e");
    }
    return false;
  }
}

final CheckoutService checkoutService = CheckoutService();
