// lib/screens/shipping_address_screen.dart
import 'package:flutter/material.dart';

class _Address {
  String name, address, city, state, zip, country;
  bool isDefault;
  _Address({
    required this.name, required this.address, required this.city,
    required this.state, required this.zip, required this.country,
    this.isDefault = false,
  });
}

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});
  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final _addresses = [
    _Address(name: 'Jane Doe', address: '3 Newbridge Court',
        city: 'Chino Hills', state: 'California', zip: '91709',
        country: 'United States', isDefault: true),
    _Address(name: 'John Doe', address: '3 Newbridge Court',
        city: 'Chino Hills', state: 'California', zip: '91709',
        country: 'United States'),
    _Address(name: 'John Doe', address: '51 Riverside',
        city: 'Chino Hills', state: 'California', zip: '91709',
        country: 'United States'),
  ];

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
        title: const Text('Shipping Addresses',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
      ),
      body: Stack(children: [
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          itemCount: _addresses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final a = _addresses[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(a.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => AddShippingAddressScreen(address: a)));
                      if (result != null && result is _Address) {
                        setState(() {
                          _addresses[i] = result;
                        });
                      }
                    },
                    child: const Text('Edit',
                        style: TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(a.address,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                Text('${a.city}, ${a.state} ${a.zip}, ${a.country}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      for (var addr in _addresses) addr.isDefault = false;
                      a.isDefault = true;
                    });
                    // Return selected address to checkout
                    Navigator.pop(context, {
                      'name': a.name,
                      'address': a.address,
                      'city': '${a.city}, ${a.state} ${a.zip}, ${a.country}',
                    });
                  },
                  child: Row(children: [
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: a.isDefault ? Colors.black : Colors.white,
                        border: Border.all(
                            color: a.isDefault ? Colors.black : Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: a.isDefault
                          ? const Icon(Icons.check, color: Colors.white, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text('Use as the shipping address',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  ]),
                ),
              ]),
            );
          },
        ),

        // ── FAB add ──────────────────────────────────────────────────────
        Positioned(
          bottom: 24, right: 16,
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const AddShippingAddressScreen()));
              if (result != null && result is _Address) {
                setState(() => _addresses.add(result));
              }
            },
            child: Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(
                  color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Add / Edit Address Screen ────────────────────────────────────────────────
class AddShippingAddressScreen extends StatefulWidget {
  final _Address? address;
  const AddShippingAddressScreen({super.key, this.address});
  @override
  State<AddShippingAddressScreen> createState() =>
      _AddShippingAddressScreenState();
}

class _AddShippingAddressScreenState extends State<AddShippingAddressScreen> {
  late final _nameCtrl    = TextEditingController(text: widget.address?.name    ?? '');
  late final _addressCtrl = TextEditingController(text: widget.address?.address ?? '');
  late final _cityCtrl    = TextEditingController(text: widget.address?.city    ?? '');
  late final _stateCtrl   = TextEditingController(text: widget.address?.state   ?? '');
  late final _zipCtrl     = TextEditingController(text: widget.address?.zip     ?? '');
  late final _countryCtrl = TextEditingController(text: widget.address?.country ?? 'United States');

  @override
  void dispose() {
    for (final c in [_nameCtrl, _addressCtrl, _cityCtrl, _stateCtrl, _zipCtrl, _countryCtrl]) c.dispose();
    super.dispose();
  }

  void _save() {
    final a = _Address(
      name:    _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city:    _cityCtrl.text.trim(),
      state:   _stateCtrl.text.trim(),
      zip:     _zipCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
    );
    Navigator.pop(context, a);
  }

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
        title: Text(widget.address != null ? 'Edit Address' : 'Adding Shipping Address',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _AddressField(controller: _nameCtrl,    label: 'Full name'),
              _AddressField(controller: _addressCtrl, label: 'Address'),
              _AddressField(controller: _cityCtrl,    label: 'City'),
              _AddressField(controller: _stateCtrl,   label: 'State/Province/Region'),
              _AddressField(controller: _zipCtrl,     label: 'Zip Code (Postal Code)'),
              _AddressField(controller: _countryCtrl, label: 'Country', showArrow: true),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: const Text('SAVE ADDRESS',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold,
                      fontSize: 15, letterSpacing: 1.5)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool showArrow;
  const _AddressField(
      {required this.controller, required this.label, this.showArrow = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        Row(children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
          if (showArrow)
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ]),
        Divider(color: Colors.grey[200], height: 1),
        const SizedBox(height: 12),
      ]),
    );
  }
}