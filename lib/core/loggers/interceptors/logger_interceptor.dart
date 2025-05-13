import 'dart:io';
import 'package:dio/dio.dart';
import 'package:promoter_app/core/loggers/logger_cubit/logger_cubit.dart';

/// Interceptor that logs all Dio requests, responses, and errors using LoggerCubit
class LoggerInterceptor extends Interceptor {
  final LoggerCubit loggerCubit;

  LoggerInterceptor({required this.loggerCubit});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    loggerCubit.logRequest(options);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    loggerCubit.logResponse(response);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    loggerCubit.logError(err);
    super.onError(err, handler);
  }
}
