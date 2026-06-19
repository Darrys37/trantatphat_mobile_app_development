import 'package:flutter/material.dart';
import 'package:trantatphat/models/product.dart';
import 'package:trantatphat/services/favorite_service.dart';
import 'package:trantatphat/services/cart_service.dart';
import 'package:trantatphat/product_detail_screen.dart';
import 'package:trantatphat/main_screen.dart';
import 'package:trantatphat/filters_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool isGridView = false;
  bool _isAscending = true;
  late Future<List<Product>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    FavoriteService.favoritesChangedNotifier.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    FavoriteService.favoritesChangedNotifier.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoritesFuture = FavoriteService().getFavorites();
    });
  }

  Future<void> _removeFavorite(String productId) async {
    bool success = await FavoriteService().removeFavorite(productId);
    if (success) {
      _loadFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites'), duration: Duration(seconds: 2)),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove from favorites'), duration: Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Favorites', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 34)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('Summer', true),
                _buildFilterChip('T-Shirts', false),
                _buildFilterChip('Shirts', false),
                _buildFilterChip('Pants', false),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tool Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FiltersScreen()),
                    );
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.filter_list, size: 20),
                      SizedBox(width: 4),
                      Text('Filters', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isAscending = !_isAscending;
                    });
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.swap_vert, size: 20),
                      const SizedBox(width: 4),
                      Text(_isAscending ? 'Price: lowest to high' : 'Price: highest to low', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(isGridView ? Icons.view_list : Icons.view_module, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      isGridView = !isGridView;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Product List
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _favoritesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return RefreshIndicator(
                    onRefresh: () async { _loadFavorites(); await _favoritesFuture; },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text("Error loading favorites")),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async { _loadFavorites(); await _favoritesFuture; },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text("No favorites yet.")),
                      ],
                    ),
                  );
                }

                final favorites = List<Product>.from(snapshot.data!);
                favorites.sort((a, b) {
                  final priceA = a.salePrice ?? a.price ?? 0.0;
                  final priceB = b.salePrice ?? b.price ?? 0.0;
                  return _isAscending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
                });

                if (isGridView) {
                  return RefreshIndicator(
                    onRefresh: () async { _loadFavorites(); await _favoritesFuture; },
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        return _buildGridItem(favorites[index]);
                      },
                    ),
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: () async { _loadFavorites(); await _favoritesFuture; },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        return _buildListItem(favorites[index]);
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildListItem(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)));
      },
      child: Container(
        height: 110,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Image
                SizedBox(
                  width: 110,
                  height: 110,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                    child: product.imageUrl != null 
                        ? (product.imageUrl!.startsWith('assets/') 
                            ? Image.asset(product.imageUrl!, fit: BoxFit.cover)
                            : Image.network(product.imageUrl!, fit: BoxFit.cover))
                        : Container(color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
                  ),
                ),
                // Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.brand ?? 'Lumina', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('Color: ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const Text('Black', style: TextStyle(fontSize: 11, color: Colors.black)),
                            const SizedBox(width: 12),
                            const Text('Size: ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const Text('L', style: TextStyle(fontSize: 11, color: Colors.black)),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              '${product.salePrice ?? product.price ?? 0}\$',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            ...List.generate(5, (index) => Icon(
                              index < (product.rating ?? 0).floor() ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 12,
                            )),
                            const SizedBox(width: 4),
                            Text('(${product.reviewCount ?? 0})', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Remove Button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  if (product.id != null) _removeFavorite(product.id!);
                },
                child: const Icon(Icons.close, color: Colors.grey, size: 20),
              ),
            ),
            // Bag Button
            Positioned(
              bottom: -16,
              right: 0,
              child: GestureDetector(
                onTap: () async {
                  if (product.id != null) {
                    bool success = await cartService.addToCart(product.id!, 'Black', 'L', 1);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Added to bag' : 'Failed to add to bag'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 12, bottom: 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDB3022),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: const Icon(Icons.shopping_bag, color: Colors.white, size: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)));
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                      child: product.imageUrl != null 
                          ? (product.imageUrl!.startsWith('assets/') 
                              ? Image.asset(product.imageUrl!, fit: BoxFit.cover)
                              : Image.network(product.imageUrl!, fit: BoxFit.cover))
                          : Container(color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
                    ),
                  ),
                ),
                // Details
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ...List.generate(5, (index) => Icon(
                            index < (product.rating ?? 0).floor() ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 10,
                          )),
                          const SizedBox(width: 4),
                          Text('(${product.reviewCount ?? 0})', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(product.brand ?? 'Lumina', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('Color: ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const Text('Black', style: TextStyle(fontSize: 11, color: Colors.black)),
                          const SizedBox(width: 8),
                          const Text('Size: ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const Text('L', style: TextStyle(fontSize: 11, color: Colors.black)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.salePrice ?? product.price ?? 0}\$',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Remove Button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                if (product.id != null) _removeFavorite(product.id!);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.grey, size: 16),
              ),
            ),
          ),
          // Bag Button
          Positioned(
            bottom: 60,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                if (product.id != null) {
                  bool success = await cartService.addToCart(product.id!, 'Black', 'L', 1);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Added to bag' : 'Failed to add to bag'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 8), 
                decoration: const BoxDecoration(
                  color: Color(0xFFDB3022),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: const Icon(Icons.shopping_bag, color: Colors.white, size: 18),
              ),
            ),
          )
        ],
      ),
    );
  }
}
