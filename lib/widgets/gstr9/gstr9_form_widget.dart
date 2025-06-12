import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/gstr9_model.dart';

class GSTR9FormWidget extends StatefulWidget {
  final GSTR9? initialData;
  final Function(GSTR9) onSave;
  final String? gstin;
  final String? financialYear;

  const GSTR9FormWidget({
    Key? key,
    this.initialData,
    required this.onSave,
    this.gstin,
    this.financialYear,
  }) : super(key: key);

  @override
  _GSTR9FormWidgetState createState() => _GSTR9FormWidgetState();
}

class _GSTR9FormWidgetState extends State<GSTR9FormWidget> {
  final _formKey = GlobalKey<FormState>();
  late GSTR9 _gstr9Data;
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _financialYearController = TextEditingController();
  final TextEditingController _legalNameController = TextEditingController();
  final TextEditingController _tradeNameController = TextEditingController();

  // Part 4 controllers
  final TextEditingController _itcAvailedOnInvoicesController = TextEditingController();
  final TextEditingController _itcReversedAndReclaimedController = TextEditingController();
  final TextEditingController _itcAvailedButIneligibleController = TextEditingController();

  // Part 5 controllers
  final TextEditingController _refundClaimedController = TextEditingController();
  final TextEditingController _refundSanctionedController = TextEditingController();
  final TextEditingController _refundRejectedController = TextEditingController();
  final TextEditingController _refundPendingController = TextEditingController();

  // Part 6 controllers
  final TextEditingController _taxPayableAsPerSection73Or74Controller = TextEditingController();
  final TextEditingController _taxPaidAsPerSection73Or74Controller = TextEditingController();
  final TextEditingController _interestPayableAsPerSection73Or74Controller = TextEditingController();
  final TextEditingController _interestPaidAsPerSection73Or74Controller = TextEditingController();

  bool _isLoading = false;
  bool _isReadOnly = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.initialData != null) {
      _gstr9Data = widget.initialData!;
      _isReadOnly = true;
    } else {
      // Initialize with default values if no data provided
      _gstr9Data = GSTR9(
        gstin: widget.gstin ?? '',
        financialYear: widget.financialYear ?? '',
        legalName: '',
        tradeName: '',
        part1: GSTR9Part1(
          totalOutwardSupplies: 0.0,
          zeroRatedSupplies: 0.0,
          nilRatedSupplies: 0.0,
          exemptedSupplies: 0.0,
          nonGSTSupplies: 0.0,
        ),
        part2: GSTR9Part2(
          inwardSuppliesAttractingReverseCharge: 0.0,
          importsOfGoodsAndServices: 0.0,
          inwardSuppliesLiableToReverseCharge: 0.0,
        ),
        part3: GSTR9Part3(
          taxPayableOnOutwardSupplies: 0.0,
          taxPayableOnReverseCharge: 0.0,
          interestPayable: 0.0,
          lateFeePayable: 0.0,
          penaltyPayable: 0.0,
        ),
        part4: GSTR9Part4(
          itcAvailedOnInvoices: 0.0,
          itcReversedAndReclaimed: 0.0,
          itcAvailedButIneligible: 0.0,
        ),
        part5: GSTR9Part5(
          refundClaimed: 0.0,
          refundSanctioned: 0.0,
          refundRejected: 0.0,
          refundPending: 0.0,
        ),
        part6: GSTR9Part6(
          taxPayableAsPerSection73Or74: 0.0,
          taxPaidAsPerSection73Or74: 0.0,
          interestPayableAsPerSection73Or74: 0.0,
          interestPaidAsPerSection73Or74: 0.0,
        ),
      );
    }

    // Set controller values
    _gstinController.text = _gstr9Data.gstin;
    _financialYearController.text = _gstr9Data.financialYear;
    _legalNameController.text = _gstr9Data.legalName;
    _tradeNameController.text = _gstr9Data.tradeName;

    // Part 4
    _itcAvailedOnInvoicesController.text = _gstr9Data.part4.itcAvailedOnInvoices.toString();
    _itcReversedAndReclaimedController.text = _gstr9Data.part4.itcReversedAndReclaimed.toString();
    _itcAvailedButIneligibleController.text = _gstr9Data.part4.itcAvailedButIneligible.toString();

    // Part 5
    _refundClaimedController.text = _gstr9Data.part5.refundClaimed.toString();
    _refundSanctionedController.text = _gstr9Data.part5.refundSanctioned.toString();
    _refundRejectedController.text = _gstr9Data.part5.refundRejected.toString();
    _refundPendingController.text = _gstr9Data.part5.refundPending.toString();

    // Part 6
    _taxPayableAsPerSection73Or74Controller.text = _gstr9Data.part6.taxPayableAsPerSection73Or74.toString();
    _taxPaidAsPerSection73Or74Controller.text = _gstr9Data.part6.taxPaidAsPerSection73Or74.toString();
    _interestPayableAsPerSection73Or74Controller.text = _gstr9Data.part6.interestPayableAsPerSection73Or74.toString();
    _interestPaidAsPerSection73Or74Controller.text = _gstr9Data.part6.interestPaidAsPerSection73Or74.toString();
  }

  @override
  void dispose() {
    // Dispose of controllers
    _gstinController.dispose();
    _financialYearController.dispose();
    _legalNameController.dispose();
    _tradeNameController.dispose();
    
    _itcAvailedOnInvoicesController.dispose();
    _itcReversedAndReclaimedController.dispose();
    _itcAvailedButIneligibleController.dispose();
    
    _refundClaimedController.dispose();
    _refundSanctionedController.dispose();
    _refundRejectedController.dispose();
    _refundPendingController.dispose();
    
    _taxPayableAsPerSection73Or74Controller.dispose();
    _taxPaidAsPerSection73Or74Controller.dispose();
    _interestPayableAsPerSection73Or74Controller.dispose();
    _interestPaidAsPerSection73Or74Controller.dispose();
    
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Update GSTR9 data with form values
        final updatedGSTR9 = GSTR9(
          gstin: _gstinController.text,
          financialYear: _financialYearController.text,
          legalName: _legalNameController.text,
          tradeName: _tradeNameController.text,
          part1: _gstr9Data.part1, // Auto-populated parts remain unchanged
          part2: _gstr9Data.part2,
          part3: _gstr9Data.part3,
          part4: GSTR9Part4(
            itcAvailedOnInvoices: double.parse(_itcAvailedOnInvoicesController.text),
            itcReversedAndReclaimed: double.parse(_itcReversedAndReclaimedController.text),
            itcAvailedButIneligible: double.parse(_itcAvailedButIneligibleController.text),
          ),
          part5: GSTR9Part5(
            refundClaimed: double.parse(_refundClaimedController.text),
            refundSanctioned: double.parse(_refundSanctionedController.text),
            refundRejected: double.parse(_refundRejectedController.text),
            refundPending: double.parse(_refundPendingController.text),
          ),
          part6: GSTR9Part6(
            taxPayableAsPerSection73Or74: double.parse(_taxPayableAsPerSection73Or74Controller.text),
            taxPaidAsPerSection73Or74: double.parse(_taxPaidAsPerSection73Or74Controller.text),
            interestPayableAsPerSection73Or74: double.parse(_interestPayableAsPerSection73Or74Controller.text),
            interestPaidAsPerSection73Or74: double.parse(_interestPaidAsPerSection73Or74Controller.text),
          ),
        );

        // Call the onSave callback
        await widget.onSave(updatedGSTR9);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 20),
              _buildAutoPopulatedPartsSection(),
              const SizedBox(height: 20),
              _buildPart4Section(),
              const SizedBox(height: 20),
              _buildPart5Section(),
              const SizedBox(height: 20),
              _buildPart6Section(),
              const SizedBox(height: 30),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _gstinController,
              decoration: const InputDecoration(
                labelText: 'GSTIN',
                border: OutlineInputBorder(),
              ),
              readOnly: _isReadOnly || widget.gstin != null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter GSTIN';
                }
                if (value.length != 15) {
                  return 'GSTIN must be 15 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _financialYearController,
              decoration: const InputDecoration(
                labelText: 'Financial Year',
                border: OutlineInputBorder(),
                hintText: 'Format: YYYY-YY (e.g., 2022-23)',
              ),
              readOnly: _isReadOnly || widget.financialYear != null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Financial Year';
                }
                if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(value)) {
                  return 'Please enter Financial Year in format YYYY-YY';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _legalNameController,
              decoration: const InputDecoration(
                labelText: 'Legal Name',
                border: OutlineInputBorder(),
              ),
              readOnly: _isReadOnly,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Legal Name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tradeNameController,
              decoration: const InputDecoration(
                labelText: 'Trade Name',
                border: OutlineInputBorder(),
              ),
              readOnly: _isReadOnly,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoPopulatedPartsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  'Auto-Populated Parts (From GSTR-1 & GSTR-3B)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Tooltip(
                  message: 'These sections are automatically populated from your GSTR-1 and GSTR-3B returns data.',
                  child: Icon(Icons.info_outline, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Part 1
            const Text(
              'Part 1: Details of outward supplies',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Total outward supplies'),
              trailing: Text('₹ ${_gstr9Data.part1.totalOutwardSupplies.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Zero-rated supplies'),
              trailing: Text('₹ ${_gstr9Data.part1.zeroRatedSupplies.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Nil-rated supplies'),
              trailing: Text('₹ ${_gstr9Data.part1.nilRatedSupplies.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Exempted supplies'),
              trailing: Text('₹ ${_gstr9Data.part1.exemptedSupplies.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Non-GST supplies'),
              trailing: Text('₹ ${_gstr9Data.part1.nonGSTSupplies.toStringAsFixed(2)}'),
            ),
            const Divider(),
            
            // Part 2
            const Text(
              'Part 2: Details of inward supplies',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Inward supplies attracting reverse charge'),
              trailing: Text('₹ ${_gstr9Data.part2.inwardSuppliesAttractingReverseCharge.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Imports of goods and services'),
              trailing: Text('₹ ${_gstr9Data.part2.importsOfGoodsAndServices.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Inward supplies liable to reverse charge'),
              trailing: Text('₹ ${_gstr9Data.part2.inwardSuppliesLiableToReverseCharge.toStringAsFixed(2)}'),
            ),
            const Divider(),
            
            // Part 3
            const Text(
              'Part 3: Details of tax paid',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Tax payable on outward supplies'),
              trailing: Text('₹ ${_gstr9Data.part3.taxPayableOnOutwardSupplies.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Tax payable on reverse charge'),
              trailing: Text('₹ ${_gstr9Data.part3.taxPayableOnReverseCharge.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Interest payable'),
              trailing: Text('₹ ${_gstr9Data.part3.interestPayable.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Late fee payable'),
              trailing: Text('₹ ${_gstr9Data.part3.lateFeePayable.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Penalty payable'),
              trailing: Text('₹ ${_gstr9Data.part3.penaltyPayable.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPart4Section() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Part 4: Details of ITC availed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              controller: _itcAvailedOnInvoicesController,
              labelText: 'ITC Availed on Invoices',
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              controller: _itcReversedAndReclaimedController,
              labelText: 'ITC Reversed and Reclaimed',
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              controller: _itcAvailedButIneligibleController,
              labelText: 'ITC Availed but Ineligible',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPart5Section() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Part 5: Details of Refunds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              controller: _refundClaimedController,
              labelText: 'Refund Claimed',
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              controller: _refundSanctionedController,
              labelText: 'Refund Sanctioned',
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              controller: _refundRejectedController,
              labelText: 'Refund Rejected',
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              controller: _refundPendingController,
              labelText: 'Refund Pending',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPart6Section() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Part 6: Tax, Interest, Late Fee, Penalties',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              controller: _taxPayableAsPerSection73Or74Controller,
              labelText: 'Tax Payable as per Section 73 or 74',
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              controller: _taxPaidAsPerSection73Or74Controller,
              labelText: 'Tax Paid as per Section 73 or 74',
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              controller: _interestPayableAsPerSection73Or74Controller,
              labelText: 'Interest Payable as per Section 73 or 74',
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              controller: _interestPaidAsPerSection73Or74Controller,
              labelText: 'Interest Paid as per Section 73 or 74',
            ),
          ],
        ),
      ),
    );
  }

  // Reusable number field to reduce code duplication
  Widget _buildNumberField({
    required TextEditingController controller,
    required String labelText,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixText: '₹ ',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      readOnly: readOnly,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text('Save GSTR-9 Data', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
