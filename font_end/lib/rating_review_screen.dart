import 'package:flutter/material.dart';
import 'package:trantatphat/models/review.dart';
import 'package:trantatphat/services/product_service.dart';
import 'package:trantatphat/write_review_bottom_sheet.dart';
import 'dart:convert';

class RatingReviewScreen extends StatefulWidget {
  final String productId;
  final double rating;
  final int reviewCount;

  const RatingReviewScreen({
    super.key, 
    required this.productId,
    required this.rating,
    required this.reviewCount,
  });

  @override
  State<RatingReviewScreen> createState() => _RatingReviewScreenState();
}

class _RatingReviewScreenState extends State<RatingReviewScreen> {
  bool withPhoto = false;
  late Future<List<Review>> _reviewsFuture;
  bool _hasReviewed = false;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ProductService().fetchReviews(widget.productId);
    _checkUserReviewStatus();
  }

  Future<void> _checkUserReviewStatus() async {
    bool hasReviewed = await ProductService().hasUserReviewed(widget.productId);
    if (mounted) {
      setState(() {
        _hasReviewed = hasReviewed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Review>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final allReviews = snapshot.data ?? [];
          final reviews = withPhoto ? allReviews.where((r) => r.images.isNotEmpty).toList() : allReviews;

          // Calculate bar chart
          final int total = allReviews.length;
          final List<int> counts = [0, 0, 0, 0, 0]; // 1, 2, 3, 4, 5 stars
          for (var r in allReviews) {
            int star = r.rating.round().clamp(1, 5);
            counts[star - 1]++;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rating&Reviews',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  
                  // Rating summary
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Text(
                            widget.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${widget.reviewCount} ratings',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Bar chart
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(5, (index) {
                          int star = 5 - index;
                          int count = counts[star - 1];
                          double ratio = total == 0 ? 0 : count / total;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < star ? Icons.star : Icons.star_border,
                                      color: i < star ? Colors.amber : Colors.transparent,
                                      size: 14,
                                    );
                                  }),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 120,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: 120 * ratio,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDB3022),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 24,
                                  child: Text(
                                    '$count',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Header with reviews count & photo filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${reviews.length} reviews',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: withPhoto,
                            onChanged: (val) {
                              setState(() {
                                withPhoto = val ?? false;
                              });
                            },
                            activeColor: Colors.black,
                          ),
                          const Text('With photo', style: TextStyle(fontSize: 14)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Reviews List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      return _buildReviewCard(reviews[index]);
                    },
                  ),
                  const SizedBox(height: 80), // space for FAB
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _hasReviewed 
          ? null 
          : FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: const Color(0xFFF9F9F9),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
            ),
            builder: (context) => WriteReviewBottomSheet(
              productId: widget.productId,
              onReviewSubmitted: () {
                setState(() {
                  _reviewsFuture = ProductService().fetchReviews(widget.productId);
                });
                _checkUserReviewStatus();
              },
            ),
          );
        },
        backgroundColor: const Color(0xFFDB3022),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('Write a review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review.rating.floor() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 14,
                      );
                    }),
                  ),
                  Text(
                    review.createdAt != null 
                        ? '${_monthStr(review.createdAt!.month)} ${review.createdAt!.day}, ${review.createdAt!.year}'
                        : 'Unknown date',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                review.content,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              if (review.images.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 104,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: review.images.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: review.images[index].startsWith('http')
                          ? Image.network(
                              review.images[index],
                              width: 104,
                              height: 104,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 104,
                                height: 104,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                            )
                          : (review.images[index].startsWith('assets')
                            ? Image.asset(
                                review.images[index],
                                width: 104,
                                height: 104,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 104,
                                  height: 104,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, color: Colors.grey),
                                ),
                              )
                            : Image.memory(
                                base64Decode(review.images[index]),
                                width: 104,
                                height: 104,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 104,
                                  height: 104,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              )),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Helpful', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(width: 4),
                  Icon(Icons.thumb_up, color: review.helpfulCount > 0 ? const Color(0xFFDB3022) : Colors.grey, size: 14),
                ],
              ),
            ],
          ),
        ),
        // Avatar positioned over the top left edge
        Positioned(
          top: 0,
          left: 0,
          child: CircleAvatar(
            radius: 20,
            backgroundImage: review.userAvatar != null ? NetworkImage(review.userAvatar!) : null,
            child: review.userAvatar == null ? const Icon(Icons.person) : null,
          ),
        )
      ],
    );
  }

  String _monthStr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
