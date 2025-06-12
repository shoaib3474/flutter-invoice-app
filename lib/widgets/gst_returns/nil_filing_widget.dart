import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/gst/nil_filing_service.dart';
import '../../models/gst_returns/nil_filing_model.dart';
import '../../services/logger_service.dart';

class NilFilingWidget extends StatefulWidget {
  final String returnType; // 'GSTR1' or 'GSTR4'
  final String? prefilledGstin;
  
  const NilFilingWidget({
    super.key,
    required this.returnType,
    this.prefilledGstin,
  });

  @override
  State<NilFilingWidget> createState() => _NilFilingWidgetState();
}

class _NilFilingWidgetState extends State<NilFilingWidget> {
  final _formKey = GlobalKey<FormState>();
  final _gstinController = TextEditingController();
  final _mobileController = TextEditingController();
  final _periodController = TextEditingController();
  final _quarterController = TextEditingController();
  final _fyController = TextEditingController();
  
  final NilFilingService _nilFilingService = NilFilingService();
  final LoggerService _logger = LoggerService();
  
  bool _isLoading = false;
  NilFilingResult? _lastResult;
  
  @override
  void initState() {
    super.initState();
    if (widget.prefilledGstin != null) {
      _gstinController.text = widget.prefilledGstin!;
    }
    
    // Set current period defaults
    final now = DateTime.now();
    if (widget.returnType == 'GSTR1') {
      _periodController.text = '${now.month.toString().padLeft(2, '0')}${now.year}';
    } else {
      _quarterController.text = _getCurrentQuarter(now);
      _fyController.text = _getCurrentFinancialYear(now);
    }
  }
  
  @override
  void dispose() {
    _gstinController.dispose();
    _mobileController.dispose();
    _periodController.dispose();
    _quarterController.dispose();
    _fyController.dispose();
    super.dispose();
  }
  
  String _getCurrentQuarter(DateTime date) {
    final month = date.month;
    if (month >= 4 && month <= 6) return '1';
    if (month >= 7 && month <= 9) return '2';
    if (month >= 10 && month <= 12) return '3';
    return '4';
  }
  
  String _getCurrentFinancialYear(DateTime date) {
    final year = date.year;
    return date.month >= 4 ? year.toString() : (year - 1).toString();
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'File ${widget.returnType} NIL Return via SMS',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'File your ${widget.returnType} return as NIL using SMS. No internet required!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // GSTIN Field
              TextFormField(
                controller: _gstinController,
                decoration: const InputDecoration(
                  labelText: 'GSTIN',
                  hintText: 'Enter 15-digit GSTIN',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(15),
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                ],
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
              
              // Mobile Number Field
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Registered Mobile Number',
                  hintText: 'Enter mobile number registered with GST',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter mobile number';
                  }
                  if (value.length != 10) {
                    return 'Mobile number must be 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Period Fields
              if (widget.returnType == 'GSTR1') ...[
                TextFormField(
                  controller: _periodController,
                  decoration: const InputDecoration(
                    labelText: 'Period (MMYYYY)',
                    hintText: 'e.g., 032024 for March 2024',
                    prefixIcon: Icon(Icons.calendar_month),
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter period';
                    }
                    if (value.length != 6) {
                      return 'Period must be in MMYYYY format';
                    }
                    return null;
                  },
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quarterController,
                        decoration: const InputDecoration(
                          labelText: 'Quarter',
                          hintText: '1, 2, 3, or 4',
                          prefixIcon: Icon(Icons.calendar_view_month),
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.allow(RegExp(r'[1-4]')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter quarter';
                          }
                          final quarter = int.tryParse(value);
                          if (quarter == null || quarter < 1 || quarter > 4) {
                            return 'Quarter must be 1-4';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _fyController,
                        decoration: const InputDecoration(
                          labelText: 'Financial Year',
                          hintText: 'e.g., 2024',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(4),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter FY';
                          }
                          if (value.length != 4) {
                            return 'Enter 4-digit year';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitNilFiling,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sms),
                  label: Text(_isLoading 
                      ? 'Sending SMS...' 
                      : 'File NIL Return via SMS'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              // Result Display
              if (_lastResult != null) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _lastResult!.success 
                        ? Colors.green[50] 
                        : Colors.red[50],
                    border: Border.all(
                      color: _lastResult!.success 
                          ? Colors.green 
                          : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _lastResult!.success 
                                ? Icons.check_circle 
                                : Icons.error,
                            color: _lastResult!.success 
                                ? Colors.green 
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _lastResult!.success ? 'Success' : 'Error',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _lastResult!.success 
                                  ? Colors.green[800] 
                                  : Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_lastResult!.message),
                      if (_lastResult!.acknowledgmentNumber != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Acknowledgment: ${_lastResult!.acknowledgmentNumber}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                      if (_lastResult!.smsText != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'SMS Sent: ${_lastResult!.smsText}',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[800]),
                        const SizedBox(width: 8),
                        Text(
                          'SMS Filing Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• SMS will be sent to GST Portal (567676)\n'
                      '• Ensure mobile number is registered with GST\n'
                      '• You will receive confirmation SMS\n'
                      '• Standard SMS charges apply\n'
                      '• Filing is valid only for NIL returns',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _submitNilFiling() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _lastResult = null;
    });
    
    try {
      NilFilingResult result;
      
      if (widget.returnType == 'GSTR1') {
        result = await _nilFilingService.fileGSTR1Nil(
          gstin: _gstinController.text.trim(),
          period: _periodController.text.trim(),
          mobileNumber: _mobileController.text.trim(),
        );
      } else {
        result = await _nilFilingService.fileGSTR4Nil(
          gstin: _gstinController.text.trim(),
          quarter: _quarterController.text.trim(),
          financialYear: _fyController.text.trim(),
          mobileNumber: _mobileController.text.trim(),
        );
      }
      
      setState(() {
        _lastResult = result;
      });
      
      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.returnType} NIL return filed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      _logger.error('Error in NIL filing: $e');
      setState(() {
        _lastResult = NilFilingResult(
          success: false,
          message: 'Error: $e',
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
