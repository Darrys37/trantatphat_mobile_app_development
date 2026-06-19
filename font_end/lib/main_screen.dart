import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'shop_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'bag_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // Pop to first route if tapping the current tab
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<bool> _onWillPop() async {
    final isFirstRouteInCurrentTab = !await _navigatorKeys[_selectedIndex].currentState!.maybePop();
    if (isFirstRouteInCurrentTab) {
      if (_selectedIndex != 0) {
        _onItemTapped(0);
        return false;
      }
    }
    return isFirstRouteInCurrentTab;
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) {
              if (index == 0) return const HomeScreen();
              if (index == 1) return ShopScreen(onBackToHome: () => _onItemTapped(0));
              if (index == 2) return const BagScreen();
              if (index == 3) return const FavoritesScreen();
              if (index == 4) return const ProfileScreen();
              return const SizedBox();
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
            _buildOffstageNavigator(3),
            _buildOffstageNavigator(4),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFDB3022),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Shop'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Bag'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
