import 'package:flutter/material.dart';
import 'package:font_end/services/cart_service.dart';
import 'package:font_end/widgets/promo_code_bottom_sheet.dart';
import 'package:font_end/checkout_screen.dart';

class BagScreen extends StatefulWidget {
  const BagScreen({super.key});

  @override
  State<BagScreen> createState() => _BagScreenState();
}

class _BagScreenState extends State<BagScreen> {

  @override
  void initState() {
    super.initState();
    cartService.addListener(_onCartChanged);
    cartService.fetchCart();
    cartService.fetchAppliedCoupon();
  }

  @override
  void dispose() {
    cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  Future<void> _refreshBag() async {
    await Future.wait([
      cartService.fetchCart(),
      cartService.fetchAppliedCoupon(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'My Bag',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshBag,
                child: cartService.items.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                          const Center(
                            child: Text(
                              "Your bag is empty",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: cartService.items.length,
                        itemBuilder: (context, index) {
                        final item = cartService.items[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                                child: item.productImageUrl.isNotEmpty
                                    ? (item.productImageUrl.startsWith('assets/')
                                        ? Image.asset(
                                            item.productImageUrl,
                                            width: 140,
                                            height: 140,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 140,
                                              height: 140,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.image, color: Colors.grey),
                                            ),
                                          )
                                        : Image.network(
                                            item.productImageUrl,
                                            width: 140,
                                            height: 140,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 140,
                                              height: 140,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.image, color: Colors.grey),
                                            ),
                                          ))
                                    : Container(
                                        width: 140,
                                        height: 140,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image, color: Colors.grey),
                                      ),
                              ),
                              // Details
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.productName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                                            padding: EdgeInsets.zero,
                                            onSelected: (value) {
                                              if (value == 'delete') {
                                                cartService.removeFromCart(item.id);
                                              } else if (value == 'favorite') {
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to favorites')));
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'favorite',
                                                child: Text('Add to favorites', style: TextStyle(fontSize: 14)),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete from the list', style: TextStyle(fontSize: 14)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text('Color: ', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                          Text('${item.color}   ', style: const TextStyle(fontSize: 11, color: Colors.black)),
                                          Text('Size: ', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                          Text(item.size, style: const TextStyle(fontSize: 11, color: Colors.black)),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              _buildQuantityButton(
                                                icon: Icons.remove,
                                                onTap: () {
                                                  if (item.quantity > 1) {
                                                    cartService.updateQuantity(item.id, item.quantity - 1);
                                                  }
                                                },
                                              ),
                                              const SizedBox(width: 12),
                                              Text('${item.quantity}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                              const SizedBox(width: 12),
                                              _buildQuantityButton(
                                                icon: Icons.add,
                                                onTap: () {
                                                  cartService.updateQuantity(item.id, item.quantity + 1);
                                                },
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${item.price.toInt()}\$',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ),
            // Bottom Section (Promo code, Total, Checkout button)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
              ),
              child: Column(
                children: [
                  // Promo Code Input
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: TextEditingController(text: cartService.appliedCoupon?.code ?? ''),
                      readOnly: true,
                      onTap: () {
                        if (cartService.appliedCoupon == null) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: const PromoCodeBottomSheet(),
                            ),
                          );
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your promo code',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(left: 20, top: 14),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InkWell(
                            onTap: () {
                              if (cartService.appliedCoupon != null) {
                                cartService.removeCoupon();
                              } else {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).viewInsets.bottom,
                                    ),
                                    child: const PromoCodeBottomSheet(),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: cartService.appliedCoupon != null ? Colors.red : Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                cartService.appliedCoupon != null ? Icons.close : Icons.arrow_forward,
                                color: Colors.white, 
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Total Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total amount:',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        '${cartService.totalAmount.toInt()}\$',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (cartService.items.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Your bag is empty. Please add some items.')),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDB3022),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFFDB3022).withOpacity(0.5),
                      ),
                      child: const Text(
                        'CHECK OUT',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
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
        child: Icon(icon, size: 20, color: Colors.grey),
      ),
    );
  }
}
