import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ─── Reviews Manager ──────────────────────────────────────────────────────────
class ReviewsManager {
  ReviewsManager._();
  static final ReviewsManager instance = ReviewsManager._();

  final Map<String, List<Map<String, dynamic>>> _productReviews = {};
  // Tracks which product keys the current user has already reviewed
  final Set<String> _reviewedProducts = {};

  static final List<Map<String, dynamic>> _staticReviews = [
    {
      'name': 'Helene Moore', 'date': 'June 5, 2019', 'rating': 3.5,
      'text': 'The dress is great! Very classy and comfortable. It fit perfectly! I\'m 5\'7\" and 130 pounds. I am a 34B chest. This dress would be too long for those who are shorter but could be hemmed.',
      'helpful': 1, 'photos': <String>[],
    },
    {
      'name': 'Kim Shine', 'date': 'August 13, 2019', 'rating': 3.5,
      'text': 'I loved this dress so much as soon as I tried it on I knew I had to buy it in another color. I am 5\'3 about 155lbs and I carry all my weight in my upper body. When I put it on I felt like it thinned me and I got so many compliments.',
      'helpful': 4,
      'photos': [
        'https://images.pexels.com/photos/1536619/pexels-photo-1536619.jpeg?auto=compress&w=200',
        'https://images.pexels.com/photos/1759622/pexels-photo-1759622.jpeg?auto=compress&w=200',
        'https://images.pexels.com/photos/2065195/pexels-photo-2065195.jpeg?auto=compress&w=200',
      ],
    },
    {
      'name': 'Matilda Brown', 'date': 'August 14, 2019', 'rating': 4.0,
      'text': 'I loved this dress so much as soon as I tried it on I knew I had to buy it in another color. I am 5\'3 about 155lbs and I carry all my weight in my upper body.',
      'helpful': 2, 'photos': <String>[],
    },
  ];

  static String keyOf(Map<String, dynamic> product) {
    final id = product['id'] as String?;
    if (id != null) return id;
    return "${product['brand']}__${product['name']}";
  }

  List<Map<String, dynamic>> getReviews(Map<String, dynamic> product) {
    final key = keyOf(product);
    if (!_productReviews.containsKey(key)) {
      _productReviews[key] = List.from(
          _staticReviews.map((r) => Map<String, dynamic>.from(r)));
    }
    return _productReviews[key]!;
  }

  bool hasReviewed(Map<String, dynamic> product) {
    return _reviewedProducts.contains(keyOf(product));
  }

  void addReview(Map<String, dynamic> product, Map<String, dynamic> review) {
    final key = keyOf(product);
    if (!_productReviews.containsKey(key)) getReviews(product);
    _productReviews[key]!.insert(0, review);
    _reviewedProducts.add(key);
  }

  int getReviewCount(Map<String, dynamic> product) {
    final key = keyOf(product);
    if (_productReviews.containsKey(key)) return _productReviews[key]!.length;
    return product['reviews'] ?? 0;
  }

  double getAverageRating(Map<String, dynamic> product) {
    final key = keyOf(product);
    if (_productReviews.containsKey(key)) {
      final list = _productReviews[key]!;
      if (list.isEmpty) return 0.0;
      double sum = list
          .map((r) => (r['rating'] as num).toDouble())
          .reduce((a, b) => a + b);
      return sum / list.length;
    }
    return ((product['rating'] ?? 0.0) as num).toDouble();
  }
}

// ─── Rating & Reviews Screen ──────────────────────────────────────────────────
class RatingReviewsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const RatingReviewsScreen({super.key, required this.product});

  @override
  State<RatingReviewsScreen> createState() => _RatingReviewsScreenState();
}

class _RatingReviewsScreenState extends State<RatingReviewsScreen> {
  bool _withPhoto = false;
  late final List<Map<String, dynamic>> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = ReviewsManager.instance.getReviews(widget.product);
  }

  List<Map<String, dynamic>> get _filtered => _withPhoto
      ? _reviews.where((r) => (r['photos'] as List).isNotEmpty).toList()
      : _reviews;

  double get _avgRating {
    if (_reviews.isEmpty) return 0;
    return _reviews
            .map((r) => (r['rating'] as num).toDouble())
            .reduce((a, b) => a + b) /
        _reviews.length;
  }

  bool get _alreadyReviewed =>
      ReviewsManager.instance.hasReviewed(widget.product);

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
        title: const Text('Rating and reviews',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 17)),
        centerTitle: true,
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Rating summary ──────────────────────────────────────────
              const Text('Rating&Reviews',
                  style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Column(children: [
                  Text(_avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.w800)),
                  Text('${_reviews.length} ratings',
                      style:
                          TextStyle(color: Colors.grey[500], fontSize: 12)),
                ]),
                const SizedBox(width: 20),
                Expanded(child: _RatingBars(reviews: _reviews)),
              ]),
              const SizedBox(height: 20),

              // ── Reviews header ──────────────────────────────────────────
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${_reviews.length} reviews',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                Row(children: [
                  Checkbox(
                    value: _withPhoto,
                    activeColor: Colors.black,
                    onChanged: (v) => setState(() => _withPhoto = v!),
                  ),
                  const Text('With photo', style: TextStyle(fontSize: 14)),
                ]),
              ]),
              const SizedBox(height: 12),

              // ── Review list ─────────────────────────────────────────────
              ..._filtered.map((r) => _ReviewCard(review: r)),
              const SizedBox(height: 16),
            ]),
          ),
        ),

        // ── Write a review / Already reviewed ──────────────────────────
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _alreadyReviewed
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'You have already reviewed this product',
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => WriteReviewScreen(
                                    onSubmit: (rev) {
                                      ReviewsManager.instance
                                          .addReview(widget.product, rev);
                                      setState(() {});
                                    },
                                  ))),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Write a review',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
          ),
        ),
      ]),
    );
  }
}

// ─── Rating bars ──────────────────────────────────────────────────────────────
class _RatingBars extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;
  const _RatingBars({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final counts = List.generate(
        5,
        (i) => reviews
            .where((r) => ((r['rating'] as num).toDouble().round()) == 5 - i)
            .length);
    final max =
        counts.isEmpty ? 1 : counts.reduce((a, b) => a > b ? a : b);

    return Column(
      children: List.generate(
          5,
          (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: [
                  Text('${5 - i}',
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: max == 0 ? 0 : counts[i] / max,
                        backgroundColor: Colors.grey[200],
                        color: const Color(0xFFE53935),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                      width: 16,
                      child: Text('${counts[i]}',
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.right)),
                ]),
              )),
    );
  }
}

// ─── Review Card ─────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final photos = review['photos'] as List;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[300],
            child: Text(review['name'].toString()[0],
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(review['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Row(children: [
                  ...List.generate(5, (i) {
                    final r = (review['rating'] as num).toDouble();
                    if (i < r.floor())
                      return const Icon(Icons.star,
                          color: Colors.amber, size: 13);
                    if (i < r)
                      return const Icon(Icons.star_half,
                          color: Colors.amber, size: 13);
                    return const Icon(Icons.star_border,
                        color: Colors.amber, size: 13);
                  }),
                ]),
              ])),
          Text(review['date'],
              style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        ]),
        const SizedBox(height: 10),
        Text(review['text'],
            style: TextStyle(
                color: Colors.grey[700], fontSize: 13, height: 1.5)),

        if (photos.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (_, i) {
                final p = photos[i];
                final isFile = p is String && !p.startsWith('http');
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isFile
                        ? Image.file(File(p),
                            width: 80, height: 80, fit: BoxFit.cover)
                        : Image.network(p,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200])),
                  ),
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('Helpful',
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(width: 4),
          Icon(Icons.thumb_up_outlined,
              size: 14, color: Colors.grey[500]),
        ]),
      ]),
    );
  }
}

// ─── Write Review Screen ──────────────────────────────────────────────────────
class WriteReviewScreen extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSubmit;
  const WriteReviewScreen({super.key, required this.onSubmit});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  double _rating = 0;
  final _ctrl = TextEditingController();
  final List<String> _photos = []; // stores file paths from image_picker
  final _picker = ImagePicker();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_photos.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 3 photos')));
      return;
    }
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (file != null) {
      setState(() => _photos.add(file.path));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE53935),
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
              title: const Text('Take a photo',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1976D2),
                child: Icon(Icons.photo_library, color: Colors.white),
              ),
              title: const Text('Choose from library',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Rating and reviews',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(children: [
                  // ── Stars ────────────────────────────────────────────
                  const Text('What is your rate?',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          5,
                          (i) => GestureDetector(
                                onTap: () =>
                                    setState(() => _rating = i + 1.0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Icon(
                                      i < _rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 36),
                                ),
                              ))),
                  const SizedBox(height: 24),

                  // ── Text area ─────────────────────────────────────────
                  const Text('Please share your opinion\nabout the product',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ctrl,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Your review',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey[200]!)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey[200]!)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Photos ────────────────────────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ..._photos.map((path) => Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 104,
                                  height: 104,
                                  margin:
                                      const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    image: DecorationImage(
                                        image: FileImage(File(path)),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _photos.remove(path)),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 12),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        if (_photos.length < 3)
                          GestureDetector(
                            onTap: _showImageSourceSheet,
                            child: Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE53935),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt,
                                        color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Add your photos',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ),

        // ── Send button ───────────────────────────────────────────────
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating == 0
                    ? null
                    : () {
                        widget.onSubmit({
                          'name': 'You',
                          'date': 'Just now',
                          'rating': _rating,
                          'text': _ctrl.text.isEmpty
                              ? 'No comment.'
                              : _ctrl.text,
                          'helpful': 0,
                          'photos': List<String>.from(_photos),
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Review submitted!'),
                                backgroundColor: Colors.green));
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('SEND REVIEW',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
