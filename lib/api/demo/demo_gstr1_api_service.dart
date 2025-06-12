import 'dart:math';

import '../../models/api/api_response.dart';
import '../../models/gst_returns/gstr1_model.dart';
import '../../models/gst_returns/nil_filing_model.dart';
import '../../services/logger_service.dart';

class DemoGSTR1ApiService {
  final Random _random = Random();
  final LoggerService _logger = LoggerService();
  
  Future<ApiResponse<GSTR1Model>> getGSTR1Data(String gstin, String period) async {
    _logger.info('Fetching GSTR-1 data for GSTIN: $gstin, Period: $period');
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Generate demo data
    final demoData = _generateDemoGSTR1Data(gstin, period);
    
    _logger.info('GSTR-1 data fetched successfully');
    return ApiResponse<GSTR1Model>(
      success: true,
      data: demoData,
      message: 'GSTR-1 data fetched successfully',
      statusCode: 200,
    );
  }
  
  Future<ApiResponse<String>> submitGSTR1(GSTR1Model data) async {
    _logger.info('Submitting GSTR-1 for GSTIN: ${data.gstin}');
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Generate acknowledgement number
    final ackNo = 'ACK${DateTime.now().millisecondsSinceEpoch}';
    
    _logger.info('GSTR-1 submitted successfully with ACK: $ackNo');
    return ApiResponse<String>(
      success: true,
      data: ackNo,
      message: 'GSTR-1 submitted successfully',
      statusCode: 200,
    );
  }
  
  Future<ApiResponse<NilFilingResult>> submitGSTR1Nil({
    required String gstin,
    required String period,
    required String mobileNumber,
  }) async {
    _logger.info('Submitting GSTR-1 NIL for GSTIN: $gstin, Period: $period');
    
    // Simulate SMS delay
    await Future.delayed(const Duration(seconds: 3));
    
    // Generate NIL filing result
    final result = NilFilingResult(
      success: true,
      message: 'GSTR-1 NIL return filed successfully via SMS',
      acknowledgmentNumber: 'NIL${DateTime.now().millisecondsSinceEpoch}',
      filingDate: DateTime.now(),
      smsText: 'GSTR1NIL $gstin $period',
    );
    
    _logger.info('GSTR-1 NIL filed successfully');
    return ApiResponse<NilFilingResult>(
      success: true,
      data: result,
      message: 'GSTR-1 NIL return filed successfully',
      statusCode: 200,
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getGSTR1Status(String gstin, String period) async {
    _logger.info('Fetching GSTR-1 status for GSTIN: $gstin, Period: $period');
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Generate random status
    final statusOptions = ['Filed', 'Pending', 'Not Filed', 'NIL Filed'];
    final status = statusOptions[_random.nextInt(statusOptions.length)];
    
    final statusData = {
      'gstin': gstin,
      'period': period,
      'status': status,
      'filing_date': status.contains('Filed') 
          ? DateTime.now().subtract(Duration(days: _random.nextInt(10))).toIso8601String() 
          : null,
      'acknowledgement_number': status.contains('Filed') 
          ? (status == 'NIL Filed' ? 'NIL${DateTime.now().millisecondsSinceEpoch}' : 'ACK${DateTime.now().millisecondsSinceEpoch}')
          : null,
      'is_nil_return': status == 'NIL Filed',
    };
    
    _logger.info('GSTR-1 status fetched: $status');
    return ApiResponse<Map<String, dynamic>>(
      success: true,
      data: statusData,
      message: 'GSTR-1 status fetched successfully',
      statusCode: 200,
    );
  }
  
  GSTR1Model _generateDemoGSTR1Data(String gstin, String period) {
    // Parse period to get month and year
    final periodParts = period.split('-');
    final month = int.parse(periodParts[0]);
    final year = int.parse(periodParts[1]);
    
    // Generate random number of B2B invoices (5-15)
    final b2bInvoiceCount = 5 + _random.nextInt(11);
    
    // Generate random number of B2C invoices (10-30)
    final b2cInvoiceCount = 10 + _random.nextInt(21);
    
    // Generate random invoice values
    final b2bInvoiceValue = (100000 + _random.nextInt(900000)) / 100;
    final b2cInvoiceValue = (50000 + _random.nextInt(450000)) / 100;
    
    // Generate random HSN summary
    final hsnSummaryCount = 3 + _random.nextInt(8);
    final hsnTotalValue = b2bInvoiceValue + b2cInvoiceValue;
    
    // Create GSTR1 model
    return GSTR1Model(
      gstin: gstin,
      financialYear: _getFinancialYear(month, year),
      taxPeriod: period,
      b2bInvoiceCount: b2bInvoiceCount,
      b2bInvoiceValue: b2bInvoiceValue,
      b2cInvoiceCount: b2cInvoiceCount,
      b2cInvoiceValue: b2cInvoiceValue,
      hsnSummaryCount: hsnSummaryCount,
      hsnTotalValue: hsnTotalValue,
    );
  }
  
  String _getFinancialYear(int month, int year) {
    // Financial year in India is from April to March
    if (month >= 4) {
      return '$year-${year + 1}';
    } else {
      return '${year - 1}-$year';
    }
  }
}
