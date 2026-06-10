// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import '../services/bag_manager.dart';
import 'shipping_address_screen.dart';
import 'payment_method_screen.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Demo data
  String _name    = 'Jane Doe';
  String _address = '3 Newbridge Court';
  String _city    = 'Chino Hills, CA 91709, United States';
  String _cardLast4 = '3947';
  String _delivery  = 'FedEx';
  final double _deliveryFee = 15.0;

  double get _order   => BagManager.instance.total;
  double get _summary => _order + _deliveryFee;

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
        title: const Text('Checkout',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Shipping address ────────────────────────────────────────
              const Text('Shipping address',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(_name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(_address,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      Text(_city,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ]),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const ShippingAddressScreen()));
                      if (result != null && result is Map) {
                        setState(() {
                          _name    = result['name'] ?? _name;
                          _address = result['address'] ?? _address;
                          _city    = result['city'] ?? _city;
                        });
                      }
                    },
                    child: const Text('Change',
                        style: TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                ]),
              ),
              const SizedBox(height: 20),

              // ── Payment ─────────────────────────────────────────────────
              const Text('Payment',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Container(
                    width: 40, height: 26,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.credit_card,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('**** **** **** $_cardLast4',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const PaymentMethodScreen()));
                      if (result != null && result is String) {
                        setState(() => _cardLast4 = result);
                      }
                    },
                    child: const Text('Change',
                        style: TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                ]),
              ),
              const SizedBox(height: 20),

              // ── Delivery method ─────────────────────────────────────────
              const Text('Delivery method',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Row(children: [
                _DeliveryOption(
                  label: 'FedEx', days: '2-3 days',
                  selected: _delivery == 'FedEx',
                  color: const Color(0xFF4D148C),
                  textColor: const Color(0xFFFF6600),
                  onTap: () => setState(() => _delivery = 'FedEx'),
                ),
                const SizedBox(width: 10),
                _DeliveryOption(
                  label: 'USPS', days: '2-3 days',
                  selected: _delivery == 'USPS',
                  color: const Color(0xFF004B87),
                  textColor: Colors.white,
                  onTap: () => setState(() => _delivery = 'USPS'),
                ),
                const SizedBox(width: 10),
                _DeliveryOption(
                  label: 'DHL', days: '2-3 days',
                  selected: _delivery == 'DHL',
                  color: const Color(0xFFFFCC00),
                  textColor: Colors.black,
                  onTap: () => setState(() => _delivery = 'DHL'),
                ),
              ]),
              const SizedBox(height: 24),

              // ── Summary ─────────────────────────────────────────────────
              _SummaryRow(label: 'Order:', value: '${_order.toStringAsFixed(0)}\$'),
              const SizedBox(height: 6),
              _SummaryRow(label: 'Delivery:', value: '${_deliveryFee.toStringAsFixed(0)}\$'),
              const Divider(height: 24),
              _SummaryRow(
                label: 'Summary:', value: '${_summary.toStringAsFixed(0)}\$',
                bold: true,
              ),
            ],
          ),
        ),

        // ── Submit button ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                BagManager.instance.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
                  (r) => r.isFirst,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: const Text('SUBMIT ORDER',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1.5)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _DeliveryOption extends StatelessWidget {
  final String label, days;
  final bool selected;
  final Color color, textColor;
  final VoidCallback onTap;

  const _DeliveryOption({
    required this.label, required this.days, required this.selected,
    required this.color, required this.textColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                color: selected ? Colors.black : Colors.grey[200]!, width: selected ? 2 : 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(4)),
              child: Text(label,
                  style: TextStyle(
                      color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(height: 4),
            Text(days,
                style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ]),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _SummaryRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: bold ? Colors.black : Colors.grey[700],
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}