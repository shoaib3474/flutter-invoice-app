import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }
  
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }
  
  static String formatQuarter(DateTime date) {
    final quarter = ((date.month - 1) / 3).floor() + 1;
    return 'Q$quarter ${date.year}';
  }
  
  static String formatFinancialYear(DateTime date) {
    final year = date.year;
    final month = date.month;
    
    if (month >= 4) {
      return '$year-${(year + 1).toString().substring(2)}';
    } else {
      return '${year - 1}-${year.toString().substring(2)}';
    }
  }
}
