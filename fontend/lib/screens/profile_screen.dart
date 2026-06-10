import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Center(child: CircleAvatar(
          radius: 48, backgroundColor: Color(0xFFE53935),
          child: Icon(Icons.person, size: 48, color: Colors.white),
        )),
        const SizedBox(height: 16),
        const Center(child: Text('Hello, User!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 32),
        _ProfileMenuItem(icon: Icons.shopping_bag_outlined, title: 'My Orders', onTap: () {}),
        _ProfileMenuItem(icon: Icons.location_on_outlined, title: 'Shipping Addresses', onTap: () {}),
        _ProfileMenuItem(icon: Icons.payment_outlined, title: 'Payment Methods', onTap: () {}),
        _ProfileMenuItem(icon: Icons.reviews_outlined, title: 'My Reviews', onTap: () {}),
        _ProfileMenuItem(icon: Icons.settings_outlined, title: 'Settings', onTap: () {}),
        const Divider(),
        _ProfileMenuItem(icon: Icons.logout, title: 'Logout', onTap: () => _logout(context), color: const Color(0xFFE53935)),
      ]),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback onTap; final Color? color;
  const _ProfileMenuItem({required this.icon, required this.title, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.black;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(title, style: TextStyle(color: c, fontWeight: FontWeight.w500)),
      trailing: color == null ? const Icon(Icons.chevron_right, color: Colors.grey) : null,
      onTap: onTap,
    );
  }
}
