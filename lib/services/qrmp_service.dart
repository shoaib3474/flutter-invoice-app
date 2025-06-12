import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_invoice_app/models/gst_returns/qrmp_model.dart';
import 'package:flutter_invoice_app/utils/api_exception.dart';
import 'package:flutter_invoice_app/utils/gstin_validator.dart';

class QRMPService {
  final String? baseUrl;
  final String? apiKey;
  final bool useDemo;

  QRMPService({
    this.baseUrl,
    this.apiKey,
    this.useDemo = true,
  });

  /// Get QRMP scheme details
  Future<QRMPScheme> getQRMPScheme(String gstin, String financialYear, String quarter) async {
    // Validate GSTIN
    final validationResult = GstinValidator.validate(gstin);
    if (!validationResult.isValid) {
      throw ApiException(
        statusCode: 400,
        message: 'Invalid GSTIN: ${validationResult.message}',
      );
    }

    if (useDemo) {
      return _getDemoQRMPScheme(gstin, financialYear, quarter);
    } else {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/qrmp/scheme'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
            'gstin': gstin,
            'financial_year': financialYear,
            'quarter': quarter,
          },
        );

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          return QRMPScheme.fromJson(jsonData);
        } else {
          throw ApiException(
            statusCode: response.statusCode,
            message: 'Failed to get QRMP scheme: ${response.body}',
          );
        }
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(
          message: 'Error fetching QRMP scheme: ${e.toString()}',
        );
      }
    }
  }

  /// Submit monthly payment under QRMP scheme
  Future<String> submitMonthlyPayment(
    String gstin,
    String financialYear,
    String quarter,
    String month,
    QRMPMonthlyPayment payment,
  ) async {
    // Validate GSTIN
    final validationResult = GstinValidator.validate(gstin);
    if (!validationResult.isValid) {
      throw ApiException(
        statusCode: 400,
        message: 'Invalid GSTIN: ${validationResult.message}',
      );
    }

    if (useDemo) {
      await Future.delayed(Duration(seconds: 2)); // Simulate network delay
      return 'PMT${DateTime.now().millisecondsSinceEpoch}';
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/qrmp/payment'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: json.encode({
            'gstin': gstin,
            'financial_year': financialYear,
            'quarter': quarter,
            'month': month,
            'payment': payment.toJson(),
          }),
        );

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          return jsonData['challan_number'];
        } else {
          throw ApiException(
            statusCode: response.statusCode,
            message: 'Failed to submit monthly payment: ${response.body}',
          );
        }
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(
          message: 'Error submitting monthly payment: ${e.toString()}',
        );
      }
    }
  }

  /// Submit quarterly return under QRMP scheme
  Future<String> submitQuarterlyReturn(
    String gstin,
    String financialYear,
    String quarter,
    QRMPQuarterlyReturn quarterlyReturn,
  ) async {
    // Validate GSTIN
    final validationResult = GstinValidator.validate(gstin);
    if (!validationResult.isValid) {
      throw ApiException(
        statusCode: 400,
        message: 'Invalid GSTIN: ${validationResult.message}',
      );
    }

    if (useDemo) {
      await Future.delayed(Duration(seconds: 3)); // Simulate network delay
      return 'RTN${DateTime.now().millisecondsSinceEpoch}';
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/qrmp/return'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: json.encode({
            'gstin': gstin,
            'financial_year': financialYear,
            'quarter': quarter,
            'quarterly_return': quarterlyReturn.toJson(),
          }),
        );

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          return jsonData['acknowledgement_number'];
        } else {
          throw ApiException(
            statusCode: response.statusCode,
            message: 'Failed to submit quarterly return: ${response.body}',
          );
        }
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(
          message: 'Error submitting quarterly return: ${e.toString()}',
        );
      }
    }
  }

  /// Export QRMP scheme data to JSON file
  Future<String> exportToJson(QRMPScheme qrmpScheme) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'QRMP_${qrmpScheme.gstin}_${qrmpScheme.quarter}_${qrmpScheme.financialYear}.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(json.encode(qrmpScheme.toJson()));
      return file.path;
    } catch (e) {
      throw Exception('Failed to export QRMP data: ${e.toString()}');
    }
  }

  /// Import QRMP scheme data from JSON file
  Future<QRMPScheme> importFromJson(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }
      
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);
      return QRMPScheme.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to import QRMP data: ${e.toString()}');
    }
  }

  /// Generate demo QRMP scheme data
  Future<QRMPScheme> _getDemoQRMPScheme(String gstin, String financialYear, String quarter) async {
    // Parse quarter to get months
    List<String> months = _getMonthsForQuarter(quarter);
    
    // Generate random monthly payments
    List<QRMPMonthlyPayment> monthlyPayments = [];
    double totalTaxPaid = 0;
    
    for (String month in months) {
      final bool useFixedSum = month == months.first; // First month uses fixed sum
      
      if (useFixedSum) {
        final fixedAmount = 5000.0;
        totalTaxPaid += fixedAmount;
        
        monthlyPayments.add(QRMPMonthlyPayment(
          month: month,
          paymentMethod: 'Fixed Sum',
          fixedSumAmount: fixedAmount,
          challanNumber: 'CHL${DateTime.now().millisecondsSinceEpoch}',
          paymentDate: DateTime.now().subtract(Duration(days: 30)),
          status: 'Paid',
        ));
      } else {
        final outwardSupplies = 100000.0;
        final igstAmount = 9000.0;
        final cgstAmount = 4500.0;
        final sgstAmount = 4500.0;
        final totalAmount = igstAmount + cgstAmount + sgstAmount;
        
        totalTaxPaid += totalAmount;
        
        monthlyPayments.add(QRMPMonthlyPayment(
          month: month,
          paymentMethod: 'Self-Assessment',
          selfAssessment: QRMPSelfAssessment(
            outwardSupplies: outwardSupplies,
            inwardSupplies: 50000.0,
            igstAmount: igstAmount,
            cgstAmount: cgstAmount,
            sgstAmount: sgstAmount,
            cessAmount: 0.0,
            totalTaxPayable: totalAmount,
          ),
          challanNumber: 'CHL${DateTime.now().millisecondsSinceEpoch}',
          paymentDate: DateTime.now().subtract(Duration(days: 15)),
          status: 'Paid',
        ));
      }
    }
    
    // Generate quarterly return
    final totalOutwardSupplies = 300000.0;
    final totalTaxPayable = 54000.0;
    final balanceTaxPayable = totalTaxPayable - totalTaxPaid;
    
    final quarterlyReturn = QRMPQuarterlyReturn(
      totalOutwardSupplies: totalOutwardSupplies,
      totalInwardSupplies: 150000.0,
      totalIgst: 27000.0,
      totalCgst: 13500.0,
      totalSgst: 13500.0,
      totalCess: 0.0,
      totalTaxPaid: totalTaxPaid,
      balanceTaxPayable: balanceTaxPayable,
      status: 'Filed',
      filingDate: DateTime.now(),
    );
    
    return QRMPScheme(
      gstin: gstin,
      financialYear: financialYear,
      quarter: quarter,
      monthlyPayments: monthlyPayments,
      quarterlyReturn: quarterlyReturn,
      status: 'Completed',
      filingDate: DateTime.now(),
    );
  }

  /// Get months for a given quarter
  List<String> _getMonthsForQuarter(String quarter) {
    switch (quarter) {
      case 'Q1':
        return ['April', 'May', 'June'];
      case 'Q2':
        return ['July', 'August', 'September'];
      case 'Q3':
        return ['October', 'November', 'December'];
      case 'Q4':
        return ['January', 'February', 'March'];
      default:
        throw ArgumentError('Invalid quarter: $quarter');
    }
  }
}
