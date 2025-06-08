import 'package:intl/intl.dart';

class Formatters {
  static final _priceFormatter = NumberFormat.currency(
    symbol: '€',
    decimalDigits: 2,
  );

  /// Format precise price as currency (e.g., "€50.99")
  static String formatPrecisePrice(double price) {
    return _priceFormatter.format(price);
  }
}