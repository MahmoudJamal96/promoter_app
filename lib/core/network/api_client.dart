import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:promoter_app/core/constants/api_constants.dart';
import 'package:promoter_app/core/error/exceptions.dart';
import 'package:promoter_app/core/loggers/interceptors/logger_interceptor.dart';
import 'package:promoter_app/core/loggers/logger_cubit/logger_cubit.dart';
import 'package:promoter_app/core/utils/request_to_curl.dart';

class ApiClient {
  final Dio dio;
  final Logger logger;
  late LoggerCubit loggerCubit;

  ApiClient({required this.dio, required this.logger}) {
    loggerCubit = LoggerCubit(logger: logger, tag: 'API');

    dio.options.baseUrl = ApiConstants.BASE_URL;
    dio.options.connectTimeout =
        Duration(seconds: ApiConstants.CONNECTION_TIMEOUT);
    dio.options.receiveTimeout =
        Duration(seconds: ApiConstants.RECEIVE_TIMEOUT);

    dio.interceptors.add(LoggerInterceptor(loggerCubit: loggerCubit));
  }

  void setToken(String token) {
    dio.options.headers[ApiConstants.AUTH_HEADER] =
        '${ApiConstants.BEARER_PREFIX}$token';
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      // Use simple logging to avoid console flooding
      print("GET $path completed with status: ${response.statusCode}");

      return response.data;
    } on DioException catch (e) {
      return _handleDioError(e, path);
    } catch (e) {
      return _handleError(e, path);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      // Generate cURL for easy debugging when needed
      // final curl = request2curl(
      //   path: path,
      //   method: 'POST',
      //   data: data,
      //   queryParameters: queryParameters,
      // );
      // logger.d('cURL equivalent: $curl');

      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      // Use simple logging to avoid console flooding
      print("POST $path completed with status: ${response.statusCode}");

      return response.data;
    } on DioException catch (e) {
      return _handleDioError(e, path);
    } catch (e) {
      return _handleError(e, path);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      // Use simple logging to avoid console flooding
      print("PUT $path completed with status: ${response.statusCode}");

      return response.data;
    } on DioException catch (e) {
      return _handleDioError(e, path);
    } catch (e) {
      return _handleError(e, path);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      // Use simple logging to avoid console flooding
      print("DELETE $path completed with status: ${response.statusCode}");

      return response.data;
    } on DioException catch (e) {
      return _handleDioError(e, path);
    } catch (e) {
      return _handleError(e, path);
    }
  }

  dynamic _handleDioError(DioException e, String path) {
    try {
      // Use LoggerCubit instead of just logger
      loggerCubit.logError(e);
    } catch (loggingError) {
      // If logging fails, fall back to simple console logging
      print('Failed to log error: $loggingError');
      print('Original error in $path: ${e.message}');
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final errorData = e.response?.data;

        if (statusCode == 401) {
          throw UnauthorizedException();
        } else if (statusCode == 404) {
          throw NotFoundException();
        } else if (statusCode != null && statusCode >= 500) {
          throw ServerException();
        } else {
          String errorMessage = 'Unknown error';
          int errorCode = statusCode ?? 0;

          // Safely extract error message from response data
          if (errorData != null && errorData is Map<String, dynamic>) {
            errorMessage = errorData['message']?.toString() ?? errorMessage;
            errorCode = errorData['code'] is num
                ? (errorData['code'] as num).toInt()
                : errorCode;
          }

          throw ApiException(message: errorMessage, code: errorCode);
        }
      case DioExceptionType.cancel:
        throw RequestCancelledException();
      case DioExceptionType.connectionError:
        throw NoInternetConnectionException();
      default:
        throw ApiException(message: e.message ?? 'Unknown error');
    }
  }

  dynamic _handleError(Object e, String path) {
    try {
      // Log general errors with LoggerCubit
      loggerCubit.logGeneralError(e, StackTrace.current);
    } catch (loggingError) {
      // Fallback to basic console logging if LoggerCubit fails
      print('Failed to log error with LoggerCubit: $loggingError');
    }

    // Print to console for easier debugging during development
    print('API Error in $path: $e');

    if (e is SocketException) {
      throw NoInternetConnectionException();
    } else if (e is FormatException) {
      throw ApiException(message: 'Invalid response format: ${e.message}');
    } else if (e is TypeError) {
      throw ApiException(message: 'Data type error: ${e.toString()}');
    }

    try {
      throw ApiException(message: e.toString());
    } catch (exceptionError) {
      // If toString() causes issues, fall back to a generic error message
      throw ApiException(message: 'An unknown error occurred');
    }
  }
}
