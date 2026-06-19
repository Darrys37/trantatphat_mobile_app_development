import 'package:flutter/material.dart';
import 'package:trantatphat/services/checkout_service.dart';
import 'package:trantatphat/widgets/add_payment_card_bottom_sheet.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String? _selectedCardId;

  @override
  void initState() {
    super.initState();
    checkoutService.addListener(_onUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (checkoutService.useCashOnDelivery) {
        if (mounted) setState(() => _selectedCardId = 'COD');
      } else {
        final defaultCard = checkoutService.defaultPaymentCard;
        if (defaultCard != null && mounted) {
          setState(() {
            _selectedCardId = defaultCard.id;
          });
        }
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

  Future<void> _refreshPayments() async {
    await checkoutService.fetchCheckoutData();
  }

  @override
  Widget build(BuildContext context) {
    final cards = checkoutService.paymentCards;

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
          'Payment methods',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshPayments,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0).copyWith(bottom: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your payment cards', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Cash on Delivery Option
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _selectedCardId == 'COD' ? Colors.red : Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.money, color: Colors.green, size: 30),
                            const SizedBox(width: 16),
                            const Text('Cash on Delivery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Checkbox(
                          value: _selectedCardId == 'COD',
                          onChanged: (val) {
                            if (val == true) {
                              setState(() => _selectedCardId = 'COD');
                            }
                          },
                          activeColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  if (cards.isEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: const Center(
                        child: Text(
                          "You don't have any payment cards yet",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    )
                  else
                    ...cards.map((card) {
                      return Column(
                        children: [
                          _buildCreditCard(card),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _selectedCardId == card.id,
                                    onChanged: (val) {
                                      if (val == true) {
                                        setState(() => _selectedCardId = card.id);
                                      }
                                    },
                                    activeColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                  const Text('Use as payment method'),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  checkoutService.deletePaymentCard(card.id);
                                },
                                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }).toList(),
                ],
              ),
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
                    if (_selectedCardId == 'COD') {
                      checkoutService.setCashOnDelivery(true);
                      if (mounted) Navigator.pop(context);
                    } else if (_selectedCardId != null) {
                      checkoutService.setCashOnDelivery(false);
                      await checkoutService.setDefaultPaymentCard(_selectedCardId!);
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
            bottom: 85,
            right: 24,
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: const AddPaymentCardBottomSheet(),
                  ),
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

  Widget _buildCreditCard(card) {
    bool isMastercard = card.brand == 'Mastercard';
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isMastercard ? const Color(0xFF222222) : const Color(0xFF9E9E9E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.amber.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              if (!isMastercard)
                const Text('VISA', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            ],
          ),
          Text(
            card.cardNumber.replaceAll(' ', '').length >= 4 
                ? '**** **** **** ${card.cardNumber.replaceAll(' ', '').substring(card.cardNumber.replaceAll(' ', '').length - 4)}'
                : card.cardNumber,
            style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Card Holder Name', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text(card.cardHolderName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Expiry Date', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text(card.expiryDate, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              if (isMastercard)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 25, height: 25, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    Transform.translate(offset: const Offset(-10, 0), child: Container(width: 25, height: 25, decoration: BoxDecoration(color: Colors.orange.withOpacity(0.8), shape: BoxShape.circle))),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
