import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../models/payment/payment_transaction_model.dart';
import '../../services/payment/razorpay_service.dart';
import '../../utils/error_handler.dart';

class RazorpayPaymentWidget extends StatefulWidget {
  const RazorpayPaymentWidget({
    super.key,
    required this.amount,
    required this.description,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.onPaymentSuccess,
  });

  final double amount;
  final String description;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final Function(PaymentTransactionModel) onPaymentSuccess;

  @override
  State<RazorpayPaymentWidget> createState() => _RazorpayPaymentWidgetState();
}

class _RazorpayPaymentWidgetState extends State<RazorpayPaymentWidget> {
  final RazorpayService _razorpayService = RazorpayService();
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpayService.initialize(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onWalletSelected: _handleExternalWallet,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // Create transaction from response
      final transaction = _razorpayService.createTransactionFromResponse(
        response,
        widget.amount,
        widget.customerName,
        widget.customerEmail,
        widget.customerPhone,
      );
      
      // Save transaction
      await _razorpayService.saveTransaction(transaction);
      
      // Call the callback
      widget.onPaymentSuccess(transaction);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to process payment: ${e.toString()}';
      });
      ErrorHandler.logError('Razorpay Payment Error', e);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _error = 'Payment failed: ${response.message ?? 'Unknown error'}';
      _isProcessing = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('External wallet selected: ${response.walletName}')),
      );
    }
  }

  Future<void> _startPayment() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // Generate a unique order ID
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create payment options
      final options = _razorpayService.createPaymentOptions(
        orderId: orderId,
        amount: widget.amount,
        description: widget.description,
        name: widget.customerName,
        email: widget.customerEmail,
        contact: widget.customerPhone,
      );
      
      // Start payment
      await _razorpayService.startPayment(options);
    } catch (e) {
      setState(() {
        _error = 'Failed to start payment: ${e.toString()}';
        _isProcessing = false;
      });
      ErrorHandler.logError('Razorpay Start Payment Error', e);
    }
  }

  @override
  void dispose() {
    _razorpayService.dispose();
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
              'Pay with Razorpay',
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Name:'),
                      Text(
                        widget.customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
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
            
            // Pay Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _startPayment,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(_isProcessing ? 'Processing...' : 'Pay Now'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
