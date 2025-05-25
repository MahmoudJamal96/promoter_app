import '../constants/strings.dart';

extension PriceExtension on num {
  String toCurrency() {
    return '${this.toStringAsFixed(2)} ${Strings.CURRENCY}';
  }
}
