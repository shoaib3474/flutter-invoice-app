import 'package:intl/intl.dart';

String formatCurrency(double amount, {String symbol = '₹'}) {
  final formatter = NumberFormat.currency(
    symbol: symbol,
    decimalDigits: 2,
  );
  return formatter.format(amount);
}

String formatCurrencyCompact(double amount, {String symbol = '₹'}) {
  final formatter = NumberFormat.compactCurrency(
    symbol: symbol,
    decimalDigits: 2,
  );
  return formatter.format(amount);
}

double parseCurrency(String value) {
  // Remove currency symbols and parse
  final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
  return double.tryParse(cleanValue) ?? 0.0;
}
