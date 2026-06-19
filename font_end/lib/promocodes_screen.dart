import 'package:flutter/material.dart';
import 'package:font_end/services/cart_service.dart';
import 'package:font_end/models/coupon.dart';
import 'package:flutter/services.dart';

class PromocodesScreen extends StatefulWidget {
  const PromocodesScreen({super.key});

  @override
  State<PromocodesScreen> createState() => _PromocodesScreenState();
}

class _PromocodesScreenState extends State<PromocodesScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    await cartService.fetchAvailableCoupons();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$code" to clipboard'),
        duration: const Duration(seconds: 2),
      ),
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
        title: const Text(
          "Promocodes",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDB3022)))
          : cartService.availableCoupons.isEmpty
              ? const Center(
                  child: Text(
                    "You don't have any promocodes right now.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartService.availableCoupons.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final coupon = cartService.availableCoupons[index];
                    return _buildCouponCard(coupon);
                  },
                ),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    return Container(
      height: 100,
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
      child: Row(
        children: [
          // Left Banner
          Container(
            width: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFDB3022), // Red brand color
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                coupon.discountType == 'PERCENTAGE'
                    ? '${coupon.discountValue.toInt()}%'
                    : '${coupon.discountValue.toInt()}\$',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    coupon.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coupon.code,
                    style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          // Right Side Column (Days & Copy Button)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${coupon.remainingDays} days remaining',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                ElevatedButton(
                  onPressed: () => _copyToClipboard(coupon.code),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB3022),
                    minimumSize: const Size(60, 30),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Copy', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
