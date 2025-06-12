import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/gst_returns/qrmp_model.dart';
import 'package:flutter_invoice_app/services/qrmp_service.dart';
import 'package:flutter_invoice_app/utils/gstin_validator.dart';

class QRMPSchemeWidget extends StatefulWidget {
  const QRMPSchemeWidget({super.key});

  @override
  State<QRMPSchemeWidget> createState() => _QRMPSchemeWidgetState();
}

class _QRMPSchemeWidgetState extends State<QRMPSchemeWidget> {
  final _formKey = GlobalKey<FormState>();
  final _gstinController = TextEditingController();
  final _qrmpService = QRMPService(useDemo: true);
  
  String _selectedFinancialYear = '2023-24';
  String _selectedQuarter = 'Q1';
  
  QRMPScheme? _qrmpScheme;
  bool _isLoading = false;
  String _errorMessage = '';
  
  final List<String> _financialYears = const [
    '2023-24', '2022-23', '2021-22', '2020-21', '2019-20'
  ];
  
  final List<String> _quarters = const ['Q1', 'Q2', 'Q3', 'Q4'];

  @override
  void initState() {
    super.initState();
    _gstinController.text = '27AADCB2230M1ZT'; // Demo GSTIN
  }

  @override
  void dispose() {
    _gstinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildForm(),
          const SizedBox(height: 16),
          
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_errorMessage.isNotEmpty)
            _buildErrorMessage()
          else if (_qrmpScheme != null)
            _buildQRMPSchemeDetails(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QRMP Scheme',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              // GSTIN field
              TextFormField(
                controller: _gstinController,
                decoration: const InputDecoration(
                  labelText: 'GSTIN',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your 15-digit GSTIN',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter GSTIN';
                  }
                  
                  final validationResult = GstinValidator.validate(value);
                  if (!validationResult.isValid) {
                    return validationResult.message;
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Financial Year dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Financial Year',
                  border: OutlineInputBorder(),
                ),
                value: _selectedFinancialYear,
                items: _financialYears.map((year) {
                  return DropdownMenuItem<String>(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFinancialYear = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Quarter dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Quarter',
                  border: OutlineInputBorder(),
                ),
                value: _selectedQuarter,
                items: _quarters.map((quarter) {
                  return DropdownMenuItem<String>(
                    value: quarter,
                    child: Text(_getQuarterLabel(quarter)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedQuarter = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _fetchQRMPScheme,
                    icon: const Icon(Icons.download),
                    label: const Text('Fetch Data'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isLoading || _qrmpScheme == null ? null : _exportToJson,
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export JSON'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _importFromJson,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Import JSON'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _errorMessage = '';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQRMPSchemeDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QRMP Scheme Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                // Basic details
                _buildInfoRow('GSTIN', _qrmpScheme!.gstin),
                _buildInfoRow('Financial Year', _qrmpScheme!.financialYear),
                _buildInfoRow('Quarter', _getQuarterLabel(_qrmpScheme!.quarter)),
                _buildInfoRow('Status', _qrmpScheme!.status, isStatus: true),
                
                if (_qrmpScheme!.filingDate != null)
                  _buildInfoRow('Filing Date', _formatDate(_qrmpScheme!.filingDate!)),
                
                const Divider(height: 32),
                
                // Monthly payments
                Text(
                  'Monthly Payments',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                
                ..._qrmpScheme!.monthlyPayments.map(_buildMonthlyPaymentCard),
                
                const Divider(height: 32),
                
                // Quarterly return
                Text(
                  'Quarterly Return',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                
                _buildQuarterlyReturnCard(_qrmpScheme!.quarterlyReturn),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    Color statusColor = Colors.blue;
    IconData statusIcon = Icons.info;
    
    if (isStatus) {
      switch (value.toUpperCase()) {
        case 'COMPLETED':
        case 'FILED':
        case 'PAID':
          statusColor = Colors.green;
          statusIcon = Icons.check_circle;
          break;
        case 'PENDING':
          statusColor = Colors.orange;
          statusIcon = Icons.warning;
          break;
        case 'NOT FILED':
        case 'NOT PAID':
          statusColor = Colors.red;
          statusIcon = Icons.error;
          break;
        default:
          statusColor = Colors.blue;
          statusIcon = Icons.info;
      }
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 16, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildMonthlyPaymentCard(QRMPMonthlyPayment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  payment.month,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    payment.status,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Text('Payment Method: ${payment.paymentMethod}'),
            
            if (payment.paymentMethod == 'Fixed Sum')
              Text('Fixed Sum Amount: ₹${payment.fixedSumAmount?.toStringAsFixed(2)}')
            else if (payment.selfAssessment != null) ...[
              const SizedBox(height: 8),
              Text('Outward Supplies: ₹${payment.selfAssessment!.outwardSupplies.toStringAsFixed(2)}'),
              Text('IGST: ₹${payment.selfAssessment!.igstAmount.toStringAsFixed(2)}'),
              Text('CGST: ₹${payment.selfAssessment!.cgstAmount.toStringAsFixed(2)}'),
              Text('SGST: ₹${payment.selfAssessment!.sgstAmount.toStringAsFixed(2)}'),
              Text('Total Tax: ₹${payment.selfAssessment!.totalTaxPayable.toStringAsFixed(2)}'),
            ],
            
            const SizedBox(height: 8),
            Text('Challan Number: ${payment.challanNumber}'),
            
            if (payment.paymentDate != null)
              Text('Payment Date: ${_formatDate(payment.paymentDate!)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuarterlyReturnCard(QRMPQuarterlyReturn quarterlyReturn) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(quarterlyReturn.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(quarterlyReturn.status).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    quarterlyReturn.status,
                    style: TextStyle(
                      color: _getStatusColor(quarterlyReturn.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Financial details
            _buildFinancialRow('Total Outward Supplies', quarterlyReturn.totalOutwardSupplies),
            _buildFinancialRow('Total Inward Supplies', quarterlyReturn.totalInwardSupplies),
            const Divider(height: 16),
            _buildFinancialRow('Total IGST', quarterlyReturn.totalIgst),
            _buildFinancialRow('Total CGST', quarterlyReturn.totalCgst),
            _buildFinancialRow('Total SGST', quarterlyReturn.totalSgst),
            _buildFinancialRow('Total Cess', quarterlyReturn.totalCess),
            const Divider(height: 16),
            _buildFinancialRow('Total Tax Paid', quarterlyReturn.totalTaxPaid),
            _buildFinancialRow('Balance Tax Payable', quarterlyReturn.balanceTaxPayable, isHighlighted: true),
            
            if (quarterlyReturn.filingDate != null) ...[
              const SizedBox(height: 16),
              Text('Filing Date: ${_formatDate(quarterlyReturn.filingDate!)}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, double value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'FILED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'NOT FILED':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getQuarterLabel(String quarter) {
    switch (quarter) {
      case 'Q1':
        return 'Q1 (Apr-Jun)';
      case 'Q2':
        return 'Q2 (Jul-Sep)';
      case 'Q3':
        return 'Q3 (Oct-Dec)';
      case 'Q4':
        return 'Q4 (Jan-Mar)';
      default:
        return quarter;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Future<void> _fetchQRMPScheme() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _qrmpScheme = null;
    });
    
    try {
      final qrmpScheme = await _qrmpService.getQRMPScheme(
        _gstinController.text,
        _selectedFinancialYear,
        _selectedQuarter,
      );
      
      setState(() {
        _qrmpScheme = qrmpScheme;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportToJson() async {
    if (_qrmpScheme == null) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final filePath = await _qrmpService.exportToJson(_qrmpScheme!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported to $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importFromJson() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null) {
        final filePath = result.files.single.path!;
        final qrmpScheme = await _qrmpService.importFromJson(filePath);
        
        setState(() {
          _qrmpScheme = qrmpScheme;
          _gstinController.text = qrmpScheme.gstin;
          _selectedFinancialYear = qrmpScheme.financialYear;
          _selectedQuarter = qrmpScheme.quarter;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QRMP data imported successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
