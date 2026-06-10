import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  bool _showSizeSheet = false;

  static const _sizes = ['XS', 'S', 'M', 'L', 'XL'];

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Women's tops",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Stack(
                  children: [
                    Image.network(
                      product['image'],
                      width: double.infinity,
                      height: 380,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 380, color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.image, size: 80, color: Colors.grey)),
                      ),
                    ),
                    if (product['discount'] != null)
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${product['discount']}%',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product['reviews'] != null && product['reviews'] > 0)
                        Row(children: [
                          ...List.generate(5, (i) => Icon(
                            i < (product['rating'] as num).floor() ? Icons.star : Icons.star_border,
                            color: Colors.amber, size: 16,
                          )),
                          const SizedBox(width: 4),
                          Text('(${product['reviews']})', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        ]),
                      const SizedBox(height: 8),
                      Text(product['brand'] ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                      Text(product['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (product['oldPrice'] != null) ...[
                            Text('\$${product['oldPrice']}',
                              style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text('\$${product['price']}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),

          // Select Size Bottom Sheet (inline overlay)
          if (_showSizeSheet)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showSizeSheet = false),
                child: Container(color: Colors.black54),
              ),
            ),

          // Bottom: Add to cart button or size sheet
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _showSizeSheet
                ? _SizeSelectSheet(
                    selectedSize: _selectedSize,
                    onSelectSize: (s) => setState(() => _selectedSize = s),
                    onAddToCart: () {
                      setState(() => _showSizeSheet = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added to cart! Size: ${_selectedSize ?? "Not selected"}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  )
                : SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: ElevatedButton(
                        onPressed: () => setState(() => _showSizeSheet = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'SELECT SIZE',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Size Select Sheet ────────────────────────────────────────────────────────
class _SizeSelectSheet extends StatelessWidget {
  final String? selectedSize;
  final ValueChanged<String> onSelectSize;
  final VoidCallback onAddToCart;

  static const _sizes = ['XS', 'S', 'M', 'L', 'XL'];

  const _SizeSelectSheet({
    required this.selectedSize,
    required this.onSelectSize,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select size',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _sizes.map((s) {
                final sel = selectedSize == s;
                return GestureDetector(
                  onTap: () => onSelectSize(s),
                  child: Container(
                    width: 64,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: sel ? Colors.black : Colors.grey[300]!),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        color: sel ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Size info',
                style: TextStyle(color: Colors.black, decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'ADD TO CART',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
