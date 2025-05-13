import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/request_to_curl.dart';
import 'api_manager.dart';

abstract class Failure extends Equatable {
  final id = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
}

abstract class ReportableFailure extends Failure {
  ReportableFailure({
    required this.failureInfo,
    required this.type,
  });

  final FailureInfo failureInfo;
  final String type;

  Future<String> generateReport() async {
    String text = 'Failure Report:\n';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(id) * 1000);
    final formattedDateTime =
        DateFormat('yyyy-MM-dd').add_jm().format(dateTime);
    text += 'DateTime: $formattedDateTime\n';
    text += 'ID: $id\n';
    text += 'Type: $type\n';
    if (failureInfo.request != null) {
      text += '\nRequest:\n';
      text += 'URL: ${failureInfo.request!.url}\n';
      text += 'Method: ${failureInfo.request!.method}\n';
      //Query Parameters
      text += 'Query Parameters:\n';
      text += '${await failureInfo.request!.queryParameters}\n';

      //Data
      final data = await failureInfo.request!.data;
      if (data != null) {
        text += 'Data:\n';
        text += '${await failureInfo.request!.data}\n';
      }
      if (failureInfo.response?.requestOptions == null) {
        //headers
        text += 'Request Headers:\n';
        text += '${failureInfo.request!.headers}\n';
        //curl
        final curl = await request2curl(failureInfo.request);
        if (curl != null) {
          text += '\nStart Curl:\n\n';
          text += '$curl\n';
          text += '\nEnd Curl\n\n';
        }
      }
    }
    text += '\n';
    if (failureInfo.response != null) {
      text += 'Request Headers:\n';
      text += '${failureInfo.response?.requestOptions.headers}\n';
      final curl = dio2curl(failureInfo.response?.requestOptions);
      if (curl != null) {
        text += '\nStart Curl:\n\n';
        text += '$curl\n';
        text += 'End Curl\n\n';
      }
      text += 'Response:\n';
      text += 'Status: ${failureInfo.response?.statusCode}\n';
      text += 'Response Headers:\n';
      text += '${failureInfo.response?.headers}\n';
      text += 'Data:\n';
      text += '${failureInfo.response?.data}\n';
    }
    text += '\n';
    text = text.replaceAll('{', '{\n');
    text = text.replaceAll(',', ',\n');
    text = text.replaceAll('}', '\n}');

    return base64.encode(utf8.encode(text));
  }

  Future<File> toFile() async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/ErrorReposrt-$id.txt');
    final report = await generateReport();
    await file.writeAsString(report);
    return file;
  }
}

class ValidationFailure extends Failure {
  ValidationFailure(this.valueKey, this.value);

  final String valueKey;
  final String value;

  @override
  List<Object?> get props => [valueKey];
}

class ErrorFailure extends Failure {
  ErrorFailure({required this.errorStatus, required this.error});

  final ErrorStatus errorStatus;
  final ResponseModel error;

  @override
  List<Object?> get props => [errorStatus, error];
}

class ConnectionFailure extends Failure {
  ConnectionFailure();
  @override
  List<Object?> get props => [];
}

class SessionEndedFailure extends Failure {
  SessionEndedFailure();

  @override
  List<Object?> get props => [];
}

class RequestCanceledFailure extends Failure {
  RequestCanceledFailure();

  @override
  List<Object?> get props => [];
}

class TypeFailure extends ReportableFailure {
  TypeFailure(FailureInfo failureInfo, [this.data])
      : super(
          failureInfo: failureInfo,
          type: 'TypeError',
        );

  final dynamic data;

  @override
  List<Object?> get props => [];
}

class ServiceNotAvailableFailure extends ReportableFailure {
  ServiceNotAvailableFailure(FailureInfo failureInfo)
      : super(
          failureInfo: failureInfo,
          type: 'Service Not Available',
        );

  @override
  List<Object?> get props => [];
}

class UnkownFailure extends ReportableFailure {
  UnkownFailure(FailureInfo failureInfo)
      : super(
          failureInfo: failureInfo,
          type: 'Unkown Failure',
        );
  @override
  List<Object?> get props => [];
}

class FailureInfo {
  FailureInfo({
    this.request,
    this.response,
    this.exception,
  });

  final Request? request;
  final Response? response;
  final dynamic exception;
}
