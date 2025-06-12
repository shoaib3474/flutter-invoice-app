import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/payment/payment_transaction_model.dart';
import '../../services/payment/qr_payment_service.dart';
import '../../utils/error_handler.dart';

class QRPaymentWidget extends StatefulWidget {
  const QRPaymentWidget({
    super.key,
    required this.amount,
    required this.description,
    required this.customerName,
    required this.onTransactionCreated,
  });

  final double amount;
  final String description;
  final String customerName;
  final Function(PaymentTransactionModel) onTransactionCreated;

  @override
  State<QRPaymentWidget> createState() => _QRPaymentWidgetState();
}

class _QRPaymentWidgetState extends State<QRPaymentWidget> {
  final QRPaymentService _qrPaymentService = QRPaymentService();
  final TextEditingController _upiIdController = TextEditingController();
  
  bool _isGenerating = false;
  String? _qrData;
  File? _qrImageFile;
  String? _error;
  PaymentTransactionModel? _transaction;

  @override
  void initState() {
    super.initState();
    _upiIdController.text = 'example@upi'; // Default UPI ID
  }

  Future<void> _generateQRCode() async {
    if (_upiIdController.text.isEmpty) {
      setState(() {
        _error = 'Please enter a UPI ID';
      });
      return;
    }
    
    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      // Generate UPI QR data
      final qrData = _qrPaymentService.generateUpiQrData(
        upiId: _upiIdController.text,
        name: widget.customerName,
        amount: widget.amount,
        transactionNote: widget.description,
      );
      
      // Save QR code image
      final fileName = 'payment_qr_${DateTime.now().millisecondsSinceEpoch}';
      final qrImageFile = await _qrPaymentService.saveQrCodeImage(qrData, fileName);
      
      // Create transaction
      final transaction = await _qrPaymentService.createQrTransaction(
        amount: widget.amount,
        customerName: widget.customerName,
        metadata: {
          'upi_id': _upiIdController.text,
          'qr_file_path': qrImageFile.path,
          'description': widget.description,
        },
      );
      
      setState(() {
        _qrData = qrData;
        _qrImageFile = qrImageFile;
        _transaction = transaction;
      });
      
      // Call the callback
      widget.onTransactionCreated(transaction);
    } catch (e) {
      setState(() {
        _error = 'Failed to generate QR code: ${e.toString()}';
      });
      ErrorHandler.logError('QR Payment Error', e);
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _shareQRCode() async {
    if (_qrImageFile != null) {
      await Share.shareXFiles(
        [XFile(_qrImageFile!.path)],
        text: 'Payment QR Code for ₹${widget.amount.toStringAsFixed(2)}',
      );
    }
  }

  Future<void> _markAsPaid() async {
    if (_transaction != null) {
      try {
        await _qrPaymentService.updateTransactionStatus(_transaction!.transactionId, 'success');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction marked as paid')),
          );
        }
        
        // Refresh the transaction
        final updatedTransaction = await _qrPaymentService.getTransactionById(_transaction!.transactionId);
        if (updatedTransaction != null) {
          setState(() {
            _transaction = updatedTransaction;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update transaction: ${e.toString()}')),
          );
        }
        ErrorHandler.logError('QR Payment Update Error', e);
      }
    }
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Receive Payment via QR Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Payment details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Amount:'),
                      Text(
                        '₹${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Description:'),
                      Expanded(
                        child: Text(
                          widget.description,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // UPI ID
            TextFormField(
              controller: _upiIdController,
              decoration: const InputDecoration(
                labelText: 'UPI ID',
                border: OutlineInputBorder(),
                hintText: 'example@upi',
              ),
              enabled: _qrData == null,
            ),
            const SizedBox(height: 16),
            
            // QR Code
            if (_qrData != null) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: _qrData!,
                        version: QrVersions.auto,
                        size: 200,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scan to pay ₹${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'UPI ID: ${_upiIdController.text}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Share and Mark as Paid buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _shareQRCode,
                    icon: const Icon(Icons.share),
                    label: const Text('Share QR'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _transaction?.status == 'success' ? null : _markAsPaid,
                    icon: const Icon(Icons.check_circle),
                    label: Text(_transaction?.status == 'success' ? 'Paid' : 'Mark as Paid'),
                  ),
                ],
              ),
            ],
            
            // Error message
            if (_error != null) ...[
              const SizedBox(height: 16),
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
            ],
            
            // Generate Button
            if (_qrData == null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateQRCode,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(_isGenerating ? 'Generating...' : 'Generate QR Code'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
