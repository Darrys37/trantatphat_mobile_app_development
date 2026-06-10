import 'package:flutter/material.dart';
import '../services/bag_manager.dart';
import '../services/favorites_manager.dart';
import '../services/product_service.dart';
import 'product_data.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isGridView = false;
  String _selectedCategory = 'All';
  String _sortBy = 'Price: lowest to high';

  static const _categories = ['All', 'Summer', 'T-Shirts', 'Shirts', 'Pants', 'Shoes'];
  static const _sortOptions = [
    'Price: lowest to high',
    'Price: highest to low',
    'Newest first',
    'Most popular',
  ];

  @override
  void initState() {
    super.initState();
    FavoritesManager.instance.favoriteItems.addListener(_onChanged);
    FavoritesManager.instance.favorites.addListener(_onChanged);
    ProductService.instance.isLoading.addListener(_onChanged);
    ProductService.instance.products.addListener(_onChanged);
    ProductService.instance.connectionFailed.addListener(_onChanged);
  }

  @override
  void dispose() {
    FavoritesManager.instance.favoriteItems.removeListener(_onChanged);
    FavoritesManager.instance.favorites.removeListener(_onChanged);
    ProductService.instance.isLoading.removeListener(_onChanged);
    ProductService.instance.products.removeListener(_onChanged);
    ProductService.instance.connectionFailed.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  List<FavoriteItem> get _favoriteItems {
    final mgr = FavoritesManager.instance;
    final keys = mgr.favorites.value;
    if (keys.isEmpty) return [];

    // Build from favoriteItems if available
    if (mgr.favoriteItems.value.isNotEmpty) {
      final items = List<FavoriteItem>.from(mgr.favoriteItems.value);
      // Apply sort
      _sortItems(items);
      return items;
    }

    // Fallback: build từ ProductService (dữ liệu backend)
    final allProducts = ProductService.instance.products.value;
    final result = <FavoriteItem>[];
    for (final p in allProducts) {
      final key = (p['id'] as String?) ?? FavoritesManager.keyOf(p);
      if (keys.contains(key)) {
        result.add(FavoriteItem(product: Map<String, dynamic>.from(p)));
      }
    }
    _sortItems(result);
    return result;
  }

  void _sortItems(List<FavoriteItem> items) {
    if (_sortBy == 'Price: lowest to high') {
      items.sort((a, b) =>
          ((a.product['price'] as num?) ?? 0)
              .compareTo((b.product['price'] as num?) ?? 0));
    } else if (_sortBy == 'Price: highest to low') {
      items.sort((a, b) =>
          ((b.product['price'] as num?) ?? 0)
              .compareTo((a.product['price'] as num?) ?? 0));
    }
  }

  Future<void> _onRefresh() => ProductService.instance.refresh();

  @override
  Widget build(BuildContext context) {
    final isLoading = ProductService.instance.isLoading.value;
    final failed = ProductService.instance.connectionFailed.value;

    if (isLoading && !failed) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          color: const Color(0xFFE53935),
          strokeWidth: 2.5,
          onRefresh: _onRefresh,
          child: const CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFE53935)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (failed) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          color: const Color(0xFFE53935),
          strokeWidth: 2.5,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Không thể kết nối đến máy chủ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text('Kéo xuống để thử lại', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _onRefresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final items = _favoriteItems;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar row ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Favorites',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.black, size: 24),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ── Category chips ─────────────────────────────────────────────
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final sel = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel ? Colors.black : Colors.grey[300]!),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: sel ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // ── Filter / Sort / View toggle row ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Filters button
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(Icons.tune, size: 18, color: Colors.grey[700]),
                        const SizedBox(width: 4),
                        Text('Filters',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Sort button
                  GestureDetector(
                    onTap: () => _showSortSheet(),
                    child: Row(
                      children: [
                        Icon(Icons.swap_vert, size: 18, color: Colors.grey[700]),
                        const SizedBox(width: 4),
                        Text(_sortBy,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // View toggle
                  GestureDetector(
                    onTap: () => setState(() => _isGridView = !_isGridView),
                    child: Icon(
                      _isGridView ? Icons.grid_view : Icons.view_list,
                      size: 22,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Divider(height: 1, color: Colors.grey[200]),

            // ── Content ────────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFDB3022),
                strokeWidth: 2.5,
                onRefresh: _onRefresh,
                child: items.isEmpty
                    ? _buildEmptyState()
                    : _isGridView
                        ? _buildGridView(items)
                        : _buildListView(items),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('No favorites yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8),
                Text('Tap the heart icon on items you love',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── List View ────────────────────────────────────────────────────────────
  Widget _buildListView(List<FavoriteItem> items) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return _FavoriteListTile(
          item: item,
          onRemove: () => FavoritesManager.instance.toggle(item.product),
          onAddToBag: () => _addToBag(item),
          onTap: () => _openDetail(item.product),
        );
      },
    );
  }

  // ─── Grid View ────────────────────────────────────────────────────────────
  Widget _buildGridView(List<FavoriteItem> items) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return _FavoriteGridCard(
          item: item,
          onRemove: () => FavoritesManager.instance.toggle(item.product),
          onAddToBag: () => _addToBag(item),
          onTap: () => _openDetail(item.product),
        );
      },
    );
  }

  void _openDetail(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  void _addToBag(FavoriteItem item) {
    BagManager.instance.add(
      item.product,
      selectedSize: item.selectedSize,
      selectedColor: item.selectedColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Added ${item.product['name']} to bag${item.selectedSize != null ? ' (Size: ${item.selectedSize})' : ''}"),
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sort by',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._sortOptions.map((opt) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(opt),
                  trailing: _sortBy == opt
                      ? const Icon(Icons.check, color: Colors.black)
                      : null,
                  onTap: () {
                    setState(() => _sortBy = opt);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

// ─── List Tile ────────────────────────────────────────────────────────────────
class _FavoriteListTile extends StatelessWidget {
  final FavoriteItem item;
  final VoidCallback onRemove;
  final VoidCallback onAddToBag;
  final VoidCallback onTap;

  const _FavoriteListTile({
    required this.item,
    required this.onRemove,
    required this.onAddToBag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    final isSoldOut = p['soldOut'] == true;
    final discount = p['discount'] as int?;
    final rating = (p['rating'] as num?)?.toDouble() ?? 0.0;
    final reviews = (p['reviews'] as int?) ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Image ───────────────────────────────────────────────────────
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                p['image'] ?? '',
                width: 100,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 120,
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: Colors.grey, size: 28),
                ),
              ),
            ),
            // NEW badge
            if (p['isNew'] == true)
              Positioned(
                top: 6,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4)),
                  ),
                  child: const Text('NEW',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            // Discount badge
            if (discount != null && discount > 0)
              Positioned(
                top: 6,
                left: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4)),
                  ),
                  child: Text('-$discount%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ]),

          const SizedBox(width: 12),

          // ── Info ─────────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand
                Text(p['brand'] ?? '',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                const SizedBox(height: 2),
                // Name
                Text(p['name'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                // Color / Size
                Row(children: [
                  if (item.selectedColor != null || p['color'] != null)
                    Text(
                      'Color: ${item.selectedColor ?? p['color'] ?? ''}',
                      style:
                          TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  if ((item.selectedColor != null || p['color'] != null) &&
                      (item.selectedSize != null || p['size'] != null))
                    const SizedBox(width: 8),
                  if (item.selectedSize != null || p['size'] != null)
                    Text(
                      'Size: ${item.selectedSize ?? p['size'] ?? ''}',
                      style:
                          TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                ]),
                const SizedBox(height: 6),
                // Price
                Row(children: [
                  Text('\$${p['price']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  if (p['oldPrice'] != null) ...[
                    const SizedBox(width: 8),
                    Text('\$${p['oldPrice']}',
                        style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough)),
                  ],
                ]),
                const SizedBox(height: 4),
                // Stars
                if (rating > 0)
                  Row(children: [
                    _StarRow(rating: rating),
                    const SizedBox(width: 4),
                    Text('($reviews)',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 11)),
                  ]),
                // Sold out banner
                if (isSoldOut)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Sorry, this item is currently sold out',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Actions (remove X, add to bag) ──────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // X button
              GestureDetector(
                onTap: onRemove,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 18, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 56),
              // Bag button
              GestureDetector(
                onTap: isSoldOut ? null : onAddToBag,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSoldOut
                        ? Colors.grey[300]
                        : const Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_bag_outlined,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

// ─── Grid Card ────────────────────────────────────────────────────────────────
class _FavoriteGridCard extends StatelessWidget {
  final FavoriteItem item;
  final VoidCallback onRemove;
  final VoidCallback onAddToBag;
  final VoidCallback onTap;

  const _FavoriteGridCard({
    required this.item,
    required this.onRemove,
    required this.onAddToBag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    final isSoldOut = p['soldOut'] == true;
    final discount = p['discount'] as int?;
    final rating = (p['rating'] as num?)?.toDouble() ?? 0.0;
    final reviews = (p['reviews'] as int?) ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ────────────────────────────────────────────────────────
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    p['image'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey, size: 28),
                    ),
                  ),
                ),
                // Sold out overlay
                if (isSoldOut)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      color: Colors.white.withOpacity(0.85),
                      child: Text(
                        'Sorry, this item is currently sold out',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                // Discount badge
                if (discount != null && discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('-$discount%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                // X button
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close,
                          size: 14, color: Colors.grey[700]),
                    ),
                  ),
                ),
                // Bag button
                Positioned(
                  bottom: isSoldOut ? 48 : 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: isSoldOut ? null : onAddToBag,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isSoldOut
                            ? Colors.grey[300]
                            : const Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ── Stars ─────────────────────────────────────────────────────────
          if (rating > 0)
            Row(children: [
              _StarRow(rating: rating),
              const SizedBox(width: 4),
              Text('($reviews)',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10)),
            ]),

          const SizedBox(height: 2),
          // Brand
          Text(p['brand'] ?? '',
              style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          // Name
          Text(
            p['name'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Color / Size
          if (item.selectedColor != null || p['color'] != null ||
              item.selectedSize != null || p['size'] != null)
            Text(
              [
                if (item.selectedColor != null || p['color'] != null)
                  'Color: ${item.selectedColor ?? p['color'] ?? ''}',
                if (item.selectedSize != null || p['size'] != null)
                  'Size: ${item.selectedSize ?? p['size'] ?? ''}',
              ].join('  '),
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          const SizedBox(height: 2),
          // Price
          Row(children: [
            Text('\$${p['price']}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 14)),
            if (p['oldPrice'] != null) ...[
              const SizedBox(width: 6),
              Text('\$${p['oldPrice']}',
                  style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough)),
            ],
          ]),
        ],
      ),
    );
  }
}

// ─── Star Row ─────────────────────────────────────────────────────────────────
class _StarRow extends StatelessWidget {
  final double rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star, color: Color(0xFFFFB800), size: 14);
        } else if (i < rating && rating - i >= 0.5) {
          return const Icon(Icons.star_half, color: Color(0xFFFFB800), size: 14);
        } else {
          return Icon(Icons.star_border, color: Colors.grey[300], size: 14);
        }
      }),
    );
  }
}