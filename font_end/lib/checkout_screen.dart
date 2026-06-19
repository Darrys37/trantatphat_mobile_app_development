import 'package:flutter/material.dart';
import 'package:font_end/services/cart_service.dart';
import 'package:font_end/services/checkout_service.dart';
import 'package:font_end/models/delivery_method.dart';
import 'package:font_end/payment_methods_screen.dart';
import 'package:font_end/shipping_addresses_screen.dart';
import 'package:font_end/success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  DeliveryMethod? selectedDelivery;

  @override
  void initState() {
    super.initState();
    checkoutService.fetchCheckoutData().then((_) {
      if (mounted && checkoutService.deliveryMethods.isNotEmpty) {
        setState(() {
          selectedDelivery = checkoutService.deliveryMethods.first;
        });
      }
    });
    checkoutService.addListener(_onCheckoutUpdate);
    cartService.addListener(_onCartUpdate);
  }

  @override
  void dispose() {
    checkoutService.removeListener(_onCheckoutUpdate);
    cartService.removeListener(_onCartUpdate);
    super.dispose();
  }

  void _onCheckoutUpdate() {
    if (mounted) setState(() {});
  }

  void _onCartUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final address = checkoutService.defaultAddress;
    final payment = checkoutService.defaultPaymentCard;
    final orderTotal = cartService.totalAmount;
    final deliveryFee = selectedDelivery?.price ?? 0.0;
    final summaryTotal = orderTotal + deliveryFee;

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
          'Checkout',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shipping address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: address == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(address.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ShippingAddressesScreen()));
                              },
                              child: const Text('Change', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                        Text(
                          '${address.address}\n${address.city}, ${address.state} ${address.zipCode}, ${address.country}',
                          style: const TextStyle(color: Colors.grey, height: 1.5),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()));
                  },
                  child: const Text('Change', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 64,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: checkoutService.useCashOnDelivery
                        ? const Icon(Icons.money, color: Colors.green)
                        : payment?.brand == 'Mastercard'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 15, height: 15, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                                  Transform.translate(offset: const Offset(-5, 0), child: Container(width: 15, height: 15, decoration: BoxDecoration(color: Colors.orange.withOpacity(0.8), shape: BoxShape.circle))),
                                ],
                              )
                            : const Text('VISA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontStyle: FontStyle.italic)),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  checkoutService.useCashOnDelivery 
                      ? 'Cash on Delivery' 
                      : (payment != null && payment.cardNumber.replaceAll(' ', '').length >= 4 
                          ? '**** **** **** ${payment.cardNumber.replaceAll(' ', '').substring(payment.cardNumber.replaceAll(' ', '').length - 4)}' 
                          : '**** **** **** ****'),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Delivery method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: checkoutService.deliveryMethods.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final method = checkoutService.deliveryMethods[index];
                  final isSelected = selectedDelivery?.id == method.id;
                  return GestureDetector(
                    onTap: () => setState(() => selectedDelivery = method),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected ? Border.all(color: Colors.red, width: 2) : Border.all(color: Colors.transparent),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Fake logo by name
                          Text(
                            method.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: method.name == 'FedEx' ? Colors.deepPurple : (method.name == 'DHL' ? Colors.red : Colors.blue[900]),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(method.duration, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 48),
            _buildSummaryRow('Order:', '\$${orderTotal.toStringAsFixed(0)}'),
            const SizedBox(height: 12),
            _buildSummaryRow('Delivery:', '\$${deliveryFee.toStringAsFixed(0)}'),
            const SizedBox(height: 12),
            _buildSummaryRow('Summary:', '\$${summaryTotal.toStringAsFixed(0)}', isBold: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (checkoutService.defaultAddress == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a shipping address')));
                    return;
                  }
                  if (!checkoutService.useCashOnDelivery && checkoutService.defaultPaymentCard == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a payment method')));
                    return;
                  }
                  if (selectedDelivery == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a delivery method')));
                    return;
                  }

                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Confirm Order'),
                      content: const Text('Are you sure you want to place this order?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext); // Close dialog
                            bool success = await checkoutService.submitOrder(
                              selectedDelivery!.id,
                              cartService.totalAmount + selectedDelivery!.price,
                            );
                            if (success) {
                              await cartService.fetchCart(); // refresh cart (it should be empty now)
                              await cartService.fetchAppliedCoupon(); // clear coupon UI
                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SuccessScreen()),
                                );
                              }
                            } else {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order failed, please try again.')));
                            }
                          },
                          child: const Text('OK', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('SUBMIT ORDER', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
