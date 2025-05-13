import 'package:promoter_app/core/data/models/identifier.dart';

class Value {
  final Identifier key;
  final Identifier value;

  Value({
    required this.key,
    required this.value,
  });
  factory Value.fromJson(Map<String, dynamic> json) {
    return Value(
      key: Identifier.fromJson(json['key']),
      value: Identifier.fromJson(json['value']),
    );
  }
}
