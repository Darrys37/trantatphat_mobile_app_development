import 'package:flutter/material.dart';
import '../services/favorites_manager.dart';
import '../services/bag_manager.dart';
import 'product_data.dart';
import 'rating_reviews_screen.dart';

// ─── Favorites Store (simple in-memory) ──────────────────────────────────────
class FavoritesStore {
  static final List<Map<String, dynamic>> items = [];

  static bool isFavorite(String name) =>
      items.any((p) => p['name'] == name);

  static void toggle(Map<String, dynamic> product) {
    if (isFavorite(product['name'])) {
      items.removeWhere((p) => p['name'] == product['name']);
    } else {
      items.add(Map<String, dynamic>.from(product));
    }
  }
}

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  String _selectedColor = 'Black';
  bool _showSizeSheet = false;
  bool _showFavSheet = false;
  int _currentImage = 0;

  static const _colors = ['Black', 'White', 'Red', 'Blue'];

  bool get _isFav => FavoritesManager.instance.isFavorite(widget.product);

  List<String> get _images {
    final base = widget.product['image'] as String;
    return [base, base, base];
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(p['name'] ?? '',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Stack(children: [
        SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Image carousel ──────────────────────────────────────────────
            SizedBox(
              height: 340,
              child: Stack(children: [
                PageView.builder(
                  onPageChanged: (i) => setState(() => _currentImage = i),
                  itemCount: _images.length,
                  itemBuilder: (_, i) => Image.network(
                    _images[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (_, child, prog) => prog == null ? child
                        : Container(color: Colors.grey[100],
                            child: const Center(child: CircularProgressIndicator(
                              color: Color(0xFFE53935), strokeWidth: 2))),
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.image_not_supported_outlined,
                        size: 60, color: Colors.grey)),
                  ),
                ),
                // Discount badge
                if (p['discount'] != null)
                  Positioned(top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(5)),
                      child: Text('-${p['discount']}%',
                        style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 13)),
                    )),
                // Page dots
                Positioned(
                  bottom: 12, left: 0, right: 0,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_images.length, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentImage == i ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentImage == i ? Colors.black : Colors.grey[300],
                        borderRadius: BorderRadius.circular(3)),
                    ))),
                ),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Size & Color dropdowns
                Row(children: [
                  _DropdownPill(
                    label: _selectedSize ?? 'Size',
                    onTap: () => setState(() { _showSizeSheet = true; _showFavSheet = false; }),
                  ),
                  const SizedBox(width: 10),
                  _DropdownPill(
                    label: _selectedColor,
                    onTap: () => _showColorPicker(),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (_isFav) {
                        FavoritesManager.instance.toggle(p);
                        setState(() {});
                      } else {
                        setState(() { _showFavSheet = true; _showSizeSheet = false; });
                      }
                    },
                    child: Icon(
                      _isFav ? Icons.favorite : Icons.favorite_border,
                      color: _isFav ? const Color(0xFFE53935) : Colors.grey,
                      size: 26,
                    ),
                  ),
                ]),
                const SizedBox(height: 14),

                // Brand & Name
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p['brand'] ?? '',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(p['name'] ?? '',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ]),
                  Text('\$${p['price']}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 8),

                GestureDetector(
                  onTap: () async {
                    await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => RatingReviewsScreen(product: p)));
                    setState(() {});
                  },
                  child: Row(children: [
                    ...List.generate(5, (i) {
                      final r = ReviewsManager.instance.getAverageRating(p);
                      if (i < r.floor()) return const Icon(Icons.star, color: Colors.amber, size: 16);
                      if (i < r) return const Icon(Icons.star_half, color: Colors.amber, size: 16);
                      return const Icon(Icons.star_border, color: Colors.amber, size: 16);
                    }),
                    const SizedBox(width: 6),
                    Text('(${ReviewsManager.instance.getReviewCount(p)})',
                      style: const TextStyle(fontSize: 13, color: Color(0xFFE53935),
                        decoration: TextDecoration.underline)),
                  ]),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  p['description'] as String? ??
                    'Short dress in soft cotton jersey with decorative buttons down the front and a wide, frill-trimmed neckline with a drawstring.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 20),

                // Shipping info & Support
                _InfoTile(label: 'Shipping info'),
                _InfoTile(label: 'Support'),
                const SizedBox(height: 24),

                // You can also like this
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('You can also like this',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  Text('12 items', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  height: 240,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: () {
                      // Collect all products from genderProducts, excluding current one
                      final current = widget.product;
                      final currentName = current['name'];
                      final allItems = <Map<String, dynamic>>[];
                      for (final gender in genderProducts.values) {
                        for (final items in gender.values) {
                          allItems.addAll(items.where((p) => p['name'] != currentName));
                        }
                      }
                      allItems.shuffle();
                      return allItems.take(6).map((rp) => _RelatedCard(product: rp)).toList();
                    }(),
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ]),
        ),

        // Dim overlay
        if (_showSizeSheet || _showFavSheet)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() { _showSizeSheet = false; _showFavSheet = false; }),
              child: Container(color: Colors.black45),
            ),
          ),

        // Size / Favorites bottom sheet
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: _showSizeSheet
            ? _SizeSheet(
                selectedSize: _selectedSize,
                onSelect: (s) => setState(() => _selectedSize = s),
                onAddToCart: () {
                  BagManager.instance.add(
                    p,
                    selectedSize: _selectedSize,
                    selectedColor: _selectedColor,
                  );
                  setState(() => _showSizeSheet = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added to cart!${_selectedSize != null ? ' Size: $_selectedSize' : ''}'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                buttonLabel: 'ADD TO CART',
              )
            : _showFavSheet
              ? _SizeSheet(
                  selectedSize: _selectedSize,
                  onSelect: (s) => setState(() => _selectedSize = s),
                  onAddToCart: () async {
                    await FavoritesManager.instance.addWithSize(
                      p,
                      selectedSize: _selectedSize,
                      selectedColor: _selectedColor,
                    );
                    setState(() { _showFavSheet = false; });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added to favorites!${_selectedSize != null ? ' Size: $_selectedSize' : ''}'),
                          backgroundColor: const Color(0xFFE53935),
                        ),
                      );
                    }
                  },
                  buttonLabel: 'ADD TO FAVORITES',
                )
              : SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: ElevatedButton(
                      onPressed: () => setState(() => _showSizeSheet = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('ADD TO CART',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                          fontSize: 15, letterSpacing: 1)),
                    ),
                  ),
                ),
        ),
      ]),
    );
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select color',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(spacing: 12, children: _colors.map((c) {
              final sel = _selectedColor == c;
              return GestureDetector(
                onTap: () { setState(() => _selectedColor = c); Navigator.pop(context); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? Colors.black : Colors.white,
                    border: Border.all(color: sel ? Colors.black : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(c, style: TextStyle(
                    color: sel ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500)),
                ),
              );
            }).toList()),
            const SizedBox(height: 16),
          ]),
      ),
    );
  }
}

// ─── Related products data ────────────────────────────────────────────────────
const _relatedProducts = [
  {'name': 'Evening Dress', 'brand': 'Dorothy Perkins', 'price': 12, 'oldPrice': 15,
    'discount': -20, 'label': null,
    'image': 'https://images.pexels.com/photos/1755428/pexels-photo-1755428.jpeg?auto=compress&w=300'},
  {'name': 'T-Shirt Sailing', 'brand': 'Mango Boy', 'price': 10, 'oldPrice': null,
    'discount': null, 'label': 'NEW',
    'image': 'https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg?auto=compress&w=300'},
  {'name': 'T-Shirt', 'brand': 'Mango', 'price': 10, 'oldPrice': null,
    'discount': null, 'label': 'NEW',
    'image': 'https://images.pexels.com/photos/1300550/pexels-photo-1300550.jpeg?auto=compress&w=300'},
];

class _RelatedCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _RelatedCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(product['image'],
                width: 140, height: 140, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 140, height: 140, color: Colors.grey[100])),
            ),
            if (product['discount'] != null)
              Positioned(top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(4)),
                  child: Text('${product['discount']}%',
                    style: const TextStyle(color: Colors.white, fontSize: 10,
                      fontWeight: FontWeight.bold)),
                )),
            if (product['label'] != null)
              Positioned(top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.black,
                    borderRadius: BorderRadius.circular(4)),
                  child: Text(product['label'],
                    style: const TextStyle(color: Colors.white, fontSize: 10,
                      fontWeight: FontWeight.bold)),
                )),
            Positioned(top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.favorite_border, size: 14, color: Colors.grey),
              )),
          ]),
          const SizedBox(height: 6),
          Text(product['brand'] ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          Text(product['name'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Row(
            children: [
              ...List.generate(5, (i) {
                final rating = ReviewsManager.instance.getAverageRating(product);
                if (i < rating.floor()) return const Icon(Icons.star, color: Colors.amber, size: 12);
                if (i < rating) return const Icon(Icons.star_half, color: Colors.amber, size: 12);
                return const Icon(Icons.star_border, color: Colors.amber, size: 12);
              }),
              const SizedBox(width: 4),
              Text('(${ReviewsManager.instance.getReviewCount(product)})',
                style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 4),
          Row(children: [
            if (product['oldPrice'] != null) ...[
              Text('${product['oldPrice']}\$',
                style: const TextStyle(decoration: TextDecoration.lineThrough,
                  color: Colors.grey, fontSize: 11)),
              const SizedBox(width: 4),
            ],
            Text('${product['price']}\$',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        ]),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _DropdownPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DropdownPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(width: 6),
        const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
      ]),
    ),
  );
}

class _InfoTile extends StatelessWidget {
  final String label;
  const _InfoTile({required this.label});

  @override
  Widget build(BuildContext context) => Column(children: [
    Divider(color: Colors.grey[200], height: 1),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
        const Spacer(),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ]),
    ),
  ]);
}

// ─── Size Sheet (shared for cart & favorites) ─────────────────────────────────
class _SizeSheet extends StatelessWidget {
  final String? selectedSize;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddToCart;
  final String buttonLabel;

  static const _sizes = ['XS', 'S', 'M', 'L', 'XL'];

  const _SizeSheet({
    required this.selectedSize, required this.onSelect,
    required this.onAddToCart, required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SafeArea(top: false, child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Select size',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 12,
            children: _sizes.map((s) {
              final sel = selectedSize == s;
              return GestureDetector(
                onTap: () => onSelect(s),
                child: Container(
                  width: 68, height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: sel ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: sel ? Colors.black : Colors.grey[300]!),
                  ),
                  child: Text(s, style: TextStyle(
                    color: sel ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500)),
                ),
              );
            }).toList()),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Size info', style: TextStyle(fontSize: 14)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ]),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAddToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(buttonLabel,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                  fontSize: 15, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      )),
    );
  }
}