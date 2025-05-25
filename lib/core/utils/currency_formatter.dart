import '../constants/strings.dart';

class CurrencyFormatter {
  static String format(double amount) {
    return '${amount.toStringAsFixed(2)} ${Strings.CURRENCY}';
  }
}
