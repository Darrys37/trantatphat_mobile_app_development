// lib/services/product_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Singleton service: fetch products từ backend.
// • Khi backend CHẠY  → products.value = danh sách sản phẩm, isLoading = false
// • Khi backend TẮT   → isLoading = true (giữ loading spinner)
//                        connectionFailed = true sau khi timeout/lỗi
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();

  // ── State ──────────────────────────────────────────────────────────────────
  final ValueNotifier<List<Map<String, dynamic>>> products =
      ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(true);

  /// true khi backend không thể kết nối (timeout / lỗi mạng / server down)
  final ValueNotifier<bool> connectionFailed = ValueNotifier(false);

  bool _fetching = false;

  // ── Public ─────────────────────────────────────────────────────────────────

  /// Gọi một lần khi app khởi động.
  Future<void> init() => _fetch();

  /// Kéo-để-refresh hoặc retry thủ công.
  Future<void> refresh() => _fetch();

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _fetch() async {
    if (_fetching) return;
    _fetching = true;
    isLoading.value = true;
    connectionFailed.value = false;

    try {
      final res = await http
          .get(Uri.parse(ApiConfig.products))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final raw = jsonDecode(res.body) as List<dynamic>;

        final list = raw.map<Map<String, dynamic>>((e) {
          final m = e as Map<String, dynamic>;
          final salePrice    = _toDouble(m['sale_price']);
          final comparePrice = _toDouble(m['compare_price']);
          int? discount;
          if (comparePrice != null && comparePrice > 0 && salePrice != null) {
            discount = (((comparePrice - salePrice) / comparePrice) * 100).round();
          }
          return {
            'id'         : m['id']?.toString() ?? '',
            'name'       : m['product_name'] ?? '',
            'brand'      : m['product_type'] ?? '',
            'price'      : salePrice ?? 0,
            'oldPrice'   : comparePrice,
            'discount'   : discount,
            'image'      : m['thumbnail'] ?? '',
            'rating'     : 4.0,
            'reviews'    : m['quantity'] ?? 0,
            'isFavorite' : false,
            'description': m['short_description'] ?? m['product_description'] ?? '',
            'slug'       : m['slug'] ?? '',
          };
        }).toList();

        products.value = list;
        isLoading.value = false;
        connectionFailed.value = false;
      } else {
        debugPrint('ProductService: server error ${res.statusCode}');
        products.value = [];
        isLoading.value = true;
        connectionFailed.value = true;
      }
    } on TimeoutException {
      debugPrint('ProductService: request timed out');
      products.value = [];
      isLoading.value = true;
      connectionFailed.value = true;
    } catch (e) {
      debugPrint('ProductService: fetch error — $e');
      products.value = [];
      isLoading.value = true;
      connectionFailed.value = true;
    } finally {
      _fetching = false;
    }
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}