import 'package:flutter/material.dart';
import 'dart:async';
import 'models/product.dart';
import 'services/product_service.dart';
import 'services/favorite_service.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  final ProductService _productService = ProductService();
  late Future<List<Product>> _newProductsFuture;

  @override
  void initState() {
    super.initState();
    _newProductsFuture = _productService.fetchNewProducts();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _newProductsFuture = _productService.fetchNewProducts();
    });
    await _newProductsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return RefreshIndicator(
      color: const Color(0xFFE53935),
      strokeWidth: 2.5,
      onRefresh: _onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
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
            child: FutureBuilder<List<Product>>(
              future: _newProductsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox(height: 180, child: Center(child: Text('Không có sản phẩm mới', style: TextStyle(color: Colors.grey))));
                }

                final products = snapshot.data!;
                return SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _NewCard(product: products[index], bgColor: index % 2 == 0 ? const Color(0xFFF0E6DC) : const Color(0xFFE8E8E8));
                    },
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _NewCard extends StatelessWidget {
  final Product product;
  final Color bgColor;
  const _NewCard({required this.product, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            product.imageUrl != null
                ? (product.imageUrl!.startsWith('assets/')
                    ? Image.asset(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: bgColor))
                    : Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: bgColor)))
                : const Icon(Icons.image, color: Colors.grey),
            Positioned(
              top: 10, left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
                child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── MAIN PAGE 2 ─────────────────────────────────────────────────────────────
class _MainPage2 extends StatefulWidget {
  const _MainPage2();

  @override
  State<_MainPage2> createState() => _MainPage2State();
}

class _MainPage2State extends State<_MainPage2> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _saleProductsFuture;
  late Future<List<Product>> _newProductsFuture;

  @override
  void initState() {
    super.initState();
    _saleProductsFuture = _productService.fetchSaleProducts();
    _newProductsFuture = _productService.fetchNewProducts();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _saleProductsFuture = _productService.fetchSaleProducts();
      _newProductsFuture = _productService.fetchNewProducts();
    });
    await Future.wait([_saleProductsFuture, _newProductsFuture]);
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return RefreshIndicator(
      color: const Color(0xFFE53935),
      strokeWidth: 2.5,
      onRefresh: _onRefresh,
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
            child: FutureBuilder<List<Product>>(
              future: _saleProductsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 260, child: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text('Không có sản phẩm sale', style: TextStyle(color: Colors.grey)),
                  );
                }

                final products = snapshot.data!;
                return SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: products.length,
                    itemBuilder: (_, i) => _SaleCard(product: products[i]),
                  ),
                );
              },
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
            child: FutureBuilder<List<Product>>(
              future: _newProductsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 260, child: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text('Không có sản phẩm mới', style: TextStyle(color: Colors.grey)),
                  );
                }

                final products = snapshot.data!;
                return SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: products.length,
                    itemBuilder: (_, i) => _SaleCard(product: products[i], isNew: true),
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _SaleCard extends StatefulWidget {
  final Product product;
  final bool isNew;
  const _SaleCard({required this.product, this.isNew = false});

  @override
  State<_SaleCard> createState() => _SaleCardState();
}

class _SaleCardState extends State<_SaleCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
    FavoriteService.favoritesChangedNotifier.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    FavoriteService.favoritesChangedNotifier.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    if (widget.product.id == null) return;
    final isFav = await FavoriteService().checkFavorite(widget.product.id!);
    if (mounted && _isFavorite != isFav) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.product.id == null) return;
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    bool success;
    if (!_isFavorite) {
      success = await FavoriteService().removeFavorite(widget.product.id!);
    } else {
      success = await FavoriteService().addFavorite(widget.product.id!);
    }

    if (!success && mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final bool hasDiscount = product.salePrice != null && product.salePrice! > 0 && product.price != null && product.price! > product.salePrice!;
    int discountPercent = 0;
    if (hasDiscount) {
      discountPercent = (((product.price! - product.salePrice!) / product.price!) * 100).round();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
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
                  child: product.imageUrl != null
                      ? (product.imageUrl!.startsWith('assets/')
                          ? Image.asset(product.imageUrl!, width: 155, height: 175, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 155, height: 175, color: Colors.grey[200]))
                          : Image.network(product.imageUrl!, width: 155, height: 175, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 155, height: 175, color: Colors.grey[200])))
                      : Container(width: 155, height: 175, color: Colors.grey[200]),
                ),
                if (hasDiscount && !widget.isNew)
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(6)),
                      child: Text('-$discountPercent%',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (widget.isNew)
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black, borderRadius: BorderRadius.circular(6)),
                      child: const Text('NEW',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(
                  top: 10, right: 10,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, size: 16, color: _isFavorite ? const Color(0xFFE53935) : Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (i) {
                  final rating = product.rating ?? 0.0;
                  if (i < rating.floor()) return const Icon(Icons.star, color: Colors.amber, size: 13);
                  if (i < rating) return const Icon(Icons.star_half, color: Colors.amber, size: 13);
                  return const Icon(Icons.star_border, color: Colors.amber, size: 13);
                }),
                const SizedBox(width: 4),
                Text('(${product.reviewCount ?? 0})',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],
            ),
            const SizedBox(height: 2),
            Text(product.brand ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            Text(product.name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Row(children: [
              if (hasDiscount) ...[
                Text('\$${product.price}',
                  style: const TextStyle(
                    color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 12)),
                const SizedBox(width: 6),
              ],
              Text('\$${product.salePrice ?? product.price ?? 0}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── MAIN PAGE 3 ─────────────────────────────────────────────────────────────
class _MainPage3 extends StatelessWidget {
  const _MainPage3();

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
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
                Container(color: Colors.black.withOpacity(0.15)),
                const Positioned(
                  bottom: 24, right: 24,
                  child: Text('New collection',
                    style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
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
                      Container(color: Colors.white),
                      const Positioned(
                        bottom: 30, right: 20,
                        child: Text("Summer\nsale",
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Color(0xFFE53935), fontSize: 24, fontWeight: FontWeight.w900, height: 1.1)),
                      ),
                    ],
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
    );
  }
}
