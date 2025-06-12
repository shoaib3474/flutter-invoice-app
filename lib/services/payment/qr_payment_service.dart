import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/payment/payment_transaction_model.dart';
import '../../utils/error_handler.dart';
import '../database/database_helper.dart';

class QRPaymentService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Uuid _uuid = Uuid();
  
  // Generate UPI QR code data
  String generateUpiQrData({
    required String upiId,
    required String name,
    required double amount,
    String? transactionNote,
    String? merchantCode,
  }) {
    final data = {
      'pa': upiId,
      'pn': name,
      'am': amount.toString(),
      'cu': 'INR',
    };
    
    if (transactionNote != null) {
      data['tn'] = transactionNote;
    }
    
    if (merchantCode != null) {
      data['mc'] = merchantCode;
    }
    
    // Format: upi://pay?param1=value1&param2=value2
    final queryParams = data.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return 'upi://pay?$queryParams';
  }
  
  // Save QR code image to file
  Future<File> saveQrCodeImage(String qrData, String fileName) async {
    try {
      final qrPainter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        gapless: true,
      );
      
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.png';
      final file = File(filePath);
      
      final imageData = await qrPainter.toImageData(200);
      await file.writeAsBytes(imageData!.buffer.asUint8List());
      
      return file;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to save QR code image: ${e.toString()}');
    }
  }
  
  // Create a payment transaction for QR code payment
  Future<PaymentTransactionModel> createQrTransaction({
    required double amount,
    required String customerName,
    String? customerEmail,
    String? customerPhone,
    String? orderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final transactionId = _uuid.v4();
      
      final transaction = PaymentTransactionModel(
        transactionId: transactionId,
        paymentMethod: 'qr_code',
        amount: amount,
        currency: 'INR',
        status: 'pending', // Initially pending until confirmed
        transactionDate: DateTime.now(),
        orderId: orderId,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        metadata: metadata,
      );
      
      await saveTransaction(transaction);
      
      return transaction;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to create QR transaction: ${e.toString()}');
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
  
  // Update transaction status
  Future<void> updateTransactionStatus(String transactionId, String status) async {
    try {
      final db = await _databaseHelper.database;
      
      final transaction = await getTransactionById(transactionId);
      if (transaction == null) {
        throw Exception('Transaction not found');
      }
      
      final updatedTransaction = PaymentTransactionModel(
        transactionId: transaction.transactionId,
        paymentMethod: transaction.paymentMethod,
        amount: transaction.amount,
        currency: transaction.currency,
        status: status,
        transactionDate: transaction.transactionDate,
        orderId: transaction.orderId,
        customerName: transaction.customerName,
        customerEmail: transaction.customerEmail,
        customerPhone: transaction.customerPhone,
        metadata: transaction.metadata,
      );
      
      await db.update(
        'payment_transactions',
        updatedTransaction.toJson(),
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to update transaction status: ${e.toString()}');
    }
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
  
  // Get all QR code transactions
  Future<List<PaymentTransactionModel>> getAllQrTransactions() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'payment_transactions',
        where: 'payment_method = ?',
        whereArgs: ['qr_code'],
        orderBy: 'transaction_date DESC',
      );
      
      return List.generate(maps.length, (i) {
        return PaymentTransactionModel.fromJson(maps[i]);
      });
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Failed to get all QR transactions: ${e.toString()}');
    }
  }
}
