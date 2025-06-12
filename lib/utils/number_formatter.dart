import 'package:intl/intl.dart';

class NumberFormatter {
  static final _formatter = NumberFormat('#,##,##0.00');
  static final _compactFormatter = NumberFormat.compact();
  
  static String format(double value) {
    return _formatter.format(value);
  }
  
  static String formatCompact(double value) {
    return _compactFormatter.format(value);
  }
  
  static String formatWithSymbol(double value, {String symbol = '₹'}) {
    return '$symbol${format(value)}';
  }
  
  static String formatAsPercentage(double value) {
    return '${(value * 100).toStringAsFixed(2)}%';
  }
}
