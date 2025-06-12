import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_item_model.dart';
import 'package:flutter_invoice_app/widgets/common/custom_text_field.dart';

class InvoiceItemForm extends StatefulWidget {
  const InvoiceItemForm({
    super.key,
    this.item,
    required this.isInterState,
    required this.onSave,
  });

  final InvoiceItem? item;
  final bool isInterState;
  final void Function(InvoiceItem) onSave;

  @override
  State<InvoiceItemForm> createState() => _InvoiceItemFormState();
}

class _InvoiceItemFormState extends State<InvoiceItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hsnSacController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _cgstRateController = TextEditingController();
  final _sgstRateController = TextEditingController();
  final _igstRateController = TextEditingController();
  final _cessRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _populateForm();
    } else {
      _setDefaultValues();
    }
  }

  void _populateForm() {
    final item = widget.item!;
    _nameController.text = item.name;
    _descriptionController.text = item.description;
    _hsnSacController.text = item.hsnSacCode;
    _quantityController.text = item.quantity.toString();
    _unitController.text = item.unit;
    _unitPriceController.text = item.unitPrice.toString();
    _discountController.text = item.discount.toString();
    _cgstRateController.text = item.cgstRate.toString();
    _sgstRateController.text = item.sgstRate.toString();
    _igstRateController.text = item.igstRate.toString();
    _cessRateController.text = item.cessRate.toString();
  }

  void _setDefaultValues() {
    _quantityController.text = '1';
    _unitController.text = 'Nos';
    _discountController.text = '0';
    _cgstRateController.text = widget.isInterState ? '0' : '9';
    _sgstRateController.text = widget.isInterState ? '0' : '9';
    _igstRateController.text = widget.isInterState ? '18' : '0';
    _cessRateController.text = '0';
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) return;

    final item = InvoiceItem.create(
      name: _nameController.text,
      description: _descriptionController.text,
      hsnSacCode: _hsnSacController.text,
      quantity: double.parse(_quantityController.text),
      unit: _unitController.text,
      unitPrice: double.parse(_unitPriceController.text),
      discount: double.parse(_discountController.text),
      cgstRate: double.parse(_cgstRateController.text),
      sgstRate: double.parse(_sgstRateController.text),
      igstRate: double.parse(_igstRateController.text),
      cessRate: double.parse(_cessRateController.text),
      isInterState: widget.isInterState,
    );

    widget.onSave(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.item != null ? 'Edit Item' : 'Add Item',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _nameController,
                            labelText: 'Item Name',
                            hintText: 'Enter item name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter item name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _descriptionController,
                            labelText: 'Description',
                            hintText: 'Enter description (optional)',
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _hsnSacController,
                            labelText: 'HSN/SAC Code',
                            hintText: 'Enter HSN/SAC code',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter HSN/SAC code';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _quantityController,
                                  labelText: 'Quantity',
                                  hintText: 'Enter quantity',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  controller: _unitController,
                                  labelText: 'Unit',
                                  hintText: 'Enter unit',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _unitPriceController,
                                  labelText: 'Unit Price',
                                  hintText: 'Enter unit price',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  controller: _discountController,
                                  labelText: 'Discount (%)',
                                  hintText: 'Enter discount',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tax Rates',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          if (!widget.isInterState) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _cgstRateController,
                                    labelText: 'CGST Rate (%)',
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Invalid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _sgstRateController,
                                    labelText: 'SGST Rate (%)',
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Invalid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            CustomTextField(
                              controller: _igstRateController,
                              labelText: 'IGST Rate (%)',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _cessRateController,
                            labelText: 'Cess Rate (%)',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveItem,
                      child: Text(widget.item != null ? 'Update Item' : 'Add Item'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _hsnSacController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _unitPriceController.dispose();
    _discountController.dispose();
    _cgstRateController.dispose();
    _sgstRateController.dispose();
    _igstRateController.dispose();
    _cessRateController.dispose();
    super.dispose();
  }
}
