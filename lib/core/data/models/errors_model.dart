// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class ErrorModel extends Equatable {
  final List<String>? otpPassword;
  const ErrorModel({
    this.otpPassword,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'otp_password': otpPassword,
    };
  }

  String toJson() => json.encode(toMap());

  factory ErrorModel.fromJson(String source) =>
      ErrorModel.fromMap(json.decode(source) as Map<String, dynamic>);

  ErrorModel copyWith({
    List<String>? otpPassword,
  }) {
    return ErrorModel(
      otpPassword: otpPassword ?? this.otpPassword,
    );
  }

  @override
  List<Object> get props => [
        otpPassword!,
      ];

  factory ErrorModel.fromMap(Map<String, dynamic> map) {
    return ErrorModel(
      otpPassword: map['otp_password'] != null
          ? List<String>.from((map['otp_password']))
          : null,
    );
  }
}
