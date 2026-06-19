import 'package:flutter/material.dart';

class BrandScreen extends StatefulWidget {
  final List<String> selectedBrands;

  const BrandScreen({super.key, required this.selectedBrands});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  final List<String> _allBrands = [
    'adidas',
    'adidas Originals',
    'Blend',
    'Boutique Moschino',
    'Champion',
    'Diesel',
    'Jack & Jones',
    'Naf Naf',
    'Red Valentino',
    's.Oliver',
  ];

  late List<String> _selectedBrands;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedBrands = List.from(widget.selectedBrands);
  }

  @override
  Widget build(BuildContext context) {
    final filteredBrands = _allBrands
        .where((brand) => brand.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.2),
        centerTitle: true,
        title: const Text(
          'Brand',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context, widget.selectedBrands),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF9F9F9),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: filteredBrands.length,
                    itemBuilder: (context, index) {
                      final brand = filteredBrands[index];
                      final isSelected = _selectedBrands.contains(brand);
                      return Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(
                            brand,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFFDB3022) : Colors.black,
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                          trailing: Checkbox(
                            value: isSelected,
                            activeColor: const Color(0xFFDB3022),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedBrands.add(brand);
                                } else {
                                  _selectedBrands.remove(brand);
                                }
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedBrands.remove(brand);
                              } else {
                                _selectedBrands.add(brand);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
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
                Navigator.pop(context, widget.selectedBrands); // Discard changes
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
                Navigator.pop(context, _selectedBrands); // Apply changes
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
