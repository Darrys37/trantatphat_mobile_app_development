// lib/services/bag_manager.dart

import 'package:flutter/foundation.dart';

/// Một mục trong giỏ hàng.
class BagItem {
  final Map<String, dynamic> product;
  final String? selectedSize;
  final String? selectedColor;
  int quantity;

  BagItem({
    required this.product,
    this.selectedSize,
    this.selectedColor,
    this.quantity = 1,
  });

  String get key {
    final id = product['id'] as String?;
    final base = id ?? '${product['brand']}__${product['name']}';
    final sizePart = selectedSize != null ? '__$selectedSize' : '';
    final colorPart = selectedColor != null ? '__$selectedColor' : '';
    return '$base$sizePart$colorPart';
  }

  double get unitPrice => _parsePrice(product['price']);
  double get subtotal => unitPrice * quantity;

  static double _parsePrice(dynamic raw) {
    if (raw == null) return 0.0;
    if (raw is num) return raw.toDouble();
    final str = raw.toString().replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(str) ?? 0.0;
  }
}

class PromoCode {
  final String code;
  final double discountPercent;
  final double discountFlat;

  const PromoCode({
    required this.code,
    this.discountPercent = 0,
    this.discountFlat = 0,
  });
}

class BagManager {
  BagManager._();
  static final BagManager instance = BagManager._();

  // Promo codes hợp lệ — thêm/sửa tuỳ ý
  static const _validPromos = <String, PromoCode>{
    'mypromocode2020': PromoCode(code: 'mypromocode2020', discountPercent: 10),
    'summer2020':      PromoCode(code: 'summer2020',      discountPercent: 15),
    'SAVE22':          PromoCode(code: 'SAVE22',          discountPercent: 22),
    'SAVE10':          PromoCode(code: 'SAVE10',          discountPercent: 10),
    'SAVE20':          PromoCode(code: 'SAVE20',          discountPercent: 20),
    'FLAT50':          PromoCode(code: 'FLAT50',          discountFlat: 50),
  };

  // ── State ────────────────────────────────────────────────────────────────────

  final ValueNotifier<List<BagItem>> items = ValueNotifier<List<BagItem>>([]);

  String? appliedPromo;
  PromoCode? _activePromo;

  // ── Computed ─────────────────────────────────────────────────────────────────

  int get totalCount =>
      items.value.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      items.value.fold(0.0, (sum, item) => sum + item.subtotal);

  double get discountAmount {
    if (_activePromo == null) return 0.0;
    if (_activePromo!.discountPercent > 0) {
      return subtotal * _activePromo!.discountPercent / 100;
    }
    return _activePromo!.discountFlat;
  }

  /// Tổng sau giảm giá — bag_screen dùng bag.total
  double get total => (subtotal - discountAmount).clamp(0.0, double.infinity);

  /// Alias để tương thích nếu có chỗ dùng totalPrice
  double get totalPrice => total;

  // ── Actions ──────────────────────────────────────────────────────────────────

  void add(
    Map<String, dynamic> product, {
    String? selectedSize,
    String? selectedColor,
    int quantity = 1,
  }) {
    final current = List<BagItem>.from(items.value);
    final newItem = BagItem(
      product: product,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
      quantity: quantity,
    );

    final idx = current.indexWhere((i) => i.key == newItem.key);
    if (idx >= 0) {
      current[idx].quantity += quantity;
    } else {
      current.add(newItem);
    }
    items.value = current;
  }

  /// Xoá item theo index — bag_screen gọi bag.remove(i)
  void remove(int index) {
    final current = List<BagItem>.from(items.value);
    if (index < 0 || index >= current.length) return;
    current.removeAt(index);
    items.value = current;
  }

  /// Xoá item theo object (dùng nội bộ nếu cần)
  void removeItem(BagItem item) {
    items.value = items.value.where((i) => i.key != item.key).toList();
  }

  /// Cập nhật số lượng theo index — bag_screen gọi bag.updateQty(i, q)
  void updateQty(int index, int quantity) {
    if (index < 0 || index >= items.value.length) return;
    if (quantity <= 0) {
      remove(index);
      return;
    }
    final current = List<BagItem>.from(items.value);
    current[index].quantity = quantity;
    items.value = List<BagItem>.from(current);
  }

  /// Alias updateQuantity → updateQty để tương thích
  void updateQuantity(BagItem item, int quantity) {
    final idx = items.value.indexWhere((i) => i.key == item.key);
    if (idx >= 0) updateQty(idx, quantity);
  }

  /// Áp dụng mã promo. Trả về true nếu hợp lệ.
  bool applyPromo(String code) {
    final key = code.trim();
    // Tìm không phân biệt hoa/thường
    final entry = _validPromos.entries
        .where((e) => e.key.toLowerCase() == key.toLowerCase())
        .firstOrNull;

    if (entry == null) {
      appliedPromo = null;
      _activePromo = null;
      items.notifyListeners();
      return false;
    }
    appliedPromo = entry.value.code;
    _activePromo = entry.value;
    items.notifyListeners();
    return true;
  }

  void removePromo() {
    appliedPromo = null;
    _activePromo = null;
    items.notifyListeners();
  }

  void clear() {
    appliedPromo = null;
    _activePromo = null;
    items.value = [];
  }
}