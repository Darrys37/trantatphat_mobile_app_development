import 'package:flutter/material.dart';
import 'catalog_screen.dart';
import 'product_data.dart';
import '../services/product_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF222222), size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Categories',
            style: TextStyle(
                color: Color(0xFF222222), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF222222), size: 22),
              onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF222222),
              unselectedLabelColor: const Color(0xFF9B9B9B),
              indicatorColor: const Color(0xFFDB3022),
              indicatorWeight: 3.0,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Metropolis',
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                fontFamily: 'Metropolis',
              ),
              tabs: const [
                Tab(text: 'Women'),
                Tab(text: 'Men'),
                Tab(text: 'Kids'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CategoriesTab(gender: 'Women'),
          _CategoriesTab(gender: 'Men'),
          _CategoriesTab(gender: 'Kids'),
        ],
      ),
    );
  }
}

// ─── Categories Tab ───────────────────────────────────────────────────────────
class _CategoriesTab extends StatefulWidget {
  final String gender;
  const _CategoriesTab({required this.gender});

  @override
  State<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<_CategoriesTab> {
  static const _categoryNames = ['New', 'Clothes', 'Shoes', 'Accessories'];

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

    // Loading without failure — show spinner (pull to refresh still available)
    if (isLoading && !failed) {
      return RefreshIndicator(
        color: const Color(0xFFDB3022),
        strokeWidth: 2.5,
        onRefresh: _onRefresh,
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFDB3022)),
              ),
            ),
          ],
        ),
      );
    }

    // Failed — show error + pull to retry
    if (failed) {
      return RefreshIndicator(
        color: const Color(0xFFDB3022),
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
                      backgroundColor: const Color(0xFFDB3022),
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

    final images = categoryImages[widget.gender]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          color: const Color(0xFFDB3022),
          strokeWidth: 2.5,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: Column(
      children: [
        // Summer Sales Banner
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFDB3022),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 1),
                )
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SUMMER SALES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Metropolis',
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Up to 50% off',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Metropolis',
                  ),
                ),
              ],
            ),
          ),
        ),

        // Category rows
        ..._categoryNames.map((name) => Expanded(
              child: _CategoryRow(
                name: name,
                imageUrl: images[name]!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoriesSubScreen(
                      parentCategory: name,
                      gender: widget.gender,
                    ),
                  ),
                ),
              ),
            )),
        // Subtle spacing at bottom to prevent hitting bottom nav
        const SizedBox(height: 8),
      ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Category Row with figma specs ───────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.name,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Spell exactly as mockup: "Accesories" instead of "Accessories"
    final displayName = name == 'Accessories' ? 'Accesories' : name;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 23), // left: 6.71% of 343 = 23px
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Metropolis',
                      color: Color(0xFF222222),
                    ),
                  ),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: Image.network(
                imageUrl,
                width: 172, // right image width = 343 * (100% - 50.15%) = 171px or 172px
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        width: 172,
                        color: Colors.grey[100],
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFDB3022)),
                          ),
                        ),
                      ),
                errorBuilder: (_, __, ___) => Container(
                  width: 172,
                  color: Colors.grey[100],
                  child: const Icon(Icons.image_outlined,
                      color: Colors.grey, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Categories Sub Screen ────────────────────────────────────────────────────
class CategoriesSubScreen extends StatelessWidget {
  final String parentCategory;
  final String gender;

  const CategoriesSubScreen({
    super.key,
    required this.parentCategory,
    required this.gender,
  });

  static const _subCategories = [
    'Tops', 'Shirts & Blouses', 'Cardigans & Sweaters', 'Knitwear',
    'Blazers', 'Outerwear', 'Pants', 'Jeans', 'Shorts', 'Skirts', 'Dresses',
  ];

  static const _chipToKey = {
    'Tops': 'T-shirts',
    'Shirts & Blouses': 'Blouses',
    'Cardigans & Sweaters': 'T-shirts',
    'Knitwear': 'T-shirts',
    'Blazers': 'Blouses',
    'Outerwear': 'Blouses',
    'Pants': 'Sleeveless',
    'Jeans': 'Sleeveless',
    'Shorts': 'Crop tops',
    'Skirts': 'Crop tops',
    'Dresses': 'Crop tops',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Categories',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.search, color: Colors.black, size: 22),
              onPressed: () {}),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => CatalogScreen(
                      categoryName: "$gender's $parentCategory",
                      gender: gender,
                      initialChip: 'T-shirts',
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('VIEW ALL ITEMS',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5)),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
            child: Text('Choose category',
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                    fontWeight: FontWeight.w400)),
          ),

          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _subCategories.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (_, i) {
                final sub = _subCategories[i];
                final chipKey = _chipToKey[sub] ?? 'T-shirts';
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  title: Text(sub,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87)),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) => CatalogScreen(
                        categoryName: sub,
                        gender: gender,
                        initialChip: chipKey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}