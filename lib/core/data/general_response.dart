import 'package:promoter_app/qara_ksa.dart';

abstract class GeneralResponse extends Equatable {
  final int statusCode;
  final String message;
  final int? flag;

  const GeneralResponse({
    required this.statusCode,
    required this.message,
    this.flag,

  });

  Map<String, dynamic> toMap();

  @override
  bool get stringify => true;
}
