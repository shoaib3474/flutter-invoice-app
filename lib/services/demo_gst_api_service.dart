import 'dart:async';
import 'dart:math';
import '../models/api/api_response.dart';
import '../utils/api_exception.dart';

/// A demo implementation of the GST API service that simulates API responses
/// This is useful for testing and development without actual API integration
class DemoGstApiService {
  final Random _random = Random();
  
  // Simulate network delay
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1500)));
  }
  
  // Simulate API error (randomly)
  void _maybeThrowError() {
    if (_random.nextInt(10) == 0) { // 10% chance of error
      throw ApiException(
        statusCode: 500,
        message: 'Simulated server error',
      );
    }
  }
  
  // GSTR1 specific endpoints
  Future<ApiResponse> fetchGstr1Data(String period, String financialYear) async {
    await _simulateNetworkDelay();
    _maybeThrowError();
    
    return ApiResponse(
      success: true,
      statusCode: 200,
      message: 'GSTR1 data fetched successfully',
      data: {
        'return_type': 'GSTR1',
        'period': period,
        'financial_year': financialYear,
        'status': 'FETCHED',
        'data': {
          'b2b_invoices': List.generate(5, (i) => {
            'invoice_number': 'INV-${1000 + i}',
            'invoice_date': '2023-${_random.nextInt(12) + 1}-${_random.nextInt(28) + 1}',
            'customer_gstin': '27AAPFU0939F1ZV',
            'place_of_supply': 'Maharashtra',
            'invoice_value': (10000 + _random.nextInt(90000)).toDouble(),
            'taxable_value': (8000 + _random.nextInt(70000)).toDouble(),
            'igst': (1000 + _random.nextInt(5000)).toDouble(),
            'cgst': 0.0,
            'sgst': 0.0,
          }),
          'b2c_invoices': List.generate(3, (i) => {
            'invoice_number': 'BINV-${2000 + i}',
            'invoice_date': '2023-${_random.nextInt(12) + 1}-${_random.nextInt(28) + 1}',
            'place_of_supply': 'Maharashtra',
            'invoice_value': (5000 + _random.nextInt(15000)).toDouble(),
            'taxable_value': (4000 + _random.nextInt(12000)).toDouble(),
            'igst': 0.0,
            'cgst': (200 + _random.nextInt(600)).toDouble(),
            'sgst': (200 + _random.nextInt(600)).toDouble(),
          }),
        }
      },
    );
  }

  Future<ApiResponse> prepareGstr1(String period, String financialYear) async {
    await _simulateNetworkDelay();
    _maybeThrowError();
    
    return ApiResponse(
      success: true,
      statusCode: 200,
      message: 'GSTR1 return prepared successfully',
      data: {
        'return_type': 'GSTR1',
        'period': period,
        'financial_year': financialYear,
        'status': 'PREPARED',
        'message': 'GSTR1 return prepared successfully',
        'summary': {
          'total_invoices': 8,
          'total_taxable_value': (100000 + _random.nextInt(500000)).toDouble(),
          'total_tax': (18000 + _random.nextInt(90000)).toDouble(),
        }
      },
    );
  }

  Future<ApiResponse> fileGstr1(String period, String financialYear) async {
    await _simulateNetworkDelay();
    _maybeThrowError();
    
    return ApiResponse(
      success: true,
      statusCode: 200,
      message: 'GSTR1 return filed successfully',
      data: {
        'return_type': 'GSTR1',
        'period': period,
        'financial_year': financialYear,
        'status': 'FILED',
        'message': 'GSTR1 return filed successfully',
        'acknowledgement_number': 'ACK${10000000 + _random.nextInt(90000000)}',
        'filed_date': DateTime.now().toIso8601String(),
      },
    );
  }

  // GSTR3B specific endpoints
  Future<ApiResponse> fetchGstr3bData(String period, String financialYear) async {
    await _simulateNetworkDelay();
    _maybeThrowError();
    
    return ApiResponse(
      success: true,
      statusCode: 200,
      message: 'GSTR3B data fetched successfully',
      data: {
        'return_type': 'GSTR3B',
        'period': period,
        'financial_year': financialYear,
        'status': 'FETCHED',
        'data': {
          'outward_supplies': {
            'taxable': (500000 + _random.nextInt(1500000)).toDouble(),
            'igst': (90000 + _random.nextInt(270000)).toDouble(),
            'cgst': (45000 + _random.nextInt(135000)).toDouble(),
            'sgst': (45000 + _random.nextInt(135000)).toDouble(),
          },
          'inward_supplies': {
            'taxable': (300000 + _random.nextInt(700000)).toDouble(),
            'igst': (54000 + _random.nextInt(126000)).toDouble(),
            'cgst': (27000 + _random.nextInt(63000)).toDouble(),
            'sgst': (27000 + _random.nextInt(63000)).toDouble(),
          },
          'itc_available': {
            'igst': (50000 + _random.nextInt(100000)).toDouble(),
            'cgst': (25000 + _random.nextInt(50000)).toDouble(),
            'sgst': (25000 + _random.nextInt(50000)).toDouble(),
          },
        }
      },
    );
  }

  Future<ApiResponse> prepareGstr3b(String period, String financialYear) async {
    await _simulateNetworkDelay();
    _maybeThrowError();
    
    return ApiResponse(
      success: true,
      statusCode: 200,
      message: 'GSTR3B return prepared successfully',
      data: {
        'return_type': 'GSTR3B',
        'period': period,
        'financial_year': financialYear,
        'status': 'PREPARED',
        'message': 'GSTR3B return prepared successfully',
        'summary': {
          'total_tax_payable': (50000 + _random.nextInt(150000)).toDouble(),
          'total_itc_utilized': (40000 + _random.nextInt(100000)).toDouble(),
          'tax_payable_in_cash': (10000 + _random.nextInt(50000)).toDouble(),
        }
      },
    );
  }

  Future<ApiResponse> fileGstr3b(String period, String financialYear) async {
    await _simulateNetworkDelay();
    _maybeThrowError();
    
    return ApiResponse(
      success: true,
      statusCode: 200,
      message: 'GSTR3B return filed successfully',
      data: {
        'return_type': 'GSTR3B',
        'period': period,
        'financial_year': financialYear,
        'status': 'FILED',
        'message': 'GSTR3B return filed successfully',
        'acknowledgement_number': 'ACK${10000000 + _random.nextInt(90000000)}',
        'filed_date': DateTime.now().toIso8601String(),
      },
    );
  }

  // GSTR9 specific endpoints
  Future<ApiResponse> fetchGstr9Data(String financialYear) async {
    await _simulateNetworkDelay();
    _maybeThrowError();
    
    return ApiResponse(
      success: true,
      statusCode: 200,
      message: 'GSTR9 data fetched successfully',
      data: {
        'return_type': 'GSTR9',
        'financial_year': financialYear,
        'status': 'FETCHED',
        'data': {
          'annual_turnover': (5000000 + _random.nextInt(15000000)).toDouble(),
          'total_tax_paid': (900000 + _random.nextInt(2700000)).toDouble(),
          'total_itc_availed': (800000 + _random.nextInt(2000000)).toDouble(),
          'monthly_summary': List.generate(12, (i) => {
            'month': i + 1,
            'turnover': (400000 + _random.nextInt(600000)).toDouble(),
            'tax_paid': (72000 + _random.nextInt(108000)).toDouble(),
          }),
        }
      },
    );
  }

  Future<ApiResponse> prepareGstr9(String financialYear) async {
    await _simulateNetworkDelay();
    _maybeThrowError();
    
    return ApiResponse(
      success: true,
      statusCode: 200,
      message: 'GSTR9 return prepared successfully',
      data: {
        'return_type': 'GSTR9',
        'financial_year': financialYear,
        'status': 'PREPARED',
        'message': 'GSTR9 return prepared successfully',
        'summary': {
          'total_annual_turnover': (6000000 + _random.nextInt(14000000)).toDouble(),
          'total_tax_liability': (1080000 + _random.nextInt(2520000)).toDouble(),
          'total_tax_paid': (1080000 + _random.nextInt(2520000)).toDouble(),
          'difference': 0.0,
        }
      },
    );
  }

  Future<ApiResponse> fileGstr9(String financialYear) async {
    await _simulateNetworkDelay();
    _maybeThrowError();
    
    return ApiResponse(
      success: true,
      statusCode: 200,
      message: 'GSTR9 return filed successfully',
      data: {
        'return_type': 'GSTR9',
        'financial_year': financialYear,
        'status': 'FILED',
        'message': 'GSTR9 return filed successfully',
        'acknowledgement_number': 'ACK${10000000 + _random.nextInt(90000000)}',
        'filed_date': DateTime.now().toIso8601String(),
      },
    );
  }

  // GSTR9C specific endpoints
  Future<ApiResponse> fetchGstr9cData(String financialYear) async {
    await _simulateNetworkDelay();
    _maybeThrowError();
    
    return ApiResponse(
      success: true,
      statusCode: 200,
      message: 'GSTR9C data fetched successfully',
      data: {
        'return_type': 'GSTR9C',
        'financial_year': financialYear,
        'status': 'FETCHED',
        'data': {
          'turnover_as_per_audited_fs': (6200000 + _random.nextInt(13800000)).toDouble(),
          'turnover_as_per_annual_return': (6000000 + _random.nextInt(14000000)).toDouble(),
          'un_reconciled_difference': (0 + _random.nextInt(200000)).toDouble(),
          'reasons_for_un_reconciled_difference': [
            'Timing difference in recording sales',
            'Credit notes not considered',
            'Sales return not accounted properly',
          ],
        }
      },
    );
  }

  Future<ApiResponse> prepareGstr9c(String financialYear) async {
    await _simulateNetworkDelay();
    _maybeThrowError();
    
    return ApiResponse(
      success: true,
      statusCode: 200,
      message: 'GSTR9C return prepared successfully',
      data: {
        'return_type': 'GSTR9C',
        'financial_year': financialYear,
        'status': 'PREPARED',
        'message': 'GSTR9C return prepared successfully',
        'summary': {
          'turnover_as_per_audited_fs': (6200000 + _random.nextInt(13800000)).toDouble(),
          'turnover_as_per_annual_return': (6000000 + _random.nextInt(14000000)).toDouble(),
          'un_reconciled_difference': (0 + _random.nextInt(200000)).toDouble(),
          'additional_liability_identified': (0 + _random.nextInt(50000)).toDouble(),
        }
      },
    );
  }

  Future<ApiResponse> fileGstr9c(String financialYear) async {
    await _simulateNetworkDelay();
    _maybeThrowError();
    
    return ApiResponse(
      success: true,
      statusCode: 200,
      message: 'GSTR9C return filed successfully',
      data: {
        'return_type': 'GSTR9C',
        'financial_year': financialYear,
        'status': 'FILED',
        'message': 'GSTR9C return filed successfully',
        'acknowledgement_number': 'ACK${10000000 + _random.nextInt(90000000)}',
        'filed_date': DateTime.now().toIso8601String(),
      },
    );
  }
}
