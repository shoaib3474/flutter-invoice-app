import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/gstr9c_model.dart';

class GSTR9CFormWidget extends StatefulWidget {
  final GSTR9C? initialData;
  final Function(GSTR9C) onSave;
  final String? gstin;
  final String? financialYear;

  const GSTR9CFormWidget({
    Key? key,
    this.initialData,
    required this.onSave,
    this.gstin,
    this.financialYear,
  }) : super(key: key);

  @override
  _GSTR9CFormWidgetState createState() => _GSTR9CFormWidgetState();
}

class _GSTR9CFormWidgetState extends State<GSTR9CFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late GSTR9C _gstr9CData;
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _financialYearController = TextEditingController();
  final TextEditingController _legalNameController = TextEditingController();
  final TextEditingController _tradeNameController = TextEditingController();

  // Reconciliation controllers
  final TextEditingController _turnoverAsPerAuditedFinancialStatementsController = TextEditingController();
  final TextEditingController _turnoverAsPerAnnualReturnController = TextEditingController();
  final TextEditingController _unReconciledController = TextEditingController();
  final List<Map<String, TextEditingController>> _reconciliationItemsControllers = [];

  // Auditor recommendation controllers
  final List<Map<String, TextEditingController>> _auditorRecommendationControllers = [];

  // Tax payable controllers
  final TextEditingController _taxPayableAsPerReconciliationController = TextEditingController();
  final TextEditingController _taxPaidAsPerAnnualReturnController = TextEditingController();
  final TextEditingController _differentialTaxPayableController = TextEditingController();
  final TextEditingController _interestPayableController = TextEditingController();

  // Auditor details controllers
  final TextEditingController _auditorDetailsController = TextEditingController();
  final TextEditingController _certificationDetailsController = TextEditingController();

  bool _isLoading = false;
  bool _isReadOnly = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.initialData != null) {
      _gstr9CData = widget.initialData!;
      _isReadOnly = true;
    } else {
      // Initialize with default values if no data provided
      _gstr9CData = GSTR9C(
        gstin: widget.gstin ?? '',
        financialYear: widget.financialYear ?? '',
        legalName: '',
        tradeName: '',
        reconciliation: GSTR9CReconciliation(
          turnoverAsPerAuditedFinancialStatements: 0.0,
          turnoverAsPerAnnualReturn: 0.0,
          unReconciled: 0.0,
          reconciliationItems: [],
        ),
        auditorRecommendation: GSTR9CAuditorRecommendation(
          recommendations: [],
        ),
        taxPayable: GSTR9CTaxPayable(
          taxPayableAsPerReconciliation: 0.0,
          taxPaidAsPerAnnualReturn: 0.0,
          differentialTaxPayable: 0.0,
          interestPayable: 0.0,
        ),
        auditorDetails: '',
        certificationDetails: '',
      );
    }

    // Set controller values
    _gstinController.text = _gstr9CData.gstin;
    _financialYearController.text = _gstr9CData.financialYear;
    _legalNameController.text = _gstr9CData.legalName;
    _tradeNameController.text = _gstr9CData.tradeName;

    // Reconciliation
    _turnoverAsPerAuditedFinancialStatementsController.text = 
        _gstr9CData.reconciliation.turnoverAsPerAuditedFinancialStatements.toString();
    _turnoverAsPerAnnualReturnController.text = 
        _gstr9CData.reconciliation.turnoverAsPerAnnualReturn.toString();
    _unReconciledController.text = 
        _gstr9CData.reconciliation.unReconciled.toString();

    // Reconciliation items
    for (var item in _gstr9CData.reconciliation.reconciliationItems) {
      final descriptionController = TextEditingController(text: item.description);
      final amountController = TextEditingController(text: item.amount.toString());
      final reasonController = TextEditingController(text: item.reason);

      _reconciliationItemsControllers.add({
        'description': descriptionController,
        'amount': amountController,
        'reason': reasonController,
      });
    }

    // Auditor recommendations
    for (var item in _gstr9CData.auditorRecommendation.recommendations) {
      final descriptionController = TextEditingController(text: item.description);
      final amountController = TextEditingController(text: item.amount.toString());
      final reasonController = TextEditingController(text: item.reason);

      _auditorRecommendationControllers.add({
        'description': descriptionController,
        'amount': amountController,
        'reason': reasonController,
      });
    }

    // Tax payable
    _taxPayableAsPerReconciliationController.text = 
        _gstr9CData.taxPayable.taxPayableAsPerReconciliation.toString();
    _taxPaidAsPerAnnualReturnController.text = 
        _gstr9CData.taxPayable.taxPaidAsPerAnnualReturn.toString();
    _differentialTaxPayableController.text = 
        _gstr9CData.taxPayable.differentialTaxPayable.toString();
    _interestPayableController.text = 
        _gstr9CData.taxPayable.interestPayable.toString();

    // Auditor details
    _auditorDetailsController.text = _gstr9CData.auditorDetails;
    _certificationDetailsController.text = _gstr9CData.certificationDetails;

    // Add at least one empty reconciliation item if none exists
    if (_reconciliationItemsControllers.isEmpty) {
      _addReconciliationItem();
    }

    // Add at least one empty auditor recommendation if none exists
    if (_auditorRecommendationControllers.isEmpty) {
      _addAuditorRecommendation();
    }
  }

  void _addReconciliationItem() {
    setState(() {
      _reconciliationItemsControllers.add({
        'description': TextEditingController(),
        'amount': TextEditingController(text: '0.0'),
        'reason': TextEditingController(),
      });
    });
  }

  void _removeReconciliationItem(int index) {
    setState(() {
      final controllers = _reconciliationItemsControllers.removeAt(index);
      controllers.values.forEach((controller) => controller.dispose());
    });
  }

  void _addAuditorRecommendation() {
    setState(() {
      _auditorRecommendationControllers.add({
        'description': TextEditingController(),
        'amount': TextEditingController(text: '0.0'),
        'reason': TextEditingController(),
      });
    });
  }

  void _removeAuditorRecommendation(int index) {
    setState(() {
      final controllers = _auditorRecommendationControllers.removeAt(index);
      controllers.values.forEach((controller) => controller.dispose());
    });
  }

  @override
  void dispose() {
    // Dispose of controllers
    _gstinController.dispose();
    _financialYearController.dispose();
    _legalNameController.dispose();
    _tradeNameController.dispose();
    
    _turnoverAsPerAuditedFinancialStatementsController.dispose();
    _turnoverAsPerAnnualReturnController.dispose();
    _unReconciledController.dispose();
    
    // Dispose reconciliation item controllers
    for (var controllers in _reconciliationItemsControllers) {
      controllers.values.forEach((controller) => controller.dispose());
    }
    
    // Dispose auditor recommendation controllers
    for (var controllers in _auditorRecommendationControllers) {
      controllers.values.forEach((controller) => controller.dispose());
    }
    
    _taxPayableAsPerReconciliationController.dispose();
    _taxPaidAsPerAnnualReturnController.dispose();
    _differentialTaxPayableController.dispose();
    _interestPayableController.dispose();
    
    _auditorDetailsController.dispose();
    _certificationDetailsController.dispose();
    
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Create reconciliation items list
      List<GSTR9CReconciliationItem> reconciliationItems = [];
      for (var controllers in _reconciliationItemsControllers) {
        final description = controllers['description']!.text;
        final amount = double.tryParse(controllers['amount']!.text) ?? 0.0;
        final reason = controllers['reason']!.text;
        
        if (description.isNotEmpty || amount > 0 || reason.isNotEmpty) {
          reconciliationItems.add(GSTR9CReconciliationItem(
            description: description,
            amount: amount,
            reason: reason,
          ));
        }
      }

      // Create auditor recommendations list
      List<GSTR9CAuditorRecommendationItem> auditorRecommendations = [];
      for (var controllers in _auditorRecommendationControllers) {
        final description = controllers['description']!.text;
        final amount = double.tryParse(controllers['amount']!.text) ?? 0.0;
        final reason = controllers['reason']!.text;
        
        if (description.isNotEmpty || amount > 0 || reason.isNotEmpty) {
          auditorRecommendations.add(GSTR9CAuditorRecommendationItem(
            description: description,
            amount: amount,
            reason: reason,
          ));
        }
      }

      // Update GSTR9C data with form values
      final updatedGSTR9C = GSTR9C(
        gstin: _gstinController.text,
        financialYear: _financialYearController.text,
        legalName: _legalNameController.text,
        tradeName: _tradeNameController.text,
        reconciliation: GSTR9CReconciliation(
          turnoverAsPerAuditedFinancialStatements: 
              double.parse(_turnoverAsPerAuditedFinancialStatementsController.text),
          turnoverAsPerAnnualReturn: 
              double.parse(_turnoverAsPerAnnualReturnController.text),
          unReconciled: 
              double.parse(_unReconciledController.text),
          reconciliationItems: reconciliationItems,
        ),
        auditorRecommendation: GSTR9CAuditorRecommendation(
          recommendations: auditorRecommendations,
        ),
        taxPayable: GSTR9CTaxPayable(
          taxPayableAsPerReconciliation: 
              double.parse(_taxPayableAsPerReconciliationController.text),
          taxPaidAsPerAnnualReturn: 
              double.parse(_taxPaidAsPerAnnualReturnController.text),
          differentialTaxPayable: 
              double.parse(_differentialTaxPayableController.text),
          interestPayable: 
              double.parse(_interestPayableController.text),
        ),
        auditorDetails: _auditorDetailsController.text,
        certificationDetails: _certificationDetailsController.text,
      );

      // Call the onSave callback
      widget.onSave(updatedGSTR9C);

      setState(() {
        _isLoading = false;
      });
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
              _buildReconciliationSection(),
              const SizedBox(height: 20),
              _buildAuditorRecommendationSection(),
              const SizedBox(height: 20),
              _buildTaxPayableSection(),
              const SizedBox(height: 20),
              _buildAuditorDetailsSection(),
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

  Widget _buildReconciliationSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reconciliation of Turnover',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _turnoverAsPerAuditedFinancialStatementsController,
              decoration: const InputDecoration(
                labelText: 'Turnover as per Audited Financial Statements',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                return null;
              },
              onChanged: (value) {
                final turnoverAsPerAudited = double.tryParse(value) ?? 0.0;
                final turnoverAsPerAnnual = double.tryParse(_turnoverAsPerAnnualReturnController.text) ?? 0.0;
                final unReconciled = turnoverAsPerAudited - turnoverAsPerAnnual;
                _unReconciledController.text = unReconciled.toStringAsFixed(2);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _turnoverAsPerAnnualReturnController,
              decoration: const InputDecoration(
                labelText: 'Turnover as per Annual Return (GSTR-9)',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                return null;
              },
              onChanged: (value) {
                final turnoverAsPerAudited = double.tryParse(_turnoverAsPerAuditedFinancialStatementsController.text) ?? 0.0;
                final turnoverAsPerAnnual = double.tryParse(value) ?? 0.0;
                final unReconciled = turnoverAsPerAudited - turnoverAsPerAnnual;
                _unReconciledController.text = unReconciled.toStringAsFixed(2);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _unReconciledController,
              decoration: const InputDecoration(
                labelText: 'Un-reconciled Turnover',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              readOnly: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),
            const Text(
              'Reconciliation Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reconciliationItemsControllers.length,
              itemBuilder: (context, index) {
                return _buildReconciliationItemForm(index);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _addReconciliationItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Reconciliation Item'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReconciliationItemForm(int index) {
    final controllers = _reconciliationItemsControllers[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_reconciliationItemsControllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeReconciliationItem(index),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controllers['description'],
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((controllers['amount']!.text != '0.0' && controllers['amount']!.text != '0') && 
                    (value == null || value.isEmpty)) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controllers['amount'],
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controllers['reason'],
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditorRecommendationSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Auditor\'s Recommendation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _auditorRecommendationControllers.length,
              itemBuilder: (context, index) {
                return _buildAuditorRecommendationForm(index);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _addAuditorRecommendation,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Recommendation'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditorRecommendationForm(int index) {
    final controllers = _auditorRecommendationControllers[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommendation ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_auditorRecommendationControllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeAuditorRecommendation(index),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controllers['description'],
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((controllers['amount']!.text != '0.0' && controllers['amount']!.text != '0') && 
                    (value == null || value.isEmpty)) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controllers['amount'],
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controllers['reason'],
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxPayableSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _taxPayableAsPerReconciliationController,
              decoration: const InputDecoration(
                labelText: 'Tax Payable as per Reconciliation',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                return null;
              },
              onChanged: (value) {
                final taxPayable = double.tryParse(value) ?? 0.0;
                final taxPaid = double.tryParse(_taxPaidAsPerAnnualReturnController.text) ?? 0.0;
                final differential = taxPayable - taxPaid;
                _differentialTaxPayableController.text = differential.toStringAsFixed(2);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taxPaidAsPerAnnualReturnController,
              decoration: const InputDecoration(
                labelText: 'Tax Paid as per Annual Return',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                return null;
              },
              onChanged: (value) {
                final taxPayable = double.tryParse(_taxPayableAsPerReconciliationController.text) ?? 0.0;
                final taxPaid = double.tryParse(value) ?? 0.0;
                final differential = taxPayable - taxPaid;
                _differentialTaxPayableController.text = differential.toStringAsFixed(2);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _differentialTaxPayableController,
              decoration: const InputDecoration(
                labelText: 'Differential Tax Payable',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              readOnly: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _interestPayableController,
              decoration: const InputDecoration(
                labelText: 'Interest Payable',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditorDetailsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Auditor Details & Certification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _auditorDetailsController,
              decoration: const InputDecoration(
                labelText: 'Auditor Details',
                border: OutlineInputBorder(),
                hintText: 'Name, Membership No., Firm Registration No.',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter auditor details';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _certificationDetailsController,
              decoration: const InputDecoration(
                labelText: 'Certification Details',
                border: OutlineInputBorder(),
                hintText: 'Certification text, place, date, etc.',
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter certification details';
                }
                return null;
              },
            ),
          ],
        ),
      ),
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
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Save GSTR-9C Data', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
