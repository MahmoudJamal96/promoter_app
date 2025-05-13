import 'package:promoter_app/qara_ksa.dart';

abstract class ResponseModel extends Equatable {
  final int? statusCode;
  final String? message;
  final int? flag;

  const ResponseModel({
    required this.statusCode,
    required this.message,
    this.flag,
  });

  @override
  List<Object?> get props => [
        statusCode,
        message,
        flag,
      ];
}
