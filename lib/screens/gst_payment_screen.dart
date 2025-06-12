import 'package:flutter/material.dart';

import '../models/payment/payment_transaction_model.dart';
import '../widgets/payment/gst_payment_widget.dart';

class GSTPaymentScreen extends StatefulWidget {
  final String gstin;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final String returnPeriod;
  final String returnType;

  const GSTPaymentScreen({
    Key? key,
    required this.gstin,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
    required this.returnPeriod,
    required this.returnType,
  }) : super(key: key);

  @override
  _GSTPaymentScreenState createState() => _GSTPaymentScreenState();
}

class _GSTPaymentScreenState extends State<GSTPaymentScreen> {
  PaymentTransactionModel? _transaction;

  void _handlePaymentComplete(PaymentTransactionModel transaction) {
    setState(() {
      _transaction = transaction;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_transaction == null)
              GSTPaymentWidget(
                gstin: widget.gstin,
                cgstAmount: widget.cgstAmount,
                sgstAmount: widget.sgstAmount,
                igstAmount: widget.igstAmount,
                cessAmount: widget.cessAmount,
                returnPeriod: widget.returnPeriod,
                returnType: widget.returnType,
                onPaymentComplete: _handlePaymentComplete,
              )
            else
              Card(
                elevation: 2,
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Successful',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Transaction ID: ${_transaction!.transactionId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Challan ID: ${_transaction!.challanId}'),
                      const SizedBox(height: 8),
                      Text('Amount: ₹${_transaction!.amount.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      Text('Payment Method: ${_transaction!.paymentMethod}'),
                      const SizedBox(height: 8),
                      Text('Payment ID: ${_transaction!.paymentId}'),
                      const SizedBox(height: 8),
                      Text('Status: ${_transaction!.status}'),
                      const SizedBox(height: 8),
                      Text('Timestamp: ${_transaction!.timestamp.toString()}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Back to Dashboard'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
