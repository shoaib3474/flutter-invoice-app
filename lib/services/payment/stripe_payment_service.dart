import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../logger_service.dart';
import '../../models/payment/stripe_payment_model.dart';
import '../../models/invoice/invoice_model.dart';

class StripePaymentService {
  final LoggerService _logger = LoggerService();
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  static const String _publishableKey = 'pk_test_your_publishable_key_here'; // Replace with your key
  
  // Initialize Stripe
  Future<void> initialize() async {
    try {
      Stripe.publishableKey = _publishableKey;
      await Stripe.instance.applySettings();
      _logger.info('Stripe initialized successfully');
    } catch (e) {
      _logger.error('Failed to initialize Stripe: $e');
      throw Exception('Failed to initialize Stripe: $e');
    }
  }

  // Create payment intent for invoice
  Future<StripePaymentIntent> createPaymentIntent({
    required Invoice invoice,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.info('Creating payment intent for invoice: ${invoice.invoiceNumber}');
      
      final callable = _functions.httpsCallable('createPaymentIntent');
      final result = await callable.call({
        'amount': (invoice.grandTotal * 100).round(), // Amount in cents
        'currency': currency.toLowerCase(),
        'invoice_id': invoice.id,
        'invoice_number': invoice.invoiceNumber,
        'customer_name': invoice.customerName,
        'customer_email': metadata?['customer_email'],
        'metadata': {
          'invoice_id': invoice.id,
          'invoice_number': invoice.invoiceNumber,
          'customer_name': invoice.customerName,
          ...?metadata,
        },
      });
      
      final data = result.data as Map<String, dynamic>;
      
      final paymentIntent = StripePaymentIntent(
        id: data['id'],
        clientSecret: data['client_secret'],
        amount: data['amount'],
        currency: data['currency'],
        status: data['status'],
        invoiceId: invoice.id,
        createdAt: DateTime.now(),
      );
      
      _logger.info('Payment intent created successfully: ${paymentIntent.id}');
      return paymentIntent;
    } catch (e) {
      _logger.error('Failed to create payment intent: $e');
      throw Exception('Failed to create payment intent: $e');
    }
  }

  // Process payment with Stripe
  Future<StripePaymentResult> processPayment({
    required StripePaymentIntent paymentIntent,
    required BillingDetails billingDetails,
  }) async {
    try {
      _logger.info('Processing payment for intent: ${paymentIntent.id}');
      
      // Confirm payment with Stripe
      final result = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntent.clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails,
          ),
        ),
      );
      
      final paymentResult = StripePaymentResult(
        paymentIntentId: paymentIntent.id,
        status: result.status.name,
        amount: paymentIntent.amount,
        currency: paymentIntent.currency,
        invoiceId: paymentIntent.invoiceId,
        paymentMethodId: result.paymentMethod?.id,
        receiptUrl: null, // Will be updated by webhook
        processedAt: DateTime.now(),
      );
      
      _logger.info('Payment processed successfully: ${paymentResult.status}');
      return paymentResult;
    } catch (e) {
      _logger.error('Payment processing failed: $e');
      throw Exception('Payment processing failed: $e');
    }
  }

  // Create customer in Stripe
  Future<StripeCustomer> createCustomer({
    required String name,
    required String email,
    String? phone,
    Map<String, String>? metadata,
  }) async {
    try {
      _logger.info('Creating Stripe customer: $email');
      
      final callable = _functions.httpsCallable('createCustomer');
      final result = await callable.call({
        'name': name,
        'email': email,
        'phone': phone,
        'metadata': metadata,
      });
      
      final data = result.data as Map<String, dynamic>;
      
      final customer = StripeCustomer(
        id: data['id'],
        name: data['name'],
        email: data['email'],
        phone: data['phone'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(data['created'] * 1000),
      );
      
      _logger.info('Stripe customer created successfully: ${customer.id}');
      return customer;
    } catch (e) {
      _logger.error('Failed to create Stripe customer: $e');
      throw Exception('Failed to create Stripe customer: $e');
    }
  }

  // Send invoice via Stripe
  Future<StripeInvoice> sendInvoice({
    required Invoice invoice,
    required String customerId,
    int? daysUntilDue,
  }) async {
    try {
      _logger.info('Sending invoice via Stripe: ${invoice.invoiceNumber}');
      
      final callable = _functions.httpsCallable('sendInvoice');
      final result = await callable.call({
        'customer_id': customerId,
        'invoice_data': {
          'number': invoice.invoiceNumber,
          'description': 'Invoice ${invoice.invoiceNumber}',
          'amount': (invoice.grandTotal * 100).round(),
          'currency': 'inr',
          'due_date': daysUntilDue != null 
              ? DateTime.now().add(Duration(days: daysUntilDue)).millisecondsSinceEpoch ~/ 1000
              : invoice.dueDate.millisecondsSinceEpoch ~/ 1000,
          'metadata': {
            'invoice_id': invoice.id,
            'invoice_number': invoice.invoiceNumber,
            'customer_name': invoice.customerName,
          },
        },
        'line_items': invoice.items.map((item) => {
          'description': item.name,
          'quantity': item.quantity,
          'unit_amount': (item.unitPrice * 100).round(),
        }).toList(),
      });
      
      final data = result.data as Map<String, dynamic>;
      
      final stripeInvoice = StripeInvoice(
        id: data['id'],
        number: data['number'],
        status: data['status'],
        amountDue: data['amount_due'],
        amountPaid: data['amount_paid'],
        currency: data['currency'],
        customerId: data['customer'],
        hostedInvoiceUrl: data['hosted_invoice_url'],
        invoicePdf: data['invoice_pdf'],
        dueDate: DateTime.fromMillisecondsSinceEpoch(data['due_date'] * 1000),
        createdAt: DateTime.fromMillisecondsSinceEpoch(data['created'] * 1000),
      );
      
      _logger.info('Invoice sent via Stripe successfully: ${stripeInvoice.id}');
      return stripeInvoice;
    } catch (e) {
      _logger.error('Failed to send invoice via Stripe: $e');
      throw Exception('Failed to send invoice via Stripe: $e');
    }
  }

  // Get payment status
  Future<String> getPaymentStatus(String paymentIntentId) async {
    try {
      final callable = _functions.httpsCallable('getPaymentStatus');
      final result = await callable.call({'payment_intent_id': paymentIntentId});
      
      return result.data['status'] as String;
    } catch (e) {
      _logger.error('Failed to get payment status: $e');
      throw Exception('Failed to get payment status: $e');
    }
  }

  // Refund payment
  Future<StripeRefund> refundPayment({
    required String paymentIntentId,
    int? amount, // Amount in cents, null for full refund
    String? reason,
  }) async {
    try {
      _logger.info('Processing refund for payment: $paymentIntentId');
      
      final callable = _functions.httpsCallable('refundPayment');
      final result = await callable.call({
        'payment_intent_id': paymentIntentId,
        'amount': amount,
        'reason': reason,
      });
      
      final data = result.data as Map<String, dynamic>;
      
      final refund = StripeRefund(
        id: data['id'],
        amount: data['amount'],
        currency: data['currency'],
        paymentIntentId: paymentIntentId,
        status: data['status'],
        reason: data['reason'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(data['created'] * 1000),
      );
      
      _logger.info('Refund processed successfully: ${refund.id}');
      return refund;
    } catch (e) {
      _logger.error('Failed to process refund: $e');
      throw Exception('Failed to process refund: $e');
    }
  }
}
