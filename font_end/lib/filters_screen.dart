import 'package:flutter/material.dart';
import 'brand_screen.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  RangeValues _currentRangeValues = const RangeValues(78, 143);
  
  final List<Color> _colors = [
    Colors.black,
    const Color(0xFFF6F6F6),
    const Color(0xFFB82222),
    const Color(0xFFBEA9A9),
    const Color(0xFFE2BE8F),
    const Color(0xFF151867),
  ];
  final Set<int> _selectedColors = {0, 4}; // Black and Tan selected as in screenshot

  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL'];
  final Set<String> _selectedSizes = {'S', 'M'};

  final List<String> _categories = ['All', 'Women', 'Men', 'Boys', 'Girls'];
  String _selectedCategory = 'All';

  List<String> _selectedBrands = ['adidas Originals', 'Jack & Jones', 's.Oliver'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.2),
        centerTitle: true,
        title: const Text(
          'Filters',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Price range'),
                _buildPriceRange(),
                _buildSectionTitle('Colors'),
                _buildColors(),
                _buildSectionTitle('Sizes'),
                _buildSizes(),
                _buildSectionTitle('Category'),
                _buildCategories(),
                _buildBrandSection(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildPriceRange() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${_currentRangeValues.start.round()}', style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('\$${_currentRangeValues.end.round()}', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFDB3022),
              inactiveTrackColor: Colors.grey[300],
              thumbColor: const Color(0xFFDB3022),
              overlayColor: const Color(0xFFDB3022).withOpacity(0.2),
              trackHeight: 2.0,
            ),
            child: RangeSlider(
              values: _currentRangeValues,
              min: 0,
              max: 200,
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColors() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_colors.length, (index) {
          bool isSelected = _selectedColors.contains(index);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedColors.remove(index);
                } else {
                  _selectedColors.add(index);
                }
              });
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: const Color(0xFFDB3022), width: 1.5) : null,
              ),
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _colors[index],
                    border: _colors[index] == const Color(0xFFF6F6F6) 
                        ? Border.all(color: Colors.grey[300]!)
                        : null,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSizes() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _sizes.map((size) {
          bool isSelected = _selectedSizes.contains(size);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedSizes.remove(size);
                } else {
                  _selectedSizes.add(size);
                }
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFDB3022) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? const Color(0xFFDB3022) : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  size,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _categories.map((category) {
          bool isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              width: 100, // approximate width from screenshot
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFDB3022) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? const Color(0xFFDB3022) : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BrandScreen(selectedBrands: _selectedBrands),
              ),
            );
            if (result != null) {
              setState(() {
                _selectedBrands = result;
              });
            }
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Brand', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        _selectedBrands.join(', '),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context); // Discard changes
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Discard', style: TextStyle(color: Colors.black, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Apply changes (mocked)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDB3022),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
              ),
              child: const Text('Apply', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
