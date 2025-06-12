import 'package:flutter/material.dart';
import '../models/gstin/gstin_filing_history.dart';

enum FilingStatus {
  onTime,
  late,
  notFiled,
  unknown,
}

class FilingStatusUtil {
  /// Determine filing status based on return type and filing date
  static FilingStatus determineStatus(GstrFiling filing) {
    // If status explicitly indicates not filed
    if (filing.status.toLowerCase().contains('not filed')) {
      return FilingStatus.notFiled;
    }
    
    // Calculate due date based on return type and period
    final dueDate = calculateDueDate(filing.returnType, filing.returnPeriod);
    
    // Compare filing date with due date
    if (filing.filingDate.isAfter(dueDate)) {
      return FilingStatus.late;
    } else {
      return FilingStatus.onTime;
    }
  }
  
  /// Calculate due date based on return type and period
  static DateTime calculateDueDate(String returnType, String period) {
    // Parse period (format: MM-YYYY for monthly, Q1-YYYY for quarterly)
    DateTime dueDate;
    
    if (period.startsWith('Q')) {
      // Quarterly return
      final quarter = int.parse(period.substring(1, 2));
      final year = int.parse(period.substring(3));
      
      switch (returnType) {
        case 'GSTR4':
          // Due on 18th of the month following the quarter
          final month = quarter * 3;
          dueDate = DateTime(year, month + 1, 18);
          break;
        case 'GSTR9':
        case 'GSTR9C':
          // Due on 31st December of the following year
          dueDate = DateTime(year + 1, 12, 31);
          break;
        default:
          // Default to end of next month
          final month = quarter * 3;
          dueDate = DateTime(year, month + 1, 20);
      }
    } else {
      // Monthly return
      final parts = period.split('-');
      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]);
      
      switch (returnType) {
        case 'GSTR1':
          // Due on 11th of the following month
          dueDate = DateTime(month == 12 ? year + 1 : year, month == 12 ? 1 : month + 1, 11);
          break;
        case 'GSTR3B':
          // Due on 20th of the following month
          dueDate = DateTime(month == 12 ? year + 1 : year, month == 12 ? 1 : month + 1, 20);
          break;
        default:
          // Default to end of next month
          dueDate = DateTime(month == 12 ? year + 1 : year, month == 12 ? 1 : month + 1, 20);
      }
    }
    
    return dueDate;
  }
  
  /// Get color for filing status
  static Color getStatusColor(FilingStatus status) {
    switch (status) {
      case FilingStatus.onTime:
        return Colors.green;
      case FilingStatus.late:
        return Colors.orange;
      case FilingStatus.notFiled:
        return Colors.red;
      case FilingStatus.unknown:
        return Colors.grey;
    }
  }
  
  /// Get label for filing status
  static String getStatusLabel(FilingStatus status) {
    switch (status) {
      case FilingStatus.onTime:
        return 'On Time';
      case FilingStatus.late:
        return 'Late';
      case FilingStatus.notFiled:
        return 'Not Filed';
      case FilingStatus.unknown:
        return 'Unknown';
    }
  }
  
  /// Get icon for filing status
  static IconData getStatusIcon(FilingStatus status) {
    switch (status) {
      case FilingStatus.onTime:
        return Icons.check_circle;
      case FilingStatus.late:
        return Icons.warning;
      case FilingStatus.notFiled:
        return Icons.cancel;
      case FilingStatus.unknown:
        return Icons.help;
    }
  }
}
