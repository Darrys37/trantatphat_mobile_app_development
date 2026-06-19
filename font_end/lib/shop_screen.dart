import 'package:flutter/material.dart';
import 'sub_category_screen.dart';

class ShopScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;
  const ShopScreen({super.key, this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Categories',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
            onPressed: () {
              if (onBackToHome != null) {
                onBackToHome!();
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            )
          ],
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFDB3022),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            tabs: [
              Tab(text: 'Women'),
              Tab(text: 'Men'),
              Tab(text: 'Kids'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CategoryTabContent(department: 'Women'), // Women
            CategoryTabContent(department: 'Men'), // Men
            CategoryTabContent(department: 'Kids'), // Kids
          ],
        ),
      ),
    );
  }
}

class CategoryTabContent extends StatelessWidget {
  final String department;
  const CategoryTabContent({super.key, this.department = 'Women'});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Summer Sales Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFDB3022),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SUMMER SALES',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Up to 50% off',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Categories list
        _buildCategoryCard(context, 'New', 'assets/images/categories_new.png'),
        _buildCategoryCard(context, 'Clothes', 'assets/images/categories_clothes.png'),
        _buildCategoryCard(context, 'Shoes', 'assets/images/categories_shoes.png'),
        _buildCategoryCard(context, 'Accesories', 'assets/images/categories_accesories.png'),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubCategoryScreen(categoryName: title, department: department),
          ),
        );
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Text half
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Image half
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                ),
              ),
            ),
          )
        ],
      ),
    ));
  }
}
