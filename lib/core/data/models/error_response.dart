import 'response_model.dart';

class ErrorResponse extends ResponseModel {
  const ErrorResponse({required super.statusCode, required super.message});
  // ErrorResponse({
  //   required this.error,
  //   required this.errorType
  // });
  //
  //
  // final ErrorModel error;
  // final String errorType;
  //
  // factory ErrorResponse.fromMap(Map<String, dynamic> map) {
  //   return ErrorResponse(
  //     error: ErrorModel.fromMap(map['errors'] as Map<String,dynamic>),
  //     errorType: map['error_type'] as String,
  //   );
  // }
  //
  // Map<String, dynamic> toMap() {
  //   return <String, dynamic>{
  //     'errors': error.toMap(),
  //     'error_type': errorType,
  //   };
  // }
  //
  // @override
  // List<Object?> get props => [error, errorType];

}
