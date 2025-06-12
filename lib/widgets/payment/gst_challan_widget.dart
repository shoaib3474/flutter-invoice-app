import 'package:flutter/material.dart';
import '../../models/payment/gst_challan_model.dart';
import '../../services/payment/gst_challan_service.dart';
import '../../utils/error_handler.dart';

class GSTChallanWidget extends StatefulWidget {
  final String gstin;
  final Function(GSTChallanModel) onChallanGenerated;

  const GSTChallanWidget({
    Key? key,
    required this.gstin,
    required this.onChallanGenerated,
  }) : super(key: key);

  @override
  _GSTChallanWidgetState createState() => _GSTChallanWidgetState();
}

class _GSTChallanWidgetState extends State<GSTChallanWidget> {
  final GSTChallanService _gstChallanService = GSTChallanService();
  final _formKey = GlobalKey<FormState>();
  
  double _cgstAmount = 0;
  double _sgstAmount = 0;
  double _igstAmount = 0;
  double _cessAmount = 0;
  String _bankName = '';
  String _bankBranch = '';
  String _paymentMode = 'Online';
  
  bool _isGenerating = false;
  String? _error;

  double get _totalAmount => _cgstAmount + _sgstAmount + _igstAmount + _cessAmount;

  Future<void> _generateChallan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      final challan = await _gstChallanService.generateChallan(
        gstin: widget.gstin,
        cgstAmount: _cgstAmount,
        sgstAmount: _sgstAmount,
        igstAmount: _igstAmount,
        cessAmount: _cessAmount,
        bankName: _bankName,
        bankBranch: _bankBranch,
        paymentMode: _paymentMode,
      );
      
      widget.onChallanGenerated(challan);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GST challan generated successfully')),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to generate challan: ${e.toString()}';
      });
      ErrorHandler.logError('GST Challan Generation Error', e);
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Generate GST Challan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // GSTIN
              TextFormField(
                initialValue: widget.gstin,
                decoration: const InputDecoration(
                  labelText: 'GSTIN',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              
              // CGST Amount
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'CGST Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CGST amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _cgstAmount = double.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // SGST Amount
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'SGST Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter SGST amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _sgstAmount = double.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // IGST Amount
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'IGST Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter IGST amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _igstAmount = double.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Cess Amount
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Cess Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Cess amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _cessAmount = double.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Total Amount
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${_totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Bank Name
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bank name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _bankName = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Bank Branch
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Bank Branch',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bank branch';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _bankBranch = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Payment Mode
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Payment Mode',
                  border: OutlineInputBorder(),
                ),
                value: _paymentMode,
                items: const [
                  DropdownMenuItem(
                    value: 'Online',
                    child: Text('Online'),
                  ),
                  DropdownMenuItem(
                    value: 'Cash',
                    child: Text('Cash'),
                  ),
                  DropdownMenuItem(
                    value: 'Cheque',
                    child: Text('Cheque'),
                  ),
                  DropdownMenuItem(
                    value: 'NEFT/RTGS',
                    child: Text('NEFT/RTGS'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _paymentMode = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // Error message
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Generate Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateChallan,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(_isGenerating ? 'Generating...' : 'Generate Challan'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
