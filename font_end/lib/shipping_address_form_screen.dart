import 'package:flutter/material.dart';
import 'package:font_end/models/user_address.dart';
import 'package:font_end/services/checkout_service.dart';

class ShippingAddressFormScreen extends StatefulWidget {
  final UserAddress? addressToEdit;

  const ShippingAddressFormScreen({super.key, this.addressToEdit});

  @override
  State<ShippingAddressFormScreen> createState() => _ShippingAddressFormScreenState();
}

class _ShippingAddressFormScreenState extends State<ShippingAddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;

  List<String> _countries = [
    'Vietnam',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Japan',
    'South Korea',
    'France',
    'Germany',
    'Singapore'
  ];
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.addressToEdit?.fullName ?? '');
    _addressController = TextEditingController(text: widget.addressToEdit?.address ?? '');
    _cityController = TextEditingController(text: widget.addressToEdit?.city ?? '');
    _stateController = TextEditingController(text: widget.addressToEdit?.state ?? '');
    _zipCodeController = TextEditingController(text: widget.addressToEdit?.zipCode ?? '');
    
    String? initialCountry = widget.addressToEdit?.country;
    if (initialCountry != null && initialCountry.isNotEmpty) {
      if (!_countries.contains(initialCountry)) {
        _countries.add(initialCountry);
      }
      _selectedCountry = initialCountry;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newAddress = UserAddress(
      id: widget.addressToEdit?.id ?? '',
      fullName: _nameController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      zipCode: _zipCodeController.text,
      country: _selectedCountry ?? '',
      isDefault: widget.addressToEdit?.isDefault ?? false,
    );

    if (widget.addressToEdit == null) {
      await checkoutService.addAddress(newAddress);
    } else {
      await checkoutService.updateAddress(newAddress.id, newAddress);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.addressToEdit != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Editing Shipping Address' : 'Adding Shipping Address',
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                _nameController, 
                'Full name', 
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter full name' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _addressController, 
                'Address', 
                validator: (val) => val == null || val.trim().length < 5 ? 'Address must be at least 5 characters' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _cityController, 
                'City',
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter city' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _stateController, 
                'State/Province/Region',
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter state/region' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _zipCodeController, 
                'Zip Code (Postal Code)',
                validator: (val) => val == null || val.trim().length < 4 ? 'Invalid zip code' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('SAVE ADDRESS', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {Widget? suffixIcon, String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCountry,
        validator: (val) => val == null || val.trim().isEmpty ? 'Please select country' : null,
        decoration: const InputDecoration(
          labelText: 'Country',
          labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        items: _countries.map((String country) {
          return DropdownMenuItem<String>(
            value: country,
            child: Text(country),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCountry = newValue;
          });
        },
      ),
    );
  }
}
