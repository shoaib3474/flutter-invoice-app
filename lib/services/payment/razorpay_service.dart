import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/payment/payment_transaction_model.dart';
import '../../utils/error_handler.dart';
import '../database/database_helper.dart';

class RazorpayService {
  final Razorpay _razorpay = Razorpay();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Uuid _uuid = Uuid();
  
  // Initialize Razorpay
  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onWalletSelected,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onWalletSelected);
  }
  
  // Dispose Razorpay
  void dispose() {
    _razorpay.clear();
  }
  
  // Create payment options
  Map<String, dynamic> createPaymentOptions({
    required String orderId,
    required double amount,
    required String description,
    required String name,
    required String email,
    required String contact,
    String? theme,
  }) {
    return {
      'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your Razorpay key
      'amount': (amount * 100).toInt(), // Razorpay expects amount in paise
      'name': name,
      'description': description,
      'order_id': orderId,
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'theme': {
        'color': theme ?? '#3399cc',
      },
    };
  }
  
  // Start payment
  Future<void> startPayment(Map<String, dynamic> options) async {
    try {
      _razorpay.open(options);
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to start payment: ${e.toString()}');
    }
  }
  
  // Save payment transaction
  Future<void> saveTransaction(PaymentTransactionModel transaction) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert(
        'payment_transactions',
        transaction.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to save transaction: ${e.toString()}');
    }
  }
  
  // Create transaction from Razorpay response
  PaymentTransactionModel createTransactionFromResponse(
    PaymentSuccessResponse response,
    double amount,
    String customerName,
    String customerEmail,
    String customerPhone,
  ) {
    return PaymentTransactionModel(
      transactionId: response.paymentId ?? _uuid.v4(),
      paymentMethod: 'razorpay',
      amount: amount,
      currency: 'INR',
      status: 'success',
      transactionDate: DateTime.now(),
      orderId: response.orderId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      metadata: {
        'signature': response.signature,
      },
    );
  }
  
  // Get transaction by ID
  Future<PaymentTransactionModel?> getTransactionById(String transactionId) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'payment_transactions',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );
      
      if (maps.isEmpty) {
        return null;
      }
      
      return PaymentTransactionModel.fromJson(maps.first);
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to get transaction: ${e.toString()}');
    }
  }
  
  // Get all transactions
  Future<List<PaymentTransactionModel>> getAllTransactions() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'payment_transactions',
        orderBy: 'transaction_date DESC',
      );
      
      return List.generate(maps.length, (i) {
        return PaymentTransactionModel.fromJson(maps[i]);
      });
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to get all transactions: ${e.toString()}');
    }
  }
}
