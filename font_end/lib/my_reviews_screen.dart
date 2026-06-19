import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_end/models/review.dart';
import 'package:font_end/services/product_service.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _productService.fetchUserReviews();
  }

  Future<void> _refreshReviews() async {
    setState(() {
      _reviewsFuture = _productService.fetchUserReviews();
    });
    await _reviewsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Reviews',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<Review>>(
                future: _reviewsFuture,
                builder: (context, snapshot) {
                  Widget content;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    content = const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    content = Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    content = const Center(
                      child: Text(
                        'Bạn chưa viết đánh giá nào.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  } else {
                    final reviews = snapshot.data!;
                    content = ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        return _buildReviewCard(reviews[index]);
                      },
                    );
                  }

                  if (content is Center) {
                    content = ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                        content,
                      ],
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshReviews,
                    child: content,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            review.productName ?? 'Sản phẩm',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFBA49),
                    size: 16,
                  );
                }),
              ),
              if (review.createdAt != null)
                Text(
                  "${review.createdAt!.day}/${review.createdAt!.month}/${review.createdAt!.year}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.content,
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                itemBuilder: (context, imgIndex) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                      image: review.images[imgIndex].startsWith('http')
                          ? DecorationImage(
                              image: NetworkImage(review.images[imgIndex]),
                              fit: BoxFit.cover,
                            )
                          : (review.images[imgIndex].startsWith('assets')
                              ? DecorationImage(
                                  image: AssetImage(review.images[imgIndex]),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: MemoryImage(base64Decode(review.images[imgIndex])),
                                  fit: BoxFit.cover,
                                )),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Helpful (${review.helpfulCount})',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.thumb_up_alt_outlined, color: Colors.grey, size: 14),
            ],
          )
        ],
      ),
    );
  }
}
