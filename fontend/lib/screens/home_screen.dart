import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/storage_service.dart';
import 'shop_screen.dart';
import 'bag_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';


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
      body: screens[_currentIndex],
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
      {'label': 'Home', 'icon': Icons.home_outlined, 'active': Icons.home},
      {'label': 'Shop', 'icon': Icons.storefront_outlined, 'active': Icons.storefront},
      {'label': 'Bag', 'icon': Icons.shopping_bag_outlined, 'active': Icons.shopping_bag},
      {'label': 'Favorites', 'icon': Icons.favorite_border, 'active': Icons.favorite},
      {'label': 'Profile', 'icon': Icons.person_outline, 'active': Icons.person},
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

// ─── HOME TAB (Main page + Main2 + Main3 in PageView) ────────────────────────
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _pageController = PageController();
  int _page = 0;

  List<Map<String, dynamic>> _apiSaleProducts = [];
  List<Map<String, dynamic>> _apiNewProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final token = await StorageService().getAccessToken();
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final url = '${ApiConfig.baseUrl}/shop/products';
      print("📡 Fetching products from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print("📡 Fetch products response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print("📡 Loaded ${data.length} products from API");

        // Sắp xếp các sản phẩm theo updated_at giảm dần (sản phẩm mới cập nhật lên đầu)
        try {
          data.sort((a, b) {
            final aTime = DateTime.tryParse(a['updated_at']?.toString() ?? '') ?? DateTime(1970);
            final bTime = DateTime.tryParse(b['updated_at']?.toString() ?? '') ?? DateTime(1970);
            return bTime.compareTo(aTime);
          });
        } catch (e) {
          print("⚠️ Lỗi khi sắp xếp sản phẩm: $e");
        }

        final List<Map<String, dynamic>> loadedSale = [];
        final List<Map<String, dynamic>> loadedNew = [];

        for (var item in data) {
          final mapped = _mapApiProduct(item);
          print("📡 Mapped: ${mapped['name']} | isSale: ${mapped['isSale']} (raw sale: ${item['sale']}, raw isSale: ${item['isSale']}) | isNew: ${mapped['isNew']} (raw new: ${item['new']}, raw isNew: ${item['isNew']})");
          if (mapped['isSale'] == true) {
            loadedSale.add(mapped);
          }
          if (mapped['isNew'] == true) {
            loadedNew.add(mapped);
          }
        }

        setState(() {
          _apiSaleProducts = loadedSale;
          _apiNewProducts = loadedNew;
        });
      } else {
        print("❌ Lỗi API status: ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e) {
      print("❌ Lỗi khi lấy sản phẩm từ API: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _mapApiProduct(dynamic item) {
    final name = item['product_name'] ?? '';
    final brand = item['sku'] ?? 'Dorothy Perkins';
    final priceVal = item['sale_price'] ?? 0;
    final oldPriceVal = item['compare_price'];
    final isSale = item['sale'] ?? item['isSale'] ?? false;
    final isNew = item['new'] ?? item['isNew'] ?? false;

    // Map image based on name
    String img = 'assets/images/main_2_evening_dress.png';
    final lowerName = name.toString().toLowerCase();
    if (lowerName.contains('evening')) {
      img = 'assets/images/main_2_evening_dress.png';
    } else if (lowerName.contains('sport')) {
      if (lowerName.contains('white') || brand.toString().toLowerCase().contains('dorothy')) {
        img = 'assets/images/main_2_sport_white.png';
      } else {
        img = 'assets/images/main_2_sport_dress.png';
      }
    } else {
      final slug = item['slug'] ?? '';
      if (slug.toString().startsWith('http') || slug.toString().startsWith('assets/')) {
        img = slug;
      } else {
        img = 'assets/images/main_2_evening_dress.png';
      }
    }

    // Calculate discount percentage
    String discountStr = '-20%';
    if (oldPriceVal != null && priceVal != null) {
      final oldP = double.tryParse(oldPriceVal.toString()) ?? 0.0;
      final newP = double.tryParse(priceVal.toString()) ?? 0.0;
      if (oldP > newP && oldP > 0) {
        discountStr = '-${((oldP - newP) / oldP * 100).round()}%';
      }
    }

    return {
      'id': item['id'],
      'name': name,
      'brand': brand,
      'oldPrice': oldPriceVal != null ? '${oldPriceVal}\$' : '15\$',
      'price': '${priceVal}\$',
      'discount': discountStr,
      'rating': 5.0,
      'reviews': 10,
      'image': img,
      'isSale': isSale,
      'isNew': isNew,
    };
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      onPageChanged: (i) => setState(() => _page = i),
      children: [
        _MainPage1(
          newProducts: _apiNewProducts,
          onRefresh: _fetchProducts,
        ),
        _MainPage2(
          saleProducts: _apiSaleProducts,
          newProducts: _apiNewProducts,
          onRefresh: _fetchProducts,
        ),
        _MainPage3(
          onRefresh: _fetchProducts,
        ),
      ],
    );
  }
}

// ─── MAIN PAGE 1 ─────────────────────────────────────────────────────────────
class _MainPage1 extends StatelessWidget {
  final List<Map<String, dynamic>> newProducts;
  final Future<void> Function() onRefresh;

  const _MainPage1({
    required this.newProducts,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final displayNews = newProducts.isNotEmpty
        ? newProducts
        : const [
            {'label': 'NEW', 'bgColor': Color(0xFFF0E6DC), 'imagePath': 'assets/images/main_page_2.png'},
            {'label': 'NEW', 'bgColor': Color(0xFFF5F5F5), 'imagePath': 'assets/images/main_page_3.png'},
          ];

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFFE53935),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Hero Banner "Fashion sale"
          SliverToBoxAdapter(
            child: SizedBox(
              height: screenH * 0.55,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/main_page_1.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFF8B6E52)),
                  ),
                  // Dark gradient bottom
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
                  // Status bar area safe
                  Positioned(
                    bottom: 36,
                    left: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fashion\nsale',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -0.5,
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

          // "New" header
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

          // New items horizontal scroll
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: displayNews.length,
                itemBuilder: (_, i) {
                  final p = displayNews[i];
                  return _NewCard(
                    label: p['label'] ?? 'NEW',
                    bgColor: p['bgColor'] ?? const Color(0xFFF0E6DC),
                    imagePath: p['imagePath'] ?? p['image'] ?? 'assets/images/main_page_2.png',
                  );
                },
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
  final String imagePath;
  const _NewCard({required this.label, required this.bgColor, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final isAsset = imagePath.startsWith('assets/');
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          isAsset
              ? Image.asset(imagePath, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: bgColor))
              : Image.network(imagePath, fit: BoxFit.cover,
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

// ─── MAIN PAGE 2 ─────────────────────────────────────────────────────────────
class _MainPage2 extends StatelessWidget {
  final List<Map<String, dynamic>> saleProducts;
  final List<Map<String, dynamic>> newProducts;
  final Future<void> Function() onRefresh;

  const _MainPage2({
    required this.saleProducts,
    required this.newProducts,
    required this.onRefresh,
  });

  static const _saleProducts = [
    {
      'name': 'Evening Dress', 'brand': 'Dorothy Perkins',
      'oldPrice': '15\$', 'price': '12\$', 'discount': '-20%', 'rating': 5.0, 'reviews': 10,
      'image': 'assets/images/main_2_evening_dress.png',
    },
    {
      'name': 'Sport Dress', 'brand': 'Sitlly',
      'oldPrice': '22\$', 'price': '19\$', 'discount': '-15%', 'rating': 5.0, 'reviews': 10,
      'image': 'assets/images/main_2_sport_dress.png',
    },
    {
      'name': 'White Sport Dress', 'brand': 'Dorothy',
      'oldPrice': '18\$', 'price': '14\$', 'discount': '-20%', 'rating': 4.0, 'reviews': 8,
      'image': 'assets/images/main_2_sport_white.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final displaySales = saleProducts.isNotEmpty ? saleProducts : _saleProducts;
    final displayNews = newProducts.isNotEmpty
        ? newProducts
        : const [
            {'label': 'NEW', 'bgColor': Color(0xFFF0E6DC), 'imagePath': 'assets/images/main_2_new_bottom_2.png'},
            {'label': 'NEW', 'bgColor': Color(0xFFF5F5F5), 'imagePath': 'assets/images/main_2_new_bottom_3.png'},
          ];

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFFE53935),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Hero Banner "Street clothes" (exactly 196px high)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 196,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/main_2.jpg',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.3),
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.05), Colors.black.withOpacity(0.35)],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 16,
                    bottom: 26,
                    child: Text(
                      'Street clothes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sale section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sale',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Super summer sale',
                        style: TextStyle(
                          color: const Color(0xFF9B9B9B),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sale products
          SliverToBoxAdapter(
            child: SizedBox(
              height: 292,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: displaySales.length,
                itemBuilder: (_, i) => _SaleCard(product: displaySales[i]),
              ),
            ),
          ),

        // New section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "You've never seen it before!",
                        style: TextStyle(
                          color: const Color(0xFF9B9B9B),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          // New items horizontal scroll
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: displayNews.length,
                itemBuilder: (_, i) {
                  final p = displayNews[i];
                  return _NewCard(
                    label: p['label'] ?? 'NEW',
                    bgColor: p['bgColor'] ?? const Color(0xFFF0E6DC),
                    imagePath: p['imagePath'] ?? p['image'] ?? 'assets/images/main_2_new_bottom_2.png',
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _SaleCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isAsset = (product['image'] as String).startsWith('assets/');
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isAsset
                    ? Image.asset(
                        product['image'],
                        width: 150,
                        height: 184,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 150, height: 184, color: const Color(0xFFC4C4C4)),
                      )
                    : Image.network(
                        product['image'],
                        width: 150,
                        height: 184,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 150, height: 184, color: const Color(0xFFC4C4C4)),
                      ),
              ),
              Positioned(
                top: 8, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDB3022),
                    borderRadius: BorderRadius.circular(29)),
                  child: Text(product['discount'],
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Transform.translate(
                  offset: const Offset(0, 15),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
                    child: const Icon(Icons.favorite_border, size: 18, color: Color(0xFF9B9B9B)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Row(
                children: List.generate(5, (i) =>
                  Icon(i < (product['rating'] as double).floor() ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFBA49), size: 13)),
              ),
              const SizedBox(width: 4),
              Text(
                "(${product['reviews']})",
                style: const TextStyle(color: Color(0xFF9B9B9B), fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(product['brand'], style: const TextStyle(color: Color(0xFF9B9B9B), fontSize: 11)),
          const SizedBox(height: 2),
          Text(product['name'],
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF222222)),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [
            Text(product['oldPrice'],
              style: const TextStyle(color: Color(0xFF9B9B9B), decoration: TextDecoration.lineThrough, fontSize: 14)),
            const SizedBox(width: 6),
            Text(product['price'], 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFDB3022))),
          ]),
        ],
      ),
    );
  }
}

// ─── MAIN PAGE 3 ─────────────────────────────────────────────────────────────
class _MainPage3 extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _MainPage3({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFFE53935),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Top hero "New collection"
          SliverToBoxAdapter(
            child: SizedBox(
              height: screenH * 0.38,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.pexels.com/photos/1148957/pexels-photo-1148957.jpeg?auto=compress&w=800',
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

          // 2x2 grid banners
          SliverToBoxAdapter(
            child: SizedBox(
              height: screenH * 0.35,
              child: Row(
                children: [
                  // Summer sale (white bg)
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      child: const Text(
                        'Summer\nsale',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  // Men's hoodies (dark image)
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://images.pexels.com/photos/1300550/pexels-photo-1300550.jpeg?auto=compress&w=400',
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
                  // Black (dark image)
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://images.pexels.com/photos/1043473/pexels-photo-1043473.jpeg?auto=compress&w=400',
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
                  // Extra banner
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://images.pexels.com/photos/2065195/pexels-photo-2065195.jpeg?auto=compress&w=400',
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