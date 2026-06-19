import 'package:flutter/material.dart';
import 'product_list_screen.dart';

class SubCategoryScreen extends StatelessWidget {
  final String categoryName;
  final String department;

  const SubCategoryScreen({super.key, required this.categoryName, this.department = 'Women'});

  @override
  Widget build(BuildContext context) {
    List<String> subCategories = [];
    if (categoryName.toLowerCase() == 'shoes') {
      subCategories = [
        'Sneakers',
        'Boots',
        'Heels',
        'Flats',
        'Sandals',
        'Slippers',
        'Loafers',
        'Oxfords',
      ];
    } else if (categoryName.toLowerCase() == 'accesories') {
      subCategories = [
        'Bags',
        'Watches',
        'Jewelry',
        'Sunglasses',
        'Hats',
        'Belts',
      ];
    } else {
      subCategories = [
        'Tops',
        'Shirts & Blouses',
        'Cardigans & Sweaters',
        'Knitwear',
        'Blazers',
        'Outerwear',
        'Pants',
        'Jeans',
        'Shorts',
        'Skirts',
        'Dresses',
      ];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
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
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // VIEW ALL ITEMS button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFDB3022),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDB3022).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'VIEW ALL ITEMS',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          
          // Choose category text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Choose category',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          
          // Sub-categories list
          Expanded(
            child: ListView.separated(
              itemCount: subCategories.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListScreen(categoryName: subCategories[index], department: department),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    width: double.infinity,
                    color: Colors.white,
                    child: Text(
                      subCategories[index],
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
