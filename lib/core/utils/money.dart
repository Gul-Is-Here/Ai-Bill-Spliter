import 'package:intl/intl.dart';

/// Money is always an int in minor units (paisa, cents). Only this file converts to/from text.
abstract class Money {
  static const defaultCurrency = 'PKR';

  static int fractionDigits(String currency) => NumberFormat.simpleCurrency(name: currency).decimalDigits ?? 2;

  static String format(int minor, String currency, {String? locale}) {
    final f = NumberFormat.simpleCurrency(name: currency, locale: locale);
    return f.format(minor / _scale(currency));
  }

  /// Parses user input like "1,250.50" into minor units; null when invalid or negative.
  static int? parse(String input, String currency) {
    final cleaned = input.replaceAll(',', '').trim();
    final value = double.tryParse(cleaned);
    if (value == null || value < 0 || !value.isFinite) return null;
    return (value * _scale(currency)).round();
  }

  /// Plain number for editing fields (no symbol, no grouping).
  static String toInput(int minor, String currency) {
    final digits = fractionDigits(currency);
    return (minor / _scale(currency)).toStringAsFixed(digits);
  }

  static int _scale(String currency) {
    var s = 1;
    for (var i = 0; i < fractionDigits(currency); i++) {
      s *= 10;
    }
    return s;
  }
}
