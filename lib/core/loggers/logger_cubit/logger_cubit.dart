import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promoter_app/core/error/failures.dart';
import 'package:logger/logger.dart';

part 'logger_state.dart';

/// A Cubit that handles logging of HTTP requests and responses
/// This is used to log all network activity in the app
class LoggerCubit extends Cubit<LoggerState> {
  final Logger logger;
  final String tag;

  LoggerCubit({
    required this.logger,
    required this.tag,
  }) : super(LoggerInitial());

  /// Log an HTTP request
  void logRequest(RequestOptions options) {
    // logger.i('API Request [$tag] - ${options.method} ${options.path}');
    // logger.d('Headers: ${options.headers}');
    // logger.d('Data: ${options.data}');
    // logger.d('Query Parameters: ${options.queryParameters}');

    emit(LoggerRequestSent(options));
  }

  /// Log an HTTP response
  void logResponse(Response response) {
    // logger.i(
    //     'API Response [$tag] - ${response.requestOptions.method} ${response.requestOptions.path}');
    // logger.i('Status: ${response.statusCode}');
    // logger.d('Headers: ${response.headers.map}');
    // logger.d('Data: ${response.data}');

    emit(LoggerResponseReceived(response));
  }

  /// Log an HTTP error
  void logError(DioException error) {
    // logger.e(
    //   'API Error [$tag] - ${error.requestOptions.method} ${error.requestOptions.path}',
    //   error: error,
    //   stackTrace: error.stackTrace,
    // );
    // logger.e('Status: ${error.response?.statusCode}');
    // logger.e('Error: ${error.message}');
    // logger.e('Error Data: ${error.response?.data}');

    emit(LoggerErrorOccurred(error));
  }

  /// Log a general error
  void logGeneralError(Object error, StackTrace stackTrace) {
    // logger.e(
    //   'General Error [$tag]',
    //   error: error,
    //   stackTrace: stackTrace,
    // );

    emit(LoggerGeneralError(error.toString(), stackTrace));
  }
}
