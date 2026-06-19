import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'my_orders_screen.dart';
import 'my_reviews_screen.dart';
import 'settings_screen.dart';
import 'shipping_addresses_screen.dart';
import 'payment_methods_screen.dart';
import 'promocodes_screen.dart';
import 'services/checkout_service.dart';
import 'services/product_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _orderCount = 0;
  int _reviewCount = 0;
  int _addressCount = 0;
  String _paymentSubtitle = 'No default payment';

  @override
  void initState() {
    super.initState();
    _fetchData();
    checkoutService.addListener(_onCheckoutDataUpdated);
  }

  @override
  void dispose() {
    checkoutService.removeListener(_onCheckoutDataUpdated);
    super.dispose();
  }

  void _onCheckoutDataUpdated() {
    if (mounted) {
      setState(() {
        _addressCount = checkoutService.addresses.length;
        if (checkoutService.useCashOnDelivery) {
          _paymentSubtitle = 'Cash on Delivery';
        } else {
          final defaultCard = checkoutService.defaultPaymentCard;
          if (defaultCard != null) {
            String masked = defaultCard.cardNumber.replaceAll(' ', '');
            if (masked.length >= 4) {
              _paymentSubtitle = '${defaultCard.brand} **${masked.substring(masked.length - 4)}';
            } else {
              _paymentSubtitle = defaultCard.brand;
            }
          } else {
            _paymentSubtitle = 'No default payment';
          }
        }
      });
    }
  }

  Future<void> _fetchData() async {
    await checkoutService.fetchCheckoutData();
    final orders = await checkoutService.fetchOrders();
    final reviews = await ProductService().fetchUserReviews();
    
    if (mounted) {
      setState(() {
        _orderCount = orders.length;
        _reviewCount = reviews.length;
      });
      _onCheckoutDataUpdated(); // trigger update for addresses and payment
    }
  }

  void _logout() async {
    await AuthService.signOut();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'My profile',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: AuthService.userPhotoUrl != null 
                        ? NetworkImage(AuthService.userPhotoUrl!) 
                        : null,
                    child: AuthService.userPhotoUrl == null 
                        ? const Icon(Icons.person, size: 32, color: Colors.white) 
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AuthService.userName ?? 'User Name',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AuthService.userEmail ?? 'user@email.com',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildListTile(
                title: 'My orders',
                subtitle: _orderCount > 0 ? 'Already have $_orderCount orders' : 'No orders yet',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
                  );
                },
              ),
              _buildListTile(
                title: 'Shipping addresses',
                subtitle: '$_addressCount addresses',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShippingAddressesScreen()),
                  );
                },
              ),
              _buildListTile(
                title: 'Payment methods',
                subtitle: _paymentSubtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                  );
                },
              ),
              _buildListTile(
                title: 'Promocodes',
                subtitle: 'You have special promocodes',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PromocodesScreen()),
                  );
                },
              ),
              _buildListTile(
                title: 'My reviews',
                subtitle: _reviewCount > 0 ? 'Reviews for $_reviewCount items' : 'No reviews yet',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyReviewsScreen()),
                  );
                },
              ),
              _buildListTile(
                title: 'Settings',
                subtitle: 'Notifications, password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  child: const Text('LOG OUT', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
