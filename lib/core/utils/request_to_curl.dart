import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../data/request/base_request.dart';
import '../service/app_logger.dart';
import 'utils.dart';

String? dio2curl(RequestOptions? requestOption, {bool isMultiPart = false}) {
  if (requestOption == null) return null;
  var curl = '';
  // Add PATH + REQUEST_METHOD
  curl +=
  '''curl --request ${requestOption.method} '${requestOption.baseUrl}${requestOption.path}' ''';
  // Include queryParamters
  var buffer = StringBuffer();
  if (requestOption.queryParameters.isNotEmpty) {
    curl += '-G';
    requestOption.queryParameters.forEach((key, value) {
      buffer.write(' --data-urlencode "$key=$value"');
    });
    curl += buffer.toString();
  }
  // Include headers
  buffer = StringBuffer();
  for (final key in requestOption.headers.keys) {
    if (key == 'content-length') continue;
    buffer.write(" -H '$key: ${requestOption.headers[key]}'");
  }
  curl += buffer.toString();
  // Include data if there is data
  if (requestOption.data != null) {
    if (isMultiPart) {
      curl += " --data-binary '${requestOption.data}'";
    } else {
      curl += " --data-binary '${jsonEncode(requestOption.data)}'";
    }
  }
  if (shouldLog) log(curl);
  return curl;
}

Future<String?> request2curl(Request? request) async {
  if (request == null) return null;
  var curl = '';
  // Add PATH + REQUEST_METHOD
  curl +=
  '''curl --request ${request.method} '${request.baseUrl}${request.path}' ''';
  // Include queryParamters
  var buffer = StringBuffer();
  final queryParameters = await request.queryParameters ?? {};
  if (queryParameters.isNotEmpty) {
    curl += '-G';
    queryParameters.forEach((key, value) {
      buffer.write(' --data-urlencode "$key=$value"');
    });
    curl += buffer.toString();
  }
  final headers = request.headers ?? {};
  if (notNullNorEmpty(headers)) {
    // Include headers
    buffer = StringBuffer();
    for (final key in headers.keys) {
      if (key == 'content-length') continue;
      buffer.write(" -H '$key: ${headers[key]}'");
    }
    curl += buffer.toString();
  }
  // Include data if there is data
  if (notNullNorEmpty(request.data)) {
    curl += " --data-binary '${jsonEncode(request.data)}'";
  }
  if (shouldLog) log(curl);
  return curl;
}