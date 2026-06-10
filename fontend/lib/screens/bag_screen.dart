// lib/screens/bag_screen.dart
import 'package:flutter/material.dart';
import '../services/bag_manager.dart';
import '../services/product_service.dart';
import 'checkout_screen.dart';

class BagScreen extends StatefulWidget {
  const BagScreen({super.key});
  @override
  State<BagScreen> createState() => _BagScreenState();
}

class _BagScreenState extends State<BagScreen> {
  final _promoController = TextEditingController();
  bool _showPromoSheet = false;

  static const _availablePromos = [
    {'code': 'mypromocode2020', 'discount': 10, 'label': 'Personal offer',    'days': 6,  'image': ''},
    {'code': 'summer2020',      'discount': 15, 'label': 'Summer Sale',       'days': 23, 'image': 'https://images.pexels.com/photos/1537086/pexels-photo-1537086.jpeg?auto=compress&w=200'},
    {'code': 'SAVE22',          'discount': 22, 'label': 'Personal offer',    'days': 6,  'image': ''},
  ];

  @override
  void initState() {
    super.initState();
    if (BagManager.instance.appliedPromo != null) {
      _promoController.text = BagManager.instance.appliedPromo!;
    }
    ProductService.instance.isLoading.addListener(_onServiceChanged);
    ProductService.instance.connectionFailed.addListener(_onServiceChanged);
  }

  void _onServiceChanged() => setState(() {});

  Future<void> _onRefresh() => ProductService.instance.refresh();

  @override
  void dispose() {
    _promoController.dispose();
    ProductService.instance.isLoading.removeListener(_onServiceChanged);
    ProductService.instance.connectionFailed.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _tryApplyPromo(String code) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return;
    final ok = BagManager.instance.applyPromo(trimmed);
    setState(() => _showPromoSheet = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Promo applied!' : 'Invalid promo code'),
      backgroundColor: ok ? Colors.green : Colors.red,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bag = BagManager.instance;

    final isLoading = ProductService.instance.isLoading.value;
    final failed = ProductService.instance.connectionFailed.value;

    // Show spinner while backend connecting (no items yet)
    if (isLoading && !failed) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          color: const Color(0xFFE53935),
          strokeWidth: 2.5,
          onRefresh: _onRefresh,
          child: const CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFE53935)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show error when backend is unreachable
    if (failed) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          color: const Color(0xFFE53935),
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
                        backgroundColor: const Color(0xFFE53935),
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
        ),
      );
    }

    // ValueListenableBuilder đảm bảo UI luôn cập nhật khi items thay đổi
    return ValueListenableBuilder<List<BagItem>>(
      valueListenable: bag.items,
      builder: (context, items, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(children: [
            SafeArea(
              child: Column(children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(children: [
                    const Expanded(
                      child: Text('My Bag',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                        icon: const Icon(Icons.search, color: Colors.black),
                        onPressed: () {}),
                  ]),
                ),

                // ── Items list ───────────────────────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFFE53935),
                    strokeWidth: 2.5,
                    onRefresh: _onRefresh,
                    child: items.isEmpty
                      ? const CustomScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text('Your bag is empty',
                                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                                    SizedBox(height: 8),
                                    Text('Start shopping to fill it up!',
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          itemCount: items.length,
                          itemBuilder: (_, i) => _BagItemTile(
                            item: items[i],
                            index: i,
                            onRemove: () => bag.remove(i),
                            onQtyChange: (q) => bag.updateQty(i, q),
                            onMoveToFav: () {
                              bag.remove(i);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Moved to favorites'),
                                    duration: Duration(seconds: 2)),
                              );
                            },
                          ),
                        ),
                  ),
                ),

                // ── Promo code bar ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: bag.appliedPromo != null
                      ? _AppliedPromoBar(
                          code: bag.appliedPromo!,
                          onRemove: () {
                            bag.removePromo();
                            _promoController.clear();
                            setState(() {});
                          },
                        )
                      : _PromoInputBar(
                          controller: _promoController,
                          onTap: () => setState(() => _showPromoSheet = true),
                          onSubmit: _tryApplyPromo,
                        ),
                ),

                // ── Total + Checkout ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total amount:',
                            style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                        Text('${bag.total.toStringAsFixed(0)}\$',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: items.isEmpty
                            ? null
                            : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => CheckoutScreen())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          disabledBackgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                          elevation: 0,
                        ),
                        child: const Text('CHECK OUT',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1.5)),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 4),
              ]),
            ),

            // ── Promo sheet overlay ──────────────────────────────────────
            if (_showPromoSheet) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showPromoSheet = false),
                  child: Container(color: Colors.black45),
                ),
              ),
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: _PromoSheet(
                  controller: _promoController,
                  promos: _availablePromos,
                  onApply: _tryApplyPromo,
                  onManualSubmit: _tryApplyPromo,
                ),
              ),
            ],
          ]),
        );
      },
    );
  }
}

// ─── Bag Item Tile ────────────────────────────────────────────────────────────
class _BagItemTile extends StatelessWidget {
  final BagItem item;
  final int index;
  final VoidCallback onRemove;
  final ValueChanged<int> onQtyChange;
  final VoidCallback onMoveToFav;

  const _BagItemTile({
    required this.item,
    required this.index,
    required this.onRemove,
    required this.onQtyChange,
    required this.onMoveToFav,
  });

  void _showMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final offset = button.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          offset.dx - 160, offset.dy + 28, offset.dx + 12, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      items: [
        PopupMenuItem(onTap: onMoveToFav, child: const Text('Add to favorites')),
        PopupMenuItem(onTap: onRemove, child: const Text('Delete from the list')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            p['image'] ?? '',
            width: 90, height: 110, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 90, height: 110,
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(p['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                Builder(builder: (ctx) => GestureDetector(
                  onTap: () => _showMenu(ctx),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.more_vert, color: Colors.grey[500], size: 20),
                  ),
                )),
              ]),
              const SizedBox(height: 2),
              Text(
                [
                  if (item.selectedColor != null) 'Color: ${item.selectedColor}',
                  if (item.selectedSize != null) 'Size: ${item.selectedSize}',
                ].join('  '),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 10),
              Row(children: [
                GestureDetector(
                  onTap: () => onQtyChange(item.quantity - 1),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Icon(Icons.remove, size: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
                GestureDetector(
                  onTap: () => onQtyChange(item.quantity + 1),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Icon(Icons.add, size: 14),
                  ),
                ),
                const Spacer(),
                Text('${p['price']}\$',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ]),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── Promo Input Bar ──────────────────────────────────────────────────────────
class _PromoInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTap;
  final ValueChanged<String> onSubmit;
  const _PromoInputBar({required this.controller, required this.onTap, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: controller.text.isEmpty
                  ? Text('Enter your promo code',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14))
                  : Text(controller.text, style: const TextStyle(fontSize: 14)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () => onSubmit(controller.text),
            child: Container(
              width: 38, height: 38,
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Applied Promo Bar ────────────────────────────────────────────────────────
class _AppliedPromoBar extends StatelessWidget {
  final String code;
  final VoidCallback onRemove;
  const _AppliedPromoBar({required this.code, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(children: [
        const SizedBox(width: 16),
        Expanded(
          child: Text(code,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!), shape: BoxShape.circle),
              child: Icon(Icons.close, color: Colors.grey[600], size: 18),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Promo Sheet ──────────────────────────────────────────────────────────────
class _PromoSheet extends StatelessWidget {
  final TextEditingController controller;
  final List<Map<String, dynamic>> promos;
  final ValueChanged<String> onApply;
  final ValueChanged<String> onManualSubmit;

  const _PromoSheet({
    required this.controller,
    required this.promos,
    required this.onApply,
    required this.onManualSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter your promo code',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: onManualSubmit,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => onManualSubmit(controller.text),
                  child: Container(
                    width: 38, height: 38,
                    decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Your Promo Codes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: promos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final promo = promos[i];
                final discount = promo['discount'] as int;
                final days = promo['days'] as int;
                return Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12)),
                      child: (promo['image'] as String).isNotEmpty
                          ? Image.network(promo['image'] as String,
                              width: 72, height: 72, fit: BoxFit.cover)
                          : Container(
                              width: 72, height: 72,
                              color: const Color(0xFFE53935),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('$discount%',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                  const Text('off',
                                      style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$days days remaining',
                              style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                          Text(promo['label'] as String,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(promo['code'] as String,
                              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ElevatedButton(
                        onPressed: () => onApply(promo['code'] as String),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Apply',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ),
                  ]),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}