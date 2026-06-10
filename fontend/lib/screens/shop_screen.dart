import 'package:flutter/material.dart';
import 'catalog_screen.dart';
import 'product_data.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.maybePop(context),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFE53935),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFE53935),
          indicatorWeight: 2.5,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
          tabs: const [
            Tab(text: 'Women'),
            Tab(text: 'Men'),
            Tab(text: 'Kids'),
          ],
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
class _CategoriesTab extends StatelessWidget {
  final String gender;
  const _CategoriesTab({required this.gender});

  static const _categoryNames = ['New', 'Clothes', 'Shoes', 'Accessories'];

  @override
  Widget build(BuildContext context) {
    final images = categoryImages[gender]!;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Summer Sales Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(children: [
                Text('SUMMER SALES',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
                SizedBox(height: 4),
                Text('Up to 50% off',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ]),
            ),
          ),

          const SizedBox(height: 8),

          // Category rows
          ..._categoryNames.map((name) => _CategoryRow(
                name: name,
                imageUrl: images[name]!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoriesSubScreen(
                      parentCategory: name,
                      gender: gender,
                    ),
                  ),
                ),
              )),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Category Row with border ─────────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onTap;

  const _CategoryRow(
      {required this.name, required this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(children: [
            Text(name,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 72,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        width: 100,
                        height: 72,
                        color: Colors.grey[100],
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFE53935)),
                          ),
                        ),
                      ),
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 72,
                  color: Colors.grey[100],
                  child: const Icon(Icons.image_outlined,
                      color: Colors.grey, size: 28),
                ),
              ),
            ),
          ]),
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
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('VIEW ALL ITEMS',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 1.2)),
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