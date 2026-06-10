// lib/services/favorites_manager.dart
//
// FavoritesManager v3: lưu thêm size đã chọn khi add favorite.
// - Khi user chưa login → hoạt động in-memory
// - Khi user đã login và có customerId → đồng bộ với backend

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Thông tin một mục trong danh sách yêu thích, bao gồm product + size đã chọn.
class FavoriteItem {
  final Map<String, dynamic> product;
  final String? selectedSize;
  final String? selectedColor;

  FavoriteItem({
    required this.product,
    this.selectedSize,
    this.selectedColor,
  });

  /// Key duy nhất để phân biệt (product id + size)
  String get key {
    final id = product['id'] as String?;
    final base = id ?? '${product['brand']}__${product['name']}';
    return selectedSize != null ? '${base}__$selectedSize' : base;
  }

  FavoriteItem copyWith({
    Map<String, dynamic>? product,
    String? selectedSize,
    String? selectedColor,
  }) =>
      FavoriteItem(
        product: product ?? this.product,
        selectedSize: selectedSize ?? this.selectedSize,
        selectedColor: selectedColor ?? this.selectedColor,
      );
}

class FavoritesManager {
  FavoritesManager._();
  static final FavoritesManager instance = FavoritesManager._();

  /// Danh sách FavoriteItem đầy đủ (có product + size)
  final ValueNotifier<List<FavoriteItem>> favoriteItems =
      ValueNotifier<List<FavoriteItem>>([]);

  /// Set chứa productId (String UUID) từ server, hoặc key local nếu chưa login
  /// (giữ lại cho backward-compat với code cũ)
  final ValueNotifier<Set<String>> favorites = ValueNotifier<Set<String>>({});

  String? _customerId;

  // Gọi sau khi login thành công để load favorites từ server
  Future<void> init(String customerId) async {
    _customerId = customerId;
    await _loadFromServer();
  }

  // Reset khi logout
  void reset() {
    _customerId = null;
    favorites.value = {};
    favoriteItems.value = [];
  }

  // Key local (dùng khi chưa có backend productId)
  static String keyOf(Map<String, dynamic> product) =>
      '${product['brand']}__${product['name']}';

  bool isFavorite(Map<String, dynamic> product) {
    final id = product['id'] as String?;
    if (id != null) return favorites.value.contains(id);
    return favorites.value.contains(keyOf(product));
  }

  /// Thêm vào favorites với size và color đã chọn
  Future<void> addWithSize(
    Map<String, dynamic> product, {
    String? selectedSize,
    String? selectedColor,
  }) async {
    final id = product['id'] as String?;
    final key = id ?? keyOf(product);

    // Cập nhật favoriteItems
    final newItem = FavoriteItem(
      product: Map<String, dynamic>.from(product),
      selectedSize: selectedSize,
      selectedColor: selectedColor,
    );
    final updatedItems = List<FavoriteItem>.from(favoriteItems.value);
    // Remove item cũ của product này (nếu có) để thay bằng cái mới
    updatedItems.removeWhere((i) {
      final iId = i.product['id'] as String?;
      final iKey = iId ?? keyOf(i.product);
      return iKey == key;
    });
    updatedItems.add(newItem);
    favoriteItems.value = updatedItems;

    // Cập nhật Set favorites
    final updated = Set<String>.from(favorites.value)..add(key);
    favorites.value = updated;

    // Sync với server
    if (_customerId != null && id != null) {
      try {
        final token = await _getToken();
        final headers = {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        };
        await http.post(
          Uri.parse(ApiConfig.favoriteItem(_customerId!, id)),
          headers: headers,
        );
      } catch (e) {
        debugPrint('FavoritesManager addWithSize error: $e');
      }
    }
  }

  Future<void> toggle(Map<String, dynamic> product) async {
    final id = product['id'] as String?;
    final key = id ?? keyOf(product);
    final wasInFav = favorites.value.contains(key);

    // Optimistic update
    final updatedSet = Set<String>.from(favorites.value);
    final updatedItems = List<FavoriteItem>.from(favoriteItems.value);

    if (wasInFav) {
      updatedSet.remove(key);
      updatedItems.removeWhere((i) {
        final iId = i.product['id'] as String?;
        final iKey = iId ?? keyOf(i.product);
        return iKey == key;
      });
    } else {
      updatedSet.add(key);
      updatedItems.add(FavoriteItem(product: Map<String, dynamic>.from(product)));
    }
    favorites.value = updatedSet;
    favoriteItems.value = updatedItems;

    // Sync với server nếu có customerId và productId
    if (_customerId != null && id != null) {
      try {
        final token = await _getToken();
        final headers = {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        };
        final url = Uri.parse(ApiConfig.favoriteItem(_customerId!, id));

        if (wasInFav) {
          await http.delete(url, headers: headers);
        } else {
          await http.post(url, headers: headers);
        }
      } catch (e) {
        // Rollback nếu API lỗi
        favorites.value = Set<String>.from(favorites.value)
          ..remove(key)
          ..addAll(wasInFav ? [key] : []);
        debugPrint('FavoritesManager toggle error: $e');
      }
    }
  }

  Future<void> _loadFromServer() async {
    if (_customerId == null) return;
    try {
      final token = await _getToken();
      final res = await http.get(
        Uri.parse(ApiConfig.favorites(_customerId!)),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final ids = data
            .map((f) => f['product']?['id'] as String?)
            .whereType<String>()
            .toSet();
        favorites.value = ids;

        // Build favoriteItems from server data
        final items = data.map((f) {
          final prod = Map<String, dynamic>.from(f['product'] as Map? ?? {});
          return FavoriteItem(product: prod);
        }).toList();
        favoriteItems.value = items;
      }
    } catch (e) {
      debugPrint('FavoritesManager load error: $e');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}