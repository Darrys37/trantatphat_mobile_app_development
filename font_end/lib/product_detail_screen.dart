import 'package:flutter/material.dart';
import 'package:trantatphat/models/product.dart';
import 'package:trantatphat/services/product_service.dart';
import 'package:trantatphat/services/favorite_service.dart';
import 'package:trantatphat/services/cart_service.dart';
import 'package:trantatphat/rating_review_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String selectedSize = 'Size';
  String selectedColor = 'Black';
  bool isFavorite = false;
  late Future<List<Product>> _relatedProductsFuture;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Using new products as a placeholder for "You can also like this"
    _relatedProductsFuture = ProductService().fetchNewProducts();
    _checkFavoriteStatus();
    FavoriteService.favoritesChangedNotifier.addListener(_onFavoritesChanged);
  }

  void _onFavoritesChanged() {
    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    FavoriteService.favoritesChangedNotifier.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _checkFavoriteStatus() async {
    if (widget.product.id != null) {
      bool status = await FavoriteService().checkFavorite(widget.product.id!);
      if (mounted) {
        setState(() {
          isFavorite = status;
        });
      }
    }
  }

  void _toggleFavorite() async {
    if (widget.product.id == null) return;
    setState(() {
      isFavorite = !isFavorite; // Optimistic update
    });
    
    bool success;
    if (isFavorite) {
      success = await FavoriteService().addFavorite(widget.product.id!);
    } else {
      success = await FavoriteService().removeFavorite(widget.product.id!);
    }

    if (!success && mounted) {
      // Revert if failed
      setState(() {
        isFavorite = !isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update favorites')),
      );
    } else if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSizeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              // Handle
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              const Text(
                'Select size',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Grid of sizes
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: ['XS', 'S', 'M', 'L', 'XL'].map((size) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSize = size;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 100,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedSize == size ? const Color(0xFFDB3022) : Colors.white,
                        border: Border.all(
                          color: selectedSize == size ? const Color(0xFFDB3022) : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        size,
                        style: TextStyle(
                          color: selectedSize == size ? Colors.white : Colors.black,
                          fontWeight: selectedSize == size ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1, thickness: 1, color: Colors.black12),
              // Size info
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Size info', style: TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.keyboard_arrow_right, size: 20),
                onTap: () {},
              ),
              const SizedBox(height: 16),
              // Add to cart button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (!isFavorite) {
                      _toggleFavorite();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB3022),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'ADD TO FAVORITES',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16), // space for bottom safe area
            ],
          ),
        )));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product.name,
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _checkFavoriteStatus();
          setState(() {
            _relatedProductsFuture = ProductService().fetchNewProducts();
          });
          await _relatedProductsFuture;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Product Image Carousel
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: PageView.builder(
                    itemCount: 3,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      List<String?> dummyImages = [
                        widget.product.imageUrl,
                        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                      ];
                      String? currentUrl = dummyImages[index];

                      return Container(
                        color: Colors.grey[200],
                        child: currentUrl != null && currentUrl.isNotEmpty
                            ? (currentUrl.startsWith('assets/')
                                ? Image.asset(currentUrl, fit: BoxFit.cover)
                                : Image.network(currentUrl, fit: BoxFit.cover))
                            : const Icon(Icons.image, size: 100, color: Colors.grey),
                      );
                    },
                  ),
                ),
                // Indicator
                Positioned(
                  bottom: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 4,
                        width: _currentImageIndex == index ? 24 : 12,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index ? const Color(0xFFDB3022) : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),

            // 2. Options Row (Size, Color, Favorite)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: InkWell(
                        onTap: () {
                          _showSizeBottomSheet(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(selectedSize),
                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedColor,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: ['Black', 'White', 'Red', 'Blue'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              if (newValue != null) selectedColor = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? const Color(0xFFDB3022) : Colors.grey,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  )
                ],
              ),
            ),

            // 3. Product Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.product.brand ?? 'Lumina',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${widget.product.salePrice != null ? widget.product.salePrice!.toStringAsFixed(2) : widget.product.price?.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                widget.product.name,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  if (widget.product.id != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RatingReviewScreen(
                          productId: widget.product.id!,
                          rating: widget.product.rating ?? 0.0,
                          reviewCount: widget.product.reviewCount ?? 0,
                        ),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    ...List.generate(5, (starIndex) {
                      double rating = widget.product.rating ?? 0.0;
                      return Icon(
                        starIndex < rating.floor() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                    const SizedBox(width: 4),
                    Text('(${widget.product.reviewCount ?? 0} reviews)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.product.description != null && widget.product.description!.isNotEmpty 
                    ? widget.product.description! 
                    : 'Discover the perfect blend of comfort and style with our ${widget.product.name}. Carefully crafted by ${widget.product.brand ?? 'our top designers'}, this piece features high-quality materials designed for long-lasting wear. Whether you\'re dressing up for a special occasion or keeping it casual, this item is a versatile addition to your everyday wardrobe.',
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),

            // 4. Add to Cart Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (widget.product.id != null) {
                      bool success = await cartService.addToCart(
                        widget.product.id!,
                        selectedColor,
                        selectedSize == 'Size' ? 'M' : selectedSize,
                        1,
                      );
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB3022),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'ADD TO CART',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ),
            
            const Divider(height: 1, thickness: 1, color: Colors.black12),

            // 5. Expandable Tiles
            ListTile(
              title: const Text('Shipping info', style: TextStyle(fontSize: 16)),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {},
            ),
            const Divider(height: 1, thickness: 1, color: Colors.black12),
            ListTile(
              title: const Text('Support', style: TextStyle(fontSize: 16)),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {},
            ),
            const Divider(height: 1, thickness: 1, color: Colors.black12),

            // 6. You can also like this
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'You can also like this',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '12 items',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            FutureBuilder<List<Product>>(
              future: _relatedProductsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 280,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox(height: 280);
                }

                // Filter out the current product and ensure uniqueness by ID
                final List<Product> uniqueProducts = [];
                final Set<String> seenIds = {};
                for (var p in snapshot.data!) {
                  if (p.id != widget.product.id && p.id != null && !seenIds.contains(p.id)) {
                    seenIds.add(p.id!);
                    uniqueProducts.add(p);
                  }
                }

                return SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16),
                    itemCount: uniqueProducts.length,
                    itemBuilder: (context, index) {
                      return _buildRelatedProductCard(uniqueProducts[index]);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildRelatedProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 184,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: product.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: product.imageUrl!.startsWith('assets/')
                              ? Image.asset(product.imageUrl!, fit: BoxFit.cover)
                              : Image.network(product.imageUrl!, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.image, color: Colors.grey),
                ),
                if (product.price != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDB3022),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '-${(((product.price ?? 1) - (product.salePrice ?? 0)) / (product.price == null || product.price == 0 ? 1 : product.price!) * 100).round()}%',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (index) => Icon(
                      index < (product.rating ?? 0).floor() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 14,
                    )),
                const SizedBox(width: 4),
                Text('(${product.reviewCount ?? 0})', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              product.brand ?? 'Lumina',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              product.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (product.price != null)
                  Text(
                    '${product.price}\$',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                if (product.price != null) const SizedBox(width: 4),
                Text(
                  '${product.salePrice ?? product.price ?? 0}\$',
                  style: TextStyle(
                    fontSize: 14,
                    color: product.price != null ? const Color(0xFFDB3022) : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
