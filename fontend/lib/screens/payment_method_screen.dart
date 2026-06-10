// lib/screens/payment_method_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _PayCard {
  final String last4, holder, expiry, network;
  bool isDefault;
  _PayCard({
    required this.last4, required this.holder,
    required this.expiry, required this.network,
    this.isDefault = false,
  });
}

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});
  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final _cards = [
    _PayCard(last4: '3947', holder: 'Jennyfer Doe', expiry: '05/23',
        network: 'mastercard', isDefault: true),
    _PayCard(last4: '4546', holder: 'Jennyfer Doe', expiry: '11/22',
        network: 'visa'),
  ];
  bool _showAddSheet = false;

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
        title: const Text('Payment methods',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
      ),
      body: Stack(children: [
        Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              children: [
                const Text('Your payment cards',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 14),
                ..._cards.asMap().entries.map((e) {
                  final i = e.key;
                  final c = e.value;
                  return Column(children: [
                    _CreditCard(card: c),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          for (var card in _cards) card.isDefault = false;
                          c.isDefault = true;
                        });
                        Navigator.pop(context, c.last4);
                      },
                      child: Row(children: [
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: c.isDefault ? Colors.black : Colors.white,
                            border: Border.all(
                                color: c.isDefault ? Colors.black : Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: c.isDefault
                              ? const Icon(Icons.check, color: Colors.white, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text('Use as default payment method',
                            style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      ]),
                    ),
                    if (i < _cards.length - 1) const SizedBox(height: 20),
                  ]);
                }),
              ],
            ),
          ),
        ]),

        // ── FAB ──────────────────────────────────────────────────────────
        Positioned(
          bottom: 24, right: 16,
          child: GestureDetector(
            onTap: () => setState(() => _showAddSheet = true),
            child: Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(
                  color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ),

        // ── Add card sheet overlay ────────────────────────────────────────
        if (_showAddSheet) ...[
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showAddSheet = false),
              child: Container(color: Colors.black45),
            ),
          ),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _AddCardSheet(
              onAdd: (card) {
                setState(() {
                  _cards.add(card);
                  _showAddSheet = false;
                });
              },
              onClose: () => setState(() => _showAddSheet = false),
            ),
          ),
        ],
      ]),
    );
  }
}

// ─── Credit Card Widget ───────────────────────────────────────────────────────
class _CreditCard extends StatelessWidget {
  final _PayCard card;
  const _CreditCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final isMaster = card.network == 'mastercard';
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: card.isDefault ? Colors.black87 : Colors.grey[400],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Chip
        Container(
          width: 36, height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC00),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 16),
        // Number
        Row(children: [
          Text('* * * *  * * * *  * * * *  ${card.last4}',
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, letterSpacing: 2,
                  fontWeight: FontWeight.w500)),
        ]),
        const Spacer(),
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Card Holder Name',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
            Text(card.holder,
                style: const TextStyle(color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Expiry Date',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
            Text(card.expiry,
                style: const TextStyle(color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(width: 12),
          // Network logo
          isMaster
              ? Stack(children: [
                  Container(
                      width: 22, height: 22,
                      decoration: const BoxDecoration(
                          color: Color(0xFFEB001B), shape: BoxShape.circle)),
                  Positioned(
                    left: 12,
                    child: Container(
                        width: 22, height: 22,
                        decoration: const BoxDecoration(
                            color: Color(0xFFF79E1B), shape: BoxShape.circle)),
                  ),
                ])
              : const Text('VISA',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold,
                      fontSize: 18, fontStyle: FontStyle.italic)),
        ]),
      ]),
    );
  }
}

// ─── Add Card Sheet ───────────────────────────────────────────────────────────
class _AddCardSheet extends StatefulWidget {
  final ValueChanged<_PayCard> onAdd;
  final VoidCallback onClose;
  const _AddCardSheet({required this.onAdd, required this.onClose});
  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _nameCtrl   = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl    = TextEditingController();
  bool _setDefault  = false;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _numberCtrl, _expiryCtrl, _cvvCtrl]) c.dispose();
    super.dispose();
  }

  void _add() {
    final number = _numberCtrl.text.replaceAll(' ', '');
    final last4  = number.length >= 4 ? number.substring(number.length - 4) : '0000';
    final card   = _PayCard(
      last4: last4,
      holder: _nameCtrl.text.trim().isEmpty ? 'Card Holder' : _nameCtrl.text.trim(),
      expiry: _expiryCtrl.text.trim().isEmpty ? '00/00' : _expiryCtrl.text.trim(),
      network: 'mastercard',
      isDefault: _setDefault,
    );
    widget.onAdd(card);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 14),
        const Text('Add new card',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        _CardField(controller: _nameCtrl,   label: 'Name on card'),
        const SizedBox(height: 12),
        _CardField(
          controller: _numberCtrl,
          label: 'Card number',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CardNumberFormatter(),
          ],
          suffix: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 16, height: 10,
                decoration: const BoxDecoration(color: Color(0xFFEB001B), shape: BoxShape.circle)),
            Transform.translate(offset: const Offset(-6, 0),
              child: Container(width: 16, height: 10,
                  decoration: const BoxDecoration(color: Color(0xFFF79E1B), shape: BoxShape.circle))),
          ]),
        ),
        const SizedBox(height: 12),
        _CardField(controller: _expiryCtrl, label: 'Expire Date',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _ExpiryFormatter(),
            ]),
        const SizedBox(height: 12),
        _CardField(
          controller: _cvvCtrl, label: 'CVV',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3)],
          suffix: const Icon(Icons.help_outline, color: Colors.grey, size: 18),
        ),
        const SizedBox(height: 14),

        GestureDetector(
          onTap: () => setState(() => _setDefault = !_setDefault),
          child: Row(children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: _setDefault ? Colors.black : Colors.white,
                border: Border.all(
                    color: _setDefault ? Colors.black : Colors.grey[400]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _setDefault
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 8),
            Text('Set as default payment method',
                style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _add,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              elevation: 0,
            ),
            child: const Text('ADD CARD',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold,
                    fontSize: 15, letterSpacing: 1.5)),
          ),
        ),
      ]),
    );
  }
}

class _CardField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;

  const _CardField({
    required this.controller, required this.label,
    this.keyboardType, this.inputFormatters, this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          suffixIcon: suffix != null ? Padding(
            padding: const EdgeInsets.only(right: 12),
            child: suffix,
          ) : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    if (digits.length > 16) return oldValue;
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
        text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    if (digits.length > 4) return oldValue;
    String text = digits;
    if (digits.length > 2) text = '${digits.substring(0, 2)}/${digits.substring(2)}';
    return TextEditingValue(
        text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}