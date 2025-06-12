import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/payment/gst_challan_model.dart';
import '../../models/payment/payment_transaction_model.dart';
import '../../services/payment/payment_service.dart';
import '../../utils/api_exception.dart';

class GSTPaymentWidget extends StatefulWidget {
  const GSTPaymentWidget({
    super.key,
    required this.gstin,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
    required this.returnPeriod,
    required this.returnType,
    required this.onPaymentComplete,
  });

  final String gstin;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final String returnPeriod;
  final String returnType;
  final Function(PaymentTransactionModel) onPaymentComplete;

  @override
  State<GSTPaymentWidget> createState() => _GSTPaymentWidgetState();
}

class _GSTPaymentWidgetState extends State<GSTPaymentWidget> {
  final PaymentService _paymentService = PaymentService();
  
  bool _isLoading = false;
  String? _errorMessage;
  GSTChallanModel? _challan;
  String? _qrCodeData;
  String _selectedPaymentMethod = 'Razorpay';
  
  @override
  void initState() {
    super.initState();
    _generateChallan();
  }
  
  Future<void> _generateChallan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final challan = await _paymentService.generateChallan(
        gstin: widget.gstin,
        cgstAmount: widget.cgstAmount,
        sgstAmount: widget.sgstAmount,
        igstAmount: widget.igstAmount,
        cessAmount: widget.cessAmount,
        returnPeriod: widget.returnPeriod,
        returnType: widget.returnType,
      );
      
      setState(() {
        _challan = challan;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e is ApiException ? e.message : 'Failed to generate challan';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _generateQRCode() async {
    if (_challan == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final qrCodeData = await _paymentService.generatePaymentQRCode(
        challan: _challan!,
        upiId: 'example@upi', // Replace with actual UPI ID
      );
      
      setState(() {
        _qrCodeData = qrCodeData;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e is ApiException ? e.message : 'Failed to generate QR code';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _processRazorpayPayment() async {
    if (_challan == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // In a real app, you would integrate with the Razorpay SDK
      // This is a simplified implementation
      
      final transaction = await _paymentService.processRazorpayPayment(
        challan: _challan!,
        razorpayKeyId: 'rzp_test_1234567890', // Replace with actual key
        razorpayOrderId: 'order_1234567890', // Replace with actual order ID
        paymentId: 'pay_1234567890', // Replace with actual payment ID
        signature: 'sig_1234567890', // Replace with actual signature
      );
      
      widget.onPaymentComplete(transaction);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e is ApiException ? e.message : 'Failed to process payment';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _verifyQRCodePayment() async {
    if (_challan == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final transaction = await _paymentService.verifyQRCodePayment(
        challan: _challan!,
        referenceId: 'ref_1234567890', // Replace with actual reference ID
      );
      
      widget.onPaymentComplete(transaction);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment verified successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e is ApiException ? e.message : 'Failed to verify payment';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GST Payment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                ),
              )
            else if (_challan != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Challan ID: ${_challan!.challanId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('GSTIN: ${_challan!.gstin}'),
                  const SizedBox(height: 8),
                  Text('Return Period: ${_challan!.returnPeriod}'),
                  const SizedBox(height: 8),
                  Text('Return Type: ${_challan!.returnType}'),
                  const SizedBox(height: 8),
                  Text('CGST Amount: ₹${_challan!.cgstAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Text('SGST Amount: ₹${_challan!.sgstAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Text('IGST Amount: ₹${_challan!.igstAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Text('Cess Amount: ₹${_challan!.cessAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Text(
                    'Total Amount: ₹${_challan!.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Valid Until: ${_challan!.validUntil.toString().substring(0, 10)}',
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Payment Method:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedPaymentMethod,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPaymentMethod = newValue;
                          _qrCodeData = null;
                        });
                      }
                    },
                    items: <String>['Razorpay', 'QR Code']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedPaymentMethod == 'Razorpay')
                    ElevatedButton(
                      onPressed: _processRazorpayPayment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Pay with Razorpay'),
                    )
                  else if (_selectedPaymentMethod == 'QR Code')
                    Column(
                      children: [
                        if (_qrCodeData == null)
                          ElevatedButton(
                            onPressed: _generateQRCode,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Generate QR Code'),
                          )
                        else
                          Column(
                            children: [
                              SizedBox(
                                height: 200,
                                width: 200,
                                child: QrImageView(
                                  data: _qrCodeData!,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Scan this QR code with any UPI app to pay',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _verifyQRCodePayment,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Verify Payment'),
                              ),
                            ],
                          ),
                      ],
                    ),
                ],
              )
            else
              const Text('Failed to generate challan. Please try again.'),
          ],
        ),
      ),
    );
  }
}
