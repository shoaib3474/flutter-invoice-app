import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/payment/stripe_payment_model.dart';
import '../../services/payment/stripe_payment_service.dart';
import '../common/loading_indicator.dart';

// Import alias to avoid conflict between Flutter Card and Stripe Card
import 'package:flutter/material.dart' as material;

class PaymentFormWidget extends StatefulWidget {
  const PaymentFormWidget({
    super.key,
    required this.invoice,
    required this.paymentIntent,
    required this.onPaymentComplete,
    required this.onPaymentError,
  });

  final InvoiceModel invoice;
  final StripePaymentIntent paymentIntent;
  final Function(StripePaymentResult) onPaymentComplete;
  final Function(String) onPaymentError;

  @override
  State<PaymentFormWidget> createState() => _PaymentFormWidgetState();
}

class _PaymentFormWidgetState extends State<PaymentFormWidget> {
  final StripePaymentService _stripeService = StripePaymentService();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'IN');

  bool _isProcessing = false;
  bool _saveCard = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill customer information if available
    _nameController.text = widget.invoice.customerName;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInvoiceSummary(),
            const SizedBox(height: 24),
            _buildPaymentForm(),
            const SizedBox(height: 24),
            _buildPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceSummary() {
    return material.Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Invoice Number:', widget.invoice.invoiceNumber),
            _buildSummaryRow('Customer:', widget.invoice.customerName),
            _buildSummaryRow('Date:', _formatDate(widget.invoice.invoiceDate)),
            const Divider(height: 20),
            _buildSummaryRow(
                'Subtotal:', '₹${widget.invoice.subtotal.toStringAsFixed(2)}'),
            if (widget.invoice.cgstTotal > 0)
              _buildSummaryRow(
                  'CGST:', '₹${widget.invoice.cgstTotal.toStringAsFixed(2)}'),
            if (widget.invoice.sgstTotal > 0)
              _buildSummaryRow(
                  'SGST:', '₹${widget.invoice.sgstTotal.toStringAsFixed(2)}'),
            if (widget.invoice.igstTotal > 0)
              _buildSummaryRow(
                  'IGST:', '₹${widget.invoice.igstTotal.toStringAsFixed(2)}'),
            if (widget.invoice.cessTotal > 0)
              _buildSummaryRow(
                  'Cess:', '₹${widget.invoice.cessTotal.toStringAsFixed(2)}'),
            const Divider(height: 20),
            _buildSummaryRow(
              'Total Amount:',
              '₹${widget.invoice.grandTotal.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.green.shade700 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return material.Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Card Element
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CardField(
                onCardChanged: (card) {
                  // Handle card changes if needed
                },
                decoration: const InputDecoration(
                  labelText: 'Card Information',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Billing Information
            const Text(
              'Billing Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your city';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Postal Code',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter postal code';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'Country',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your country';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CheckboxListTile(
              title: const Text('Save card for future payments'),
              value: _saveCard,
              onChanged: (value) {
                setState(() {
                  _saveCard = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: _isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Processing Payment...'),
                ],
              )
            : Text('Pay ₹${widget.invoice.grandTotal.toStringAsFixed(2)}'),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final billingDetails = BillingDetails(
        email: _emailController.text,
        name: _nameController.text,
        address: Address(
          line1: _addressController.text,
          line2: '', // Required parameter
          city: _cityController.text,
          state: '', // Required parameter
          postalCode: _postalCodeController.text,
          country: _countryController.text,
        ),
      );

      final result = await _stripeService.processPayment(
        paymentIntent: widget.paymentIntent,
        billingDetails: billingDetails,
      );

      widget.onPaymentComplete(result);
    } catch (e) {
      widget.onPaymentError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
