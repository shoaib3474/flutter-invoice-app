// ignore_for_file: library_private_types_in_public_api, avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/gstr4_model.dart';

class GSTR4FormWidget extends StatefulWidget {
  const GSTR4FormWidget({
    required this.onSave,
    Key? key,
    this.initialData,
  }) : super(key: key);
  final GSTR4Model? initialData;
  final Function(GSTR4Model) onSave;

  @override
  _GSTR4FormWidgetState createState() => _GSTR4FormWidgetState();
}

class _GSTR4FormWidgetState extends State<GSTR4FormWidget> {
  final _formKey = GlobalKey<FormState>();
  late GSTR4Model _formData;
  final TextEditingController _periodController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();

  // Controllers for outward supplies
  final TextEditingController _b2bSuppliesController = TextEditingController();
  final TextEditingController _b2cSuppliesController = TextEditingController();

  // Controllers for inward supplies
  final TextEditingController _inwardRCMController = TextEditingController();
  final TextEditingController _inwardImportsController =
      TextEditingController();

  // Controllers for tax payment
  final TextEditingController _cgstController = TextEditingController();
  final TextEditingController _sgstController = TextEditingController();
  final TextEditingController _igstController = TextEditingController();
  final TextEditingController _cessController = TextEditingController();

  get b2bIst => null;

  @override
  void initState() {
    super.initState();
    _formData = widget.initialData ??
        GSTR4Model(
          gstin: '',
          returnPeriod: '',
          filingDate: DateTime.now(),
          b2burInvoices: const [],
          importedGoods: const [],
          taxesPaid: const [],
        );
    _periodController.text = _formData.taxPeriod ?? '';
    _gstinController.text = _formData.gstin;

    // Initialize outward supplies controllers
    _b2bSuppliesController.text =
        _formData.outwardSupplies?.b2bSupplies?.toString() ?? '0';
    _b2cSuppliesController.text =
        _formData.outwardSupplies?.b2cSupplies?.toString() ?? '0';

    // Initialize inward supplies controllers
    _inwardRCMController.text =
        _formData.inwardSupplies?.reverseChargeSupplies?.toString() ?? '0';
    _inwardImportsController.text =
        _formData.inwardSupplies?.imports?.toString() ?? '0';

    // Initialize tax payment controllers
    _cgstController.text = _formData.taxPayment?.cgst?.toString() ?? '0';
    _sgstController.text = _formData.taxPayment?.sgst?.toString() ?? '0';
    _igstController.text = _formData.taxPayment?.igst?.toString() ?? '0';
    _cessController.text = _formData.taxPayment?.cess?.toString() ?? '0';
  }

  @override
  void dispose() {
    _periodController.dispose();
    _gstinController.dispose();
    _b2bSuppliesController.dispose();
    _b2cSuppliesController.dispose();
    _inwardRCMController.dispose();
    _inwardImportsController.dispose();
    _cgstController.dispose();
    _sgstController.dispose();
    _igstController.dispose();
    _cessController.dispose();
    super.dispose();
  }

  Future<void> _selectPeriod() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2017),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Format as MM-YYYY for tax period
        _periodController.text = DateFormat('MM-yyyy').format(picked);
        _formData.taxPeriod = _periodController.text;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Update outward supplies
      _formData.outwardSupplies ??= GSTR4OutwardSupplies();
      _formData.outwardSupplies!.b2bSupplies =
          double.tryParse(_b2bSuppliesController.text) ?? 0;
      _formData.outwardSupplies!.b2cSupplies =
          double.tryParse(_b2cSuppliesController.text) ?? 0;

      // Update inward supplies
      _formData.inwardSupplies ??= GSTR4InwardSupplies();
      _formData.inwardSupplies!.reverseChargeSupplies =
          double.tryParse(_inwardRCMController.text) ?? 0;
      _formData.inwardSupplies!.imports =
          double.tryParse(_inwardImportsController.text) ?? 0;

      // Update tax payment
      _formData.taxPayment ??= GSTR4TaxPayment();
      _formData.taxPayment!.cgst = double.tryParse(_cgstController.text) ?? 0;
      _formData.taxPayment!.sgst = double.tryParse(_sgstController.text) ?? 0;
      _formData.taxPayment!.igst = double.tryParse(_igstController.text) ?? 0;
      _formData.taxPayment!.cess = double.tryParse(_cessController.text) ?? 0;

      widget.onSave(_formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GSTR-4 Form (Composition Scheme)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // GSTIN Field
            TextFormField(
              controller: _gstinController,
              decoration: const InputDecoration(
                labelText: 'GSTIN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter GSTIN';
                }
                if (!RegExp(
                        r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid GSTIN';
                }
                return null;
              },
              onSaved: (value) {
                _formData.gstin = value!;
              },
            ),
            const SizedBox(height: 16),

            // Tax Period Field
            GestureDetector(
              onTap: _selectPeriod,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _periodController,
                  decoration: const InputDecoration(
                    labelText: 'Tax Period (MM-YYYY)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select tax period';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Financial Year Field
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Financial Year',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_view_month),
              ),
              value: _formData.financialYear,
              items: [
                '2021-2022',
                '2022-2023',
                '2023-2024',
                '2024-2025',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _formData.financialYear = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select financial year';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Outward Supplies Section
            _buildSectionHeader(context, 'Outward Supplies'),
            const SizedBox(height: 8),

            // B2B Supplies
            TextFormField(
              controller: _b2bSuppliesController,
              decoration: const InputDecoration(
                labelText: 'B2B Supplies',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter B2B supplies value';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // B2C Supplies
            TextFormField(
              controller: _b2cSuppliesController,
              decoration: const InputDecoration(
                labelText: 'B2C Supplies',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter B2C supplies value';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Inward Supplies Section
            _buildSectionHeader(context, 'Inward Supplies'),
            const SizedBox(height: 8),

            // Reverse Charge Mechanism Supplies
            TextFormField(
              controller: _inwardRCMController,
              decoration: const InputDecoration(
                labelText: 'Reverse Charge Supplies',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter reverse charge supplies value';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Imports
            TextFormField(
              controller: _inwardImportsController,
              decoration: const InputDecoration(
                labelText: 'Imports',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter imports value';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Tax Payment Section
            _buildSectionHeader(context, 'Tax Payment'),
            const SizedBox(height: 8),

            // CGST
            TextFormField(
              controller: _cgstController,
              decoration: const InputDecoration(
                labelText: 'CGST',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter CGST value';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // SGST
            TextFormField(
              controller: _sgstController,
              decoration: const InputDecoration(
                labelText: 'SGST',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter SGST value';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // IGST
            TextFormField(
              controller: _igstController,
              decoration: const InputDecoration(
                labelText: 'IGST',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter IGST value';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // CESS
            TextFormField(
              controller: _cessController,
              decoration: const InputDecoration(
                labelText: 'CESS',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter CESS value';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save GSTR-4 Return'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
