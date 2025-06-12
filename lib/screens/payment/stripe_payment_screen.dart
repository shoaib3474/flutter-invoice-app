import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../services/payment/stripe_payment_service.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/payment/stripe_payment_model.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/payment/payment_form_widget.dart';
import '../../widgets/payment/payment_success_widget.dart';

class StripePaymentScreen extends StatefulWidget {
  final Invoice invoice;
  final String? customerEmail;

  const StripePaymentScreen({
    Key? key,
    required this.invoice,
    this.customerEmail,
  }) : super(key: key);

  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  final StripePaymentService _stripeService = StripePaymentService();
  
  StripePaymentIntent? _paymentIntent;
  StripePaymentResult? _paymentResult;
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeStripe();
  }

  Future<void> _initializeStripe() async {
    setState(() => _isLoading = true);
    
    try {
      await _stripeService.initialize();
      await _createPaymentIntent();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize payment: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createPaymentIntent() async {
    try {
      final paymentIntent = await _stripeService.createPaymentIntent(
        invoice: widget.invoice,
        currency: 'INR',
        metadata: {
          'customer_email': widget.customerEmail ?? '',
          'app_name': 'Flutter Invoice App',
        },
      );
      
      setState(() {
        _paymentIntent = paymentIntent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create payment intent: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.purple,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(),
            SizedBox(height: 16),
            Text('Setting up payment...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_paymentResult != null) {
      return PaymentSuccessWidget(
        paymentResult: _paymentResult!,
        invoice: widget.invoice,
        onDone: () => Navigator.pop(context, _paymentResult),
      );
    }

    if (_paymentIntent != null) {
      return PaymentFormWidget(
        invoice: widget.invoice,
        paymentIntent: _paymentIntent!,
        onPaymentComplete: _handlePaymentComplete,
        onPaymentError: _handlePaymentError,
      );
    }

    return const Center(
      child: Text('Unable to load payment form'),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _retryPayment,
                  child: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handlePaymentComplete(StripePaymentResult result) {
    setState(() {
      _paymentResult = result;
    });
  }

  void _handlePaymentError(String error) {
    setState(() {
      _errorMessage = error;
    });
  }

  void _retryPayment() {
    setState(() {
      _errorMessage = null;
      _paymentIntent = null;
      _paymentResult = null;
    });
    _initializeStripe();
  }
}
