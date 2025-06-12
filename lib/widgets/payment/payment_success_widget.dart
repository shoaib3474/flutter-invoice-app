import 'package:flutter/material.dart';
import '../../models/payment/stripe_payment_model.dart';
import '../../models/invoice/invoice_model.dart';

class PaymentSuccessWidget extends StatelessWidget {
  final StripePaymentResult paymentResult;
  final InvoiceModel invoice;
  final VoidCallback onDone;

  const PaymentSuccessWidget({
    super.key,
    required this.paymentResult,
    required this.invoice,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
          const SizedBox(height: 16),
          const Text(
            'Payment Successful!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Payment ID: ${paymentResult.paymentIntentId}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onDone,
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
