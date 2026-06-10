import 'package:flutter/material.dart';
import 'product_detail_screen.dart';
import 'product_data.dart';

class CatalogScreen extends StatefulWidget {
  final String categoryName;
  final String gender;
  final String initialChip;

  const CatalogScreen({
    super.key,
    required this.categoryName,
    this.gender = 'Women',
    this.initialChip = 'T-shirts',
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool _isGrid = false;
  String _sortBy = 'Price: lowest to high';
  late String _selectedChip;

  static const _chips = ['T-shirts', 'Crop tops', 'Sleeveless', 'Blouses'];

  @override
  void initState() {
    super.initState();
    _selectedChip = widget.initialChip;
  }

  List<Map<String, dynamic>> get _displayProducts {
    final genderData = genderProducts[widget.gender] ?? genderProducts['Women']!;
    final base = List<Map<String, dynamic>>.from(
      (genderData[_selectedChip] as List?) ?? genderData['T-shirts']!,
    );
    if (_sortBy == 'Price: lowest to high') {
      base.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
    } else if (_sortBy == 'Price: highest to low') {
      base.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final products = _displayProducts;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.categoryName,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {}),
        ],
      ),
      body: Column(children: [
        // ── Chips ────────────────────────────────────────────────────────────
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: _chips.map((chip) {
              final selected = _selectedChip == chip;
              return GestureDetector(
                onTap: () => setState(() => _selectedChip = chip),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: selected ? Colors.black : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Row(children: [
                    if (selected) ...[
                      const Icon(Icons.check, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                    ],
                    Text(chip,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        )),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),

        // ── Sort & Filter bar ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FiltersScreen())),
              child: Row(children: [
                const Icon(Icons.tune, size: 18, color: Colors.black54),
                const SizedBox(width: 4),
                Text('Filters',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ]),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: _showSortSheet,
              child: Row(children: [
                const Icon(Icons.sort, size: 18, color: Colors.black54),
                const SizedBox(width: 4),
                Text(_sortBy,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ]),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _isGrid = !_isGrid),
              child: Icon(_isGrid ? Icons.view_list : Icons.grid_view,
                  size: 22, color: Colors.black54),
            ),
          ]),
        ),

        // ── Product list / grid ───────────────────────────────────────────
        Expanded(
          child: _isGrid
              ? GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) => _ProductGridCard(
                    product: Map<String, dynamic>.from(products[i]),
                    onFavorite: () => setState(() {}),
                    onTap: () => _openProduct(products[i]),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey[100]),
                  itemBuilder: (_, i) => _ProductListCard(
                    product: Map<String, dynamic>.from(products[i]),
                    onFavorite: () => setState(() {}),
                    onTap: () => _openProduct(products[i]),
                  ),
                ),
        ),
      ]),
    );
  }

  void _openProduct(Map<String, dynamic> p) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
  }

  void _showSortSheet() {
    final options = [
      'Popular', 'Newest', 'Customer review',
      'Price: lowest to high', 'Price: highest to low',
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Sort by',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18))),
            ...options.map((o) {
              final active = _sortBy == o;
              return ListTile(
                tileColor: active ? const Color(0xFFE53935) : null,
                title: Text(o,
                    style: TextStyle(
                      color: active ? Colors.white : Colors.black,
                      fontWeight:
                          active ? FontWeight.bold : FontWeight.normal,
                    )),
                onTap: () {
                  setState(() => _sortBy = o);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── List Card ────────────────────────────────────────────────────────────────
class _ProductListCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const _ProductListCard(
      {required this.product,
      required this.onFavorite,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          // Image
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product['image'],
                width: 110,
                height: 130,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        width: 110,
                        height: 130,
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10)),
                        child: const Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFE53935))),
                      ),
                errorBuilder: (_, __, ___) => Container(
                  width: 110,
                  height: 130,
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: Colors.grey, size: 32),
                ),
              ),
            ),
            if (product['discount'] != null)
              Positioned(
                top: 8, left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(5)),
                  child: Text('-${product['discount']}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ]),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(product['name'],
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 2),
              Text(product['brand'],
                  style:
                      TextStyle(color: Colors.grey[500], fontSize: 13)),
              const SizedBox(height: 6),
              if ((product['reviews'] as int) > 0)
                _StarRow(
                    rating: (product['rating'] as num).toDouble(),
                    reviews: product['reviews']),
              const SizedBox(height: 6),
              Row(children: [
                if (product['oldPrice'] != null) ...[
                  Text('\$${product['oldPrice']}',
                      style: const TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 13)),
                  const SizedBox(width: 6),
                ],
                Text('\$${product['price']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 18)),
              ]),
            ]),
          ),

          // Favorite
          IconButton(
            icon: Icon(
              (product['isFavorite'] as bool)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: (product['isFavorite'] as bool)
                  ? const Color(0xFFE53935)
                  : Colors.grey[400],
              size: 22,
            ),
            onPressed: onFavorite,
          ),
        ]),
      ),
    );
  }
}

// ─── Grid Card ────────────────────────────────────────────────────────────────
class _ProductGridCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const _ProductGridCard(
      {required this.product,
      required this.onFavorite,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product['image'],
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        color: Colors.grey[100],
                        child: const Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFE53935)))),
                errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[100],
                    child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 32)),
              ),
            ),
            if (product['discount'] != null)
              Positioned(
                top: 8, left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(5)),
                  child: Text('-${product['discount']}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: onFavorite,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4)
                      ]),
                  child: Icon(
                    (product['isFavorite'] as bool)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: (product['isFavorite'] as bool)
                        ? const Color(0xFFE53935)
                        : Colors.grey,
                    size: 16,
                  ),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 6),
        if ((product['reviews'] as int) > 0)
          _StarRow(
              rating: (product['rating'] as num).toDouble(),
              reviews: product['reviews'],
              size: 12),
        Text(product['brand'],
            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        Text(product['name'],
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        Row(children: [
          if (product['oldPrice'] != null) ...[
            Text('\$${product['oldPrice']}',
                style: const TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                    fontSize: 11)),
            const SizedBox(width: 4),
          ],
          Text('\$${product['price']}',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ]),
      ]),
    );
  }
}

// ─── Star Row ─────────────────────────────────────────────────────────────────
class _StarRow extends StatelessWidget {
  final double rating;
  final int reviews;
  final double size;
  const _StarRow(
      {required this.rating, required this.reviews, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ...List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star, color: Colors.amber, size: size);
        } else if (i < rating) {
          return Icon(Icons.star_half, color: Colors.amber, size: size);
        }
        return Icon(Icons.star_border, color: Colors.amber, size: size);
      }),
      const SizedBox(width: 4),
      Text('($reviews)',
          style: TextStyle(fontSize: size - 2, color: Colors.grey[500])),
    ]);
  }
}

// ─── Filters Screen ───────────────────────────────────────────────────────────
class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});
  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  RangeValues _priceRange = const RangeValues(78, 143);
  final Set<int> _selectedColors = {};
  final Set<String> _selectedSizes = {'S', 'M'};
  String _selectedCategory = 'All';

  static const _colorValues = [
    0xFF000000, 0xFF9E9E9E, 0xFFE53935, 0xFFD3B8AE, 0xFFD4A853, 0xFF1565C0,
  ];
  static const _sizes = ['XS', 'S', 'M', 'L', 'XL'];
  static const _categories = ['All', 'Women', 'Men', 'Boys', 'Girls'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Filters',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Price range',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('\$${_priceRange.start.round()}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('\$${_priceRange.end.round()}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ]),
              RangeSlider(
                values: _priceRange, min: 0, max: 500,
                activeColor: const Color(0xFFE53935),
                inactiveColor: Colors.grey[200],
                onChanged: (v) => setState(() => _priceRange = v),
              ),
              const SizedBox(height: 16),
              const Text('Colors',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(spacing: 12, children: _colorValues.asMap().entries.map((e) {
                final sel = _selectedColors.contains(e.key);
                return GestureDetector(
                  onTap: () => setState(() =>
                      sel ? _selectedColors.remove(e.key) : _selectedColors.add(e.key)),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Color(e.value), shape: BoxShape.circle,
                      border: sel ? Border.all(color: Colors.black, width: 2.5) : null,
                    ),
                  ),
                );
              }).toList()),
              const SizedBox(height: 20),
              const Text('Sizes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(spacing: 10, children: _sizes.map((s) {
                final sel = _selectedSizes.contains(s);
                return GestureDetector(
                  onTap: () => setState(() =>
                      sel ? _selectedSizes.remove(s) : _selectedSizes.add(s)),
                  child: Container(
                    width: 52, height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFFE53935) : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: sel ? const Color(0xFFE53935) : Colors.grey[300]!),
                    ),
                    child: Text(s, style: TextStyle(
                        color: sel ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500)),
                  ),
                );
              }).toList()),
              const SizedBox(height: 20),
              const Text('Category',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(spacing: 10, runSpacing: 10, children: _categories.map((c) {
                final sel = _selectedCategory == c;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFFE53935) : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: sel ? const Color(0xFFE53935) : Colors.grey[300]!),
                    ),
                    child: Text(c, style: TextStyle(
                        color: sel ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500)),
                  ),
                );
              }).toList()),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BrandFilterScreen())),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(children: [
                    const Text('Brand',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    Text('adidas Originals, Jack & Jones, s.Oliver',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ]),
                ),
              ),
            ]),
          ),
        ),
        _FilterButtons(
          onDiscard: () => Navigator.pop(context),
          onApply: () => Navigator.pop(context),
        ),
      ]),
    );
  }
}

// ─── Brand Filter ─────────────────────────────────────────────────────────────
class BrandFilterScreen extends StatefulWidget {
  const BrandFilterScreen({super.key});
  @override
  State<BrandFilterScreen> createState() => _BrandFilterScreenState();
}

class _BrandFilterScreenState extends State<BrandFilterScreen> {
  final _ctrl = TextEditingController();
  final Set<String> _selected = {'adidas Originals', 'Jack & Jones', 's.Oliver'};
  static const _brands = [
    'adidas', 'adidas Originals', 'Blend', 'Boutique Moschino',
    'Champion', 'Diesel', 'Jack & Jones', 'Naf Naf', 'Red Valentino', 's.Oliver',
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _brands
        .where((b) => b.toLowerCase().contains(_ctrl.text.toLowerCase()))
        .toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Brand',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _ctrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true, fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: ListView(children: filtered.map((b) {
            final sel = _selected.contains(b);
            return ListTile(
              title: Text(b, style: TextStyle(
                  color: sel ? const Color(0xFFE53935) : Colors.black,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
              trailing: Checkbox(
                value: sel, activeColor: const Color(0xFFE53935),
                onChanged: (_) => setState(() =>
                    sel ? _selected.remove(b) : _selected.add(b)),
              ),
              onTap: () => setState(() =>
                  sel ? _selected.remove(b) : _selected.add(b)),
            );
          }).toList()),
        ),
        _FilterButtons(
          onDiscard: () => Navigator.pop(context),
          onApply: () => Navigator.pop(context),
        ),
      ]),
    );
  }
}

class _FilterButtons extends StatelessWidget {
  final VoidCallback onDiscard;
  final VoidCallback onApply;
  const _FilterButtons({required this.onDiscard, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onDiscard,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Discard',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Apply',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }
}