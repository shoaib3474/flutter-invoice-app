import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/gst_returns/gst_return_summary.dart';

class GstReturnsService {
  // Mock data for demonstration
  static const Map<String, dynamic> _mockDashboardData = {
    'summary': {
      'total_tax_liability': 150000.0,
      'tax_paid': 120000.0,
      'input_tax_credit': 80000.0,
      'balance': 30000.0,
    },
    'compliance_score': 85,
    'filing_status_data': {
      'filed': 8,
      'pending': 2,
      'overdue': 1,
    },
    'tax_liability_data': [
      {'month': 'Jan', 'amount': 12000},
      {'month': 'Feb', 'amount': 15000},
      {'month': 'Mar', 'amount': 18000},
      {'month': 'Apr', 'amount': 14000},
      {'month': 'May', 'amount': 16000},
      {'month': 'Jun', 'amount': 19000},
    ],
    'due_dates': [
      {
        'return_type': 'GSTR-1',
        'period': 'June 2024',
        'date': '2024-07-11',
      },
      {
        'return_type': 'GSTR-3B',
        'period': 'June 2024',
        'date': '2024-07-20',
      },
    ],
  };

  Future<Map<String, dynamic>> getDashboardData() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockDashboardData;
  }

  Future<List<GstReturnSummary>> getRecentFilings() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      GstReturnSummary(
        id: '1',
        returnType: 'GSTR-1',
        period: 'May 2024',
        filingDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'Filed',
        taxAmount: 15000.0,
      ),
      GstReturnSummary(
        id: '2',
        returnType: 'GSTR-3B',
        period: 'May 2024',
        filingDate: DateTime.now().subtract(const Duration(days: 3)),
        status: 'Filed',
        taxAmount: 12000.0,
      ),
      GstReturnSummary(
        id: '3',
        returnType: 'GSTR-1',
        period: 'April 2024',
        filingDate: DateTime.now().subtract(const Duration(days: 35)),
        status: 'Filed',
        taxAmount: 18000.0,
      ),
    ];
  }

  Future<void> fileReturn(String returnType, String period) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    if (kDebugMode) {
      print('Filed $returnType for $period');
    }
  }

  Future<Map<String, dynamic>> getReturnDetails(String returnId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'id': returnId,
      'return_type': 'GSTR-1',
      'period': 'May 2024',
      'filing_date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'status': 'Filed',
      'tax_amount': 15000.0,
      'details': {
        'total_invoices': 45,
        'total_taxable_value': 500000.0,
        'total_tax': 90000.0,
        'input_tax_credit': 75000.0,
      },
    };
  }
}
