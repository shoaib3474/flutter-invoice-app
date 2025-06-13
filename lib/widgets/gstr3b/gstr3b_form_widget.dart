// ignore_for_file: sort_constructors_first, library_private_types_in_public_api, unused_field, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/gstr3b_model.dart';
import 'package:flutter_invoice_app/services/gstr3b_service.dart';
import 'package:flutter_invoice_app/utils/error_handler.dart';
import 'package:flutter_invoice_app/widgets/error_boundary_widget.dart';

class GSTR3BFormWidget extends StatefulWidget {
  final GSTR3BModel? initialData;
  final Function(GSTR3BModel) onSave;
  final bool isReadOnly;

  const GSTR3BFormWidget({
    required this.onSave,
    Key? key,
    this.initialData,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  _GSTR3BFormWidgetState createState() => _GSTR3BFormWidgetState();
}

class _GSTR3BFormWidgetState extends State<GSTR3BFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late GSTR3BModel _formData;
  final GSTR3BService _gstr3bService = GSTR3BService();
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _formData = widget.initialData?.copy() ?? GSTR3BModel.empty();
  }

  void _updateFormField(String field, dynamic value) {
    setState(() {
      switch (field) {
        case 'gstin':
          _formData.gstin = value;
          break;
        case 'financialYear':
          _formData.financialYear = value;
          break;
        case 'taxPeriod':
          _formData.taxPeriod = value;
          break;
        case 'outwardSuppliesTotal':
          _formData.outwardSuppliesTotal = double.tryParse(value) ?? 0.0;
          break;
        case 'outwardSuppliesZeroRated':
          _formData.outwardSuppliesZeroRated = double.tryParse(value) ?? 0.0;
          break;
        case 'outwardSuppliesNilRated':
          _formData.outwardSuppliesNilRated = double.tryParse(value) ?? 0.0;
          break;
        case 'inwardSuppliesReverseCharge':
          _formData.inwardSuppliesReverseCharge = double.tryParse(value) ?? 0.0;
          break;
        case 'inwardSuppliesImport':
          _formData.inwardSuppliesImport = double.tryParse(value) ?? 0.0;
          break;
        case 'itcAvailed':
          _formData.itcAvailed = double.tryParse(value) ?? 0.0;
          break;
        case 'itcReversed':
          _formData.itcReversed = double.tryParse(value) ?? 0.0;
          break;
        case 'taxPayableCGST':
          _formData.taxPayableCGST = double.tryParse(value) ?? 0.0;
          break;
        case 'taxPayableSGST':
          _formData.taxPayableCGST = double.tryParse(value) ?? 0.0;
          break;
        case 'taxPayableIGST':
          _formData.taxPayableCGST = double.tryParse(value) ?? 0.0;
          break;
        case 'taxPayableCess':
          _formData.taxPayableCess = double.tryParse(value) ?? 0.0;
          break;
        // Add other fields as needed
      }
      _hasChanges = true;
    });
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _gstr3bService.validateGSTR3B(_formData);
        widget.onSave(_formData);
        setState(() {
          _hasChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GSTR-3B data saved successfully')),
        );
      } catch (e) {
        ErrorHandler.showError(context, 'Failed to save GSTR-3B data', e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundaryWidget(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GSTR-3B Form',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // GSTIN Field
                TextFormField(
                  initialValue: _formData.gstin,
                  decoration: const InputDecoration(
                    labelText: 'GSTIN',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your 15-digit GSTIN',
                  ),
                  enabled: !widget.isReadOnly,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter GSTIN';
                    }
                    if (value.length != 15) {
                      return 'GSTIN must be 15 characters';
                    }
                    return null;
                  },
                  onChanged: (value) => _updateFormField('gstin', value),
                ),
                const SizedBox(height: 16),

                // Financial Year Dropdown
                DropdownButtonFormField<String>(
                  value: _formData.financialYear,
                  decoration: const InputDecoration(
                    labelText: 'Financial Year',
                    border: OutlineInputBorder(),
                  ),
                  items: _gstr3bService.getFinancialYears().map((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) => _updateFormField('financialYear', value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select financial year';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tax Period Dropdown
                DropdownButtonFormField<String>(
                  value: _formData.taxPeriod,
                  decoration: const InputDecoration(
                    labelText: 'Tax Period',
                    border: OutlineInputBorder(),
                  ),
                  items: _gstr3bService.getTaxPeriods().map((String period) {
                    return DropdownMenuItem<String>(
                      value: period,
                      child: Text(period),
                    );
                  }).toList(),
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) => _updateFormField('taxPeriod', value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select tax period';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Outward Supplies Section
                _buildOutwardSuppliesSection(),

                // Inward Supplies Section
                _buildInwardSuppliesSection(),

                // ITC Details Section
                _buildITCDetailsSection(),

                // Tax Payable Section
                _buildTaxPayableSection(),

                // Save Button
                if (!widget.isReadOnly)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveForm,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Save GSTR-3B Data'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutwardSuppliesSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Outward Supplies',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _formData.outwardSuppliesTotal?.toString() ?? '0.0',
              decoration: const InputDecoration(
                labelText: 'Total Taxable Value',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isReadOnly,
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  _updateFormField('outwardSuppliesTotal', value),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue:
                  _formData.outwardSuppliesZeroRated?.toString() ?? '0.0',
              decoration: const InputDecoration(
                labelText: 'Zero Rated Supplies',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isReadOnly,
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  _updateFormField('outwardSuppliesZeroRated', value),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue:
                  _formData.outwardSuppliesNilRated?.toString() ?? '0.0',
              decoration: const InputDecoration(
                labelText: 'Nil Rated, Exempted Supplies',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isReadOnly,
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  _updateFormField('outwardSuppliesNilRated', value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInwardSuppliesSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inward Supplies',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue:
                  _formData.inwardSuppliesReverseCharge?.toString() ?? '0.0',
              decoration: const InputDecoration(
                labelText: 'Reverse Charge',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isReadOnly,
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  _updateFormField('inwardSuppliesReverseCharge', value),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _formData.inwardSuppliesImport?.toString() ?? '0.0',
              decoration: const InputDecoration(
                labelText: 'Import of Goods',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isReadOnly,
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  _updateFormField('inwardSuppliesImport', value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildITCDetailsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Input Tax Credit (ITC)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _formData.itcAvailed?.toString() ?? '0.0',
              decoration: const InputDecoration(
                labelText: 'ITC Availed',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isReadOnly,
              keyboardType: TextInputType.number,
              onChanged: (value) => _updateFormField('itcAvailed', value),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _formData.itcReversed?.toString() ?? '0.0',
              decoration: const InputDecoration(
                labelText: 'ITC Reversed',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isReadOnly,
              keyboardType: TextInputType.number,
              onChanged: (value) => _updateFormField('itcReversed', value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxPayableSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tax Payable',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _formData.taxPayableCGST?.toString() ?? '0.0',
              decoration: const InputDecoration(
                labelText: 'CGST',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isReadOnly,
              keyboardType: TextInputType.number,
              onChanged: (value) => _updateFormField('taxPayableCGST', value),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _formData.taxPayableCGST?.toString() ?? '0.0',
              decoration: const InputDecoration(
                labelText: 'SGST',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isReadOnly,
              keyboardType: TextInputType.number,
              onChanged: (value) => _updateFormField('taxPayableSGST', value),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _formData.taxPayableCGST?.toString() ?? '0.0',
              decoration: const InputDecoration(
                labelText: 'IGST',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isReadOnly,
              keyboardType: TextInputType.number,
              onChanged: (value) => _updateFormField('taxPayableIGST', value),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _formData.taxPayableCess?.toString() ?? '0.0',
              decoration: const InputDecoration(
                labelText: 'Cess',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isReadOnly,
              keyboardType: TextInputType.number,
              onChanged: (value) => _updateFormField('taxPayableCess', value),
            ),
          ],
        ),
      ),
    );
  }
}
