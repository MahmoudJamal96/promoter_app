
import 'response_model.dart';

class MessageResponse extends ResponseModel /*implements LoggersBase*/ {
  @override
  final int? flag;
  final dynamic data;

  const MessageResponse({
    super.statusCode,
    super.message,
    this.flag,
    this.data,
  });

  factory MessageResponse.fromMap(Map<String, dynamic> map, {dynamic data}) => MessageResponse(
    data: data,
    statusCode: map['Status'] ?? map['status'] ?? map['statusCode'],
    flag: map['flag'] == null ? null : int.tryParse(map['flag'].toString()),
    message: map['Message'] ?? map['message'] ?? map['errorMessage'] ?? map['description'],
  );

  /*@override
  LoggersBase fromMap(Map<String, dynamic> map) => MessageResponse(
    data: data,
    statusCode: map['Status'] ?? map['status'] ?? map['statusCode'],
    flag: int.tryParse(map['flag']?.toString() ?? '0') ?? 0,
    message: map['Message'] ?? map['message'] ?? map['errorMessage'] ?? map['description'],
  );*/
}
