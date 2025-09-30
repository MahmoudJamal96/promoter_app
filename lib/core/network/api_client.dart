import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:promoter_app/core/constants/api_constants.dart';
import 'package:promoter_app/core/error/exceptions.dart';
import 'package:promoter_app/core/loggers/interceptors/logger_interceptor.dart';
import 'package:promoter_app/core/loggers/logger_cubit/logger_cubit.dart';
import 'package:promoter_app/features/auth/screens/login_screen.dart';
import 'package:promoter_app/main.dart';

class ApiClient {
  final Dio dio;
  final Logger logger;
  late LoggerCubit loggerCubit;

  // Add callback for handling logout
  final VoidCallback? onUnauthorized;
  // Add callback for clearing token
  final VoidCallback? onClearToken;

  ApiClient({
    required this.dio,
    required this.logger,
    this.onUnauthorized,
    this.onClearToken,
  }) {
    loggerCubit = LoggerCubit(logger: logger, tag: 'API');

    dio.options.baseUrl = ApiConstants.BASE_URL;
    dio.options.connectTimeout = const Duration(seconds: ApiConstants.CONNECTION_TIMEOUT);
    dio.options.receiveTimeout = const Duration(seconds: ApiConstants.RECEIVE_TIMEOUT);

    dio.interceptors.add(LoggerInterceptor(loggerCubit: loggerCubit));
  }

  void setToken(String token) {
    dio.options.headers[ApiConstants.AUTH_HEADER] = '${ApiConstants.BEARER_PREFIX}$token';
  }

  void clearToken() {
    dio.options.headers.remove(ApiConstants.AUTH_HEADER);
    // Call the clear token callback if provided
    onClearToken?.call();
  }

  void _handle401Unauthorized() {
    // Clear the token
    clearToken();

    // Navigate to login screen
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
// show a snackbar or dialog if needed
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      const SnackBar(
        content: Text('يرجى تسجيل الدخول مرة أخرى'),
        duration: Duration(seconds: 2),
      ),
    );
    // Log the unauthorized access
    loggerCubit.logError(DioException(
      requestOptions: RequestOptions(path: ''),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 401,
        statusMessage: 'User session expired - redirecting to login',
      ),
    ));
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
          // Handle 401 unauthorized - clear token and navigate to login
          _handle401Unauthorized();
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
            errorCode = errorData['code'] is num ? (errorData['code'] as num).toInt() : errorCode;
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
