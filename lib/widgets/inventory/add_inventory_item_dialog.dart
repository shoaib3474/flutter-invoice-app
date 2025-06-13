// ignore_for_file: use_if_null_to_convert_nulls_to_bools

import 'package:flutter/material.dart';
import '../../models/inventory/inventory_item_model.dart';

// Ensure that InventoryCategory is defined in inventory_category_model.dart and imported correctly.

class AddInventoryItemDialog extends StatefulWidget {
  const AddInventoryItemDialog({
    required this.categories,
    required this.onSave,
    super.key,
    this.item,
  });
  final List<InventoryCategory> categories;
  final InventoryItem? item;
  final Function(InventoryItem) onSave;

  @override
  State<AddInventoryItemDialog> createState() => _AddInventoryItemDialogState();
}

class _AddInventoryItemDialogState extends State<AddInventoryItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _gstRateController = TextEditingController();
  final _hsnCodeController = TextEditingController();

  String _selectedCategory = '';
  String _selectedUnit = 'Piece';

  final List<String> _units = ['Piece', 'Kg', 'Liter', 'Meter', 'Box', 'Pack'];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _priceController.text = widget.item!.price.toString();
      _stockController.text = widget.item!.stockQuantity.toString();
      _barcodeController.text = widget.item!.barcode ?? '';
      _descriptionController.text = widget.item!.description;
      _gstRateController.text = widget.item!.gstRate?.toString() ?? '';
      _hsnCodeController.text = widget.item!.hsnCode ?? '';
      _selectedCategory = widget.item!.category;
      _selectedUnit = widget.item!.unit;
    } else if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.item == null ? 'Add New Item' : 'Edit Item',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Item Name',
                        validator: (value) =>
                            value?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: _priceController,
                              label: 'Price (₹)',
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildUnitDropdown(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _stockController,
                        label: 'Stock Quantity',
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _barcodeController,
                        label: 'Barcode (Optional)',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _gstRateController,
                              label: 'GST Rate % (Optional)',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _hsnCodeController,
                              label: 'HSN Code (Optional)',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description (Optional)',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(widget.item == null ? 'Add Item' : 'Update Item'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory.isEmpty ? null : _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: widget.categories.map((category) {
        return DropdownMenuItem(
          value: category.name,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedCategory = value ?? '');
      },
      validator: (value) => value?.isEmpty == true ? 'Required' : null,
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedUnit,
      decoration: InputDecoration(
        labelText: 'Unit',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: _units.map((unit) {
        return DropdownMenuItem(
          value: unit,
          child: Text(unit),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedUnit = value ?? 'Piece');
      },
    );
  }

  void _saveItem() {
    if (_formKey.currentState?.validate() == true) {
      final item = InventoryItem(
        id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        costPrice: double.tryParse(_priceController.text) ??
            0.0, // Replace with actual cost price controller if available
        sellingPrice: double.tryParse(_priceController.text) ??
            0.0, // Replace with actual selling price controller if available
        unit: _selectedUnit,
        stockQuantity: int.parse(_stockController.text),
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? ''
            : _descriptionController.text.trim(),
        taxRate: _gstRateController.text.trim().isEmpty
            ? 0.0
            : double.parse(_gstRateController.text),
        hsnCode: _hsnCodeController.text.trim().isEmpty
            ? null
            : _hsnCodeController.text.trim(),
        createdAt: widget.item?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave(item);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _gstRateController.dispose();
    _hsnCodeController.dispose();
    super.dispose();
  }
}
