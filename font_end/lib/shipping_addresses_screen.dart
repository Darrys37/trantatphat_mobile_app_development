import 'package:flutter/material.dart';
import 'package:font_end/services/checkout_service.dart';
import 'package:font_end/shipping_address_form_screen.dart';

class ShippingAddressesScreen extends StatefulWidget {
  const ShippingAddressesScreen({super.key});

  @override
  State<ShippingAddressesScreen> createState() => _ShippingAddressesScreenState();
}

class _ShippingAddressesScreenState extends State<ShippingAddressesScreen> {
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    checkoutService.addListener(_onUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final defaultAddr = checkoutService.defaultAddress;
      if (defaultAddr != null && mounted) {
        setState(() {
          _selectedAddressId = defaultAddr.id;
        });
      }
    });
  }

  @override
  void dispose() {
    checkoutService.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshAddresses() async {
    await checkoutService.fetchCheckoutData();
  }

  @override
  Widget build(BuildContext context) {
    final addresses = checkoutService.addresses;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shipping Addresses',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshAddresses,
            child: addresses.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                      const Center(
                        child: Text(
                          "You don't have any shipping addresses yet",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0).copyWith(bottom: 100),
                    itemCount: addresses.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(address.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ShippingAddressFormScreen(addressToEdit: address)),
                                        );
                                      },
                                      child: const Text('Edit', style: TextStyle(color: Colors.red)),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        checkoutService.deleteAddress(address.id);
                                      },
                                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              '${address.address}\n${address.city}, ${address.state} ${address.zipCode}, ${address.country}',
                              style: const TextStyle(color: Colors.grey, height: 1.5),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Checkbox(
                                  value: _selectedAddressId == address.id,
                                  onChanged: (val) {
                                    if (val == true) {
                                      setState(() => _selectedAddressId = address.id);
                                    }
                                  },
                                  activeColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                                const Text('Use as the shipping address'),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16).copyWith(bottom: 24),
              color: const Color(0xFFF9F9F9),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_selectedAddressId != null) {
                      await checkoutService.setDefaultAddress(_selectedAddressId!);
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('SAVE', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            right: 24,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShippingAddressFormScreen()),
                );
              },
              backgroundColor: Colors.black,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
