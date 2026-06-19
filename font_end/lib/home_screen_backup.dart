import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/product_service.dart';
import 'shop_screen.dart';
import 'product_detail_screen.dart';
import 'bag_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'rating_reviews_screen.dart';

// ─── HOME SCREEN ──────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _HomeTab(),
      const ShopScreen(),
      const BagScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      {'label': 'Home',      'icon': Icons.home_outlined,        'active': Icons.home},
      {'label': 'Shop',      'icon': Icons.storefront_outlined,   'active': Icons.storefront},
      {'label': 'Bag',       'icon': Icons.shopping_bag_outlined, 'active': Icons.shopping_bag},
      {'label': 'Favorites', 'icon': Icons.favorite_border,       'active': Icons.favorite},
      {'label': 'Profile',   'icon': Icons.person_outline,        'active': Icons.person},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -1))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? (items[i]['active'] as IconData) : (items[i]['icon'] as IconData),
                        color: active ? const Color(0xFFE53935) : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: active ? const Color(0xFFE53935) : Colors.grey,
                          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── HOME TAB ─────────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: const [
        _MainPage1(),
        _MainPage2(),
        _MainPage3(),
      ],
    );
  }
}

// ─── Shared: Connection Error Banner ─────────────────────────────────────────
class _ConnectionErrorBanner extends StatelessWidget {
  final VoidCallback onRetry;
  const _ConnectionErrorBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Color(0xFFE53935), size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Không thể kết nối đến máy chủ',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Kéo xuống để thử lại',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Thử lại',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MAIN PAGE 1 ─────────────────────────────────────────────────────────────
class _MainPage1 extends StatefulWidget {
  const _MainPage1();

  @override
  State<_MainPage1> createState() => _MainPage1State();
}

class _MainPage1State extends State<_MainPage1> {
  @override
  void initState() {
    super.initState();
    ProductService.instance.isLoading.addListener(_onChange);
    ProductService.instance.connectionFailed.addListener(_onChange);
  }

  @override
  void dispose() {
    ProductService.instance.isLoading.removeListener(_onChange);
    ProductService.instance.connectionFailed.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  Future<void> _onRefresh() => ProductService.instance.refresh();

  @override
  Widget build(BuildContext context) {
    final isLoading = ProductService.instance.isLoading.value;
    final failed = ProductService.instance.connectionFailed.value;
    final screenH = MediaQuery.of(context).size.height;

    if (isLoading && !failed) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE53935)),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFE53935),
      strokeWidth: 2.5,
      onRefresh: _onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Connection error banner
          if (failed)
            SliverToBoxAdapter(
              child: _ConnectionErrorBanner(onRetry: _onRefresh),
            ),

          // ── Hero Banner ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: screenH * 0.55,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/main-page.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFF8B6E52)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.4, 1.0],
                        colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 36, left: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fashion\nsale',
                          style: TextStyle(
                            color: Colors.white, fontSize: 42,
                            fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text('Check', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('New', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View all', style: TextStyle(color: Color(0xFFE53935), fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 14),
              child: Text("You've never seen it before!", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  _NewCard(label: 'NEW', bgColor: Color(0xFFF0E6DC),
                    imageUrl: 'assets/images/main_2_product_sale__evening_dress.png'),
                  _NewCard(label: 'NEW', bgColor: Color(0xFFF5F5F5),
                    imageUrl: 'assets/images/main_2_product_sale_sport_dress.png'),
                  _NewCard(label: 'NEW', bgColor: Color(0xFFE8E8E8),
                    imageUrl: 'assets/images/main_2_product_sale_sport_dress2.png'),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _NewCard extends StatelessWidget {
  final String label;
  final Color bgColor;
  final String imageUrl;
  const _NewCard({required this.label, required this.bgColor, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imageUrl, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: bgColor)),
          Positioned(
            top: 10, left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MAIN PAGE 2 — Pull-to-Refresh + API driven ───────────────────────────────
class _MainPage2 extends StatefulWidget {
  const _MainPage2();

  @override
  State<_MainPage2> createState() => _MainPage2State();
}

class _MainPage2State extends State<_MainPage2> {
  List<Map<String, dynamic>> _saleProducts = [];
  List<Map<String, dynamic>> _newProducts  = [];
  bool _isLoading = true;
  bool _failed = false;

  Future<void> _fetchLayout() async {
    if (mounted) setState(() { _isLoading = true; _failed = false; });
    try {
      final res = await http
          .get(Uri.parse(ApiConfig.products))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final rawProducts = jsonDecode(res.body) as List<dynamic>;

        final allProducts = rawProducts.map<Map<String, dynamic>>((e) {
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
            'description': m['short_description'] ?? '',
            'slug'       : m['slug'] ?? '',
          };
        }).toList();

        final saleList = allProducts.where((p) {
          final d = p['discount'];
          return d != null && (d as int) > 0;
        }).toList();
        final newList = allProducts.where((p) {
          final d = p['discount'];
          return d == null || (d as int) == 0;
        }).toList();

        final mid = (allProducts.length / 2).ceil();
        if (mounted) {
          setState(() {
            _saleProducts = saleList.isNotEmpty ? saleList : allProducts.take(mid).toList();
            _newProducts  = newList.isNotEmpty  ? newList  : allProducts.skip(mid).toList();
            _isLoading    = false;
            _failed       = false;
          });
        }
      } else {
        if (mounted) setState(() { _isLoading = true; _failed = true; });
      }
    } catch (e) {
      debugPrint('MainPage2 fetch error: $e');
      if (mounted) setState(() { _isLoading = true; _failed = true; });
    }
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  @override
  void initState() {
    super.initState();
    _fetchLayout();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    // Loading without failure — keep spinner
    if (_isLoading && !_failed) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE53935)),
      );
    }

    // Loading with failure — show error + allow pull to retry
    if (_isLoading && _failed) {
      return RefreshIndicator(
        color: const Color(0xFFE53935),
        strokeWidth: 2.5,
        onRefresh: _fetchLayout,
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
                    onPressed: _fetchLayout,
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
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFE53935),
      strokeWidth: 2.5,
      onRefresh: _fetchLayout,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Banner ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: screenH * 0.28,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/main2.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.5)],
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 20, left: 20,
                    child: Text('Street clothes',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ),

          // ── Section SALE ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sale', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                      Text('Super summer sale', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View all', style: TextStyle(color: Color(0xFFE53935))),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _saleProducts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text('Không có sản phẩm sale', style: TextStyle(color: Colors.grey)),
                  )
                : SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _saleProducts.length,
                      itemBuilder: (_, i) => _SaleCard(product: _saleProducts[i]),
                    ),
                  ),
          ),

          // ── Section NEW ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('New', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View all', style: TextStyle(color: Color(0xFFE53935))),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 14),
              child: Text("You've never seen it before!", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ),
          ),

          SliverToBoxAdapter(
            child: _newProducts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text('Không có sản phẩm mới', style: TextStyle(color: Colors.grey)),
                  )
                : SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _newProducts.length,
                      itemBuilder: (_, i) => _SaleCard(product: _newProducts[i]),
                    ),
                  ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ─── Sale / Product Card ──────────────────────────────────────────────────────
class _SaleCard extends StatefulWidget {
  final Map<String, dynamic> product;
  const _SaleCard({required this.product});

  @override
  State<_SaleCard> createState() => _SaleCardState();
}

class _SaleCardState extends State<_SaleCard> {
  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final hasDiscount = product['discount'] != null && (product['discount'] as int) > 0;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
        setState(() {});
      },
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    product['image'],
                    width: 155, height: 175, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(width: 155, height: 175, color: Colors.grey[200]),
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(6)),
                      child: Text('-${product['discount']}%',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                    child: const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (i) {
                  final rating = ReviewsManager.instance.getAverageRating(product);
                  if (i < rating.floor()) return const Icon(Icons.star, color: Colors.amber, size: 13);
                  if (i < rating) return const Icon(Icons.star_half, color: Colors.amber, size: 13);
                  return const Icon(Icons.star_border, color: Colors.amber, size: 13);
                }),
                const SizedBox(width: 4),
                Text('(${ReviewsManager.instance.getReviewCount(product)})',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],
            ),
            const SizedBox(height: 2),
            Text(product['brand'], style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            Text(product['name'],
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Row(children: [
              if (hasDiscount) ...[
                Text('\$${product['oldPrice']}',
                  style: const TextStyle(
                    color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 12)),
                const SizedBox(width: 6),
              ],
              Text('\$${product['price']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── MAIN PAGE 3 ─────────────────────────────────────────────────────────────
class _MainPage3 extends StatefulWidget {
  const _MainPage3();

  @override
  State<_MainPage3> createState() => _MainPage3State();
}

class _MainPage3State extends State<_MainPage3> {
  @override
  void initState() {
    super.initState();
    ProductService.instance.isLoading.addListener(_onChange);
    ProductService.instance.connectionFailed.addListener(_onChange);
  }

  @override
  void dispose() {
    ProductService.instance.isLoading.removeListener(_onChange);
    ProductService.instance.connectionFailed.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  Future<void> _onRefresh() => ProductService.instance.refresh();

  @override
  Widget build(BuildContext context) {
    final isLoading = ProductService.instance.isLoading.value;
    final failed = ProductService.instance.connectionFailed.value;
    final screenH = MediaQuery.of(context).size.height;

    if (isLoading && !failed) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE53935)),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFE53935),
      strokeWidth: 2.5,
      onRefresh: _onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Connection error banner
          if (failed)
            SliverToBoxAdapter(
              child: _ConnectionErrorBanner(onRetry: _onRefresh),
            ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: screenH * 0.38,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/main3.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.blueGrey[700]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 28, right: 24,
                    child: Text('New collection',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: screenH * 0.35,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      child: const Text(
                        'Summer\nsale',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFE53935), fontSize: 28,
                          fontWeight: FontWeight.w900, height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/main_3_men\'s_hoodie.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey[700]),
                        ),
                        Container(color: Colors.black.withOpacity(0.35)),
                        const Positioned(
                          bottom: 20, left: 16,
                          child: Text("Men's\nhoodies",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: screenH * 0.22,
              child: Row(
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/main_3_black.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.black87),
                        ),
                        Container(color: Colors.black.withOpacity(0.3)),
                        const Positioned(
                          bottom: 16, left: 16,
                          child: Text('Black',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/categories_clothes.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.brown[700]),
                        ),
                        Container(color: Colors.black.withOpacity(0.25)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
