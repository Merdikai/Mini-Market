import 'package:intl/intl.dart';

/// Formatting utility ensuring exact 2-decimal financial presentation
class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormatter = NumberFormat.compactCurrency(
    symbol: '\$',
    decimalDigits: 1,
  );

  /// Format an amount with currency symbol, e.g. $1,249.50
  static String format(double amount, [String symbol = '\$']) {
    if (symbol == '\$') {
      return _formatter.format(amount);
    }
    return NumberFormat.currency(symbol: symbol, decimalDigits: 2).format(amount);
  }

  /// Compact representation for high-density KPI chips, e.g. $12.4K
  static String formatCompact(double amount, [String symbol = '\$']) {
    if (symbol == '\$') {
      return _compactFormatter.format(amount);
    }
    return NumberFormat.compactCurrency(symbol: symbol, decimalDigits: 1).format(amount);
  }

  /// Exact 2-decimal rounded double for financial transactions
  static double round(double amount) {
    return (amount * 100).roundToDouble() / 100;
  }

  /// Calculate tax on subtotal with specified tax rate
  static double calculateTax(double subtotal, double rate) {
    return round(subtotal * rate);
  }

  /// Calculate discount from percentage
  static double calculateDiscount(double subtotal, double percent) {
    if (percent <= 0) return 0.0;
    return round(subtotal * (percent / 100));
  }
}
