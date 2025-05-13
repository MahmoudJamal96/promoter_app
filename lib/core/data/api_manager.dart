// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/io.dart';
import 'package:promoter_app/qara_ksa.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../service/app_logger.dart';
import '../utils/request_to_curl.dart';
export 'exceptions.dart';
export 'failure_handler.dart';
export 'failures.dart';
export 'models/id_request_model.dart';
export 'models/message_response.dart';
export 'models/request_model.dart';
export 'models/response_model.dart';
export 'request/base_request.dart';
export 'status_checker.dart';

class APIsManager {
  APIsManager({
    this.interceptors = const [],
  }) {
    if (shouldLog) {
      _dio.interceptors.addAll(interceptors);
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
        ),
      );
    }
  }

  final StatusChecker _statusChecker = StatusChecker();
  final FailureHandler _failureHandler = FailureHandler();
  final Dio _dio = Dio();
  final List<Interceptor> interceptors;

  Future<Either<Failure, R>> send<R, ER extends ResponseModel>({
    required Request request,
    required R Function(Map<String, dynamic> map)? responseFromMap,
    ER Function(Map<String, dynamic> map)? errorResponseFromMap,
  }) async {
    Response<dynamic>? response;
    try {
      _dio.options.connectTimeout = const Duration(minutes: 1);
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };


      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
      // if (AppFlavor.appFlavor == Flavors.testing) _dio.interceptors.add(alice.getDioInterceptor());


      // if (AppFlavor.appFlavor == Flavor.qc) _dio.interceptors.add(alice.getDioInterceptor());

      response = await _dio.request(
        request.url,
        data: await request.data,
        queryParameters: await request.queryParameters,
        cancelToken: request.cancelToken,
        onSendProgress: request.requestModel.progressListener?.onSendProgress,
        onReceiveProgress: request.requestModel.progressListener?.onReceiveProgress,
        options: Options(
          headers: request.headers,
          sendTimeout: const Duration(milliseconds: 60 * 1000),
          receiveTimeout: const Duration(milliseconds: 60 * 1000),
          method: request.method,
        ),
      );

      dio2curl(response.requestOptions, isMultiPart: request.multiPart);
      var resp = response.data;

      if (resp is! Map<String, dynamic>) {
        dynamic mapResponse;
        try {
          mapResponse = json.decode(response.data);
        } catch (e) {
          e.toString();
        }
        if (mapResponse != null && mapResponse is Map) {
          resp = mapResponse;
        } else {
          resp = {'response': resp};
        }
      }
      return Right(responseFromMap!(resp));
    } on DioError catch (error) {
      // dio2curl(error.response?.requestOptions);
      if (error.type == DioErrorType.badResponse) {
        if (error.response?.statusCode != null && _statusChecker(error.response!.statusCode) == HTTPCodes.error) {
          try {
            Map<String, dynamic> errorData = {};
            if (error.response!.data is Map<String, dynamic>) {
              errorData = error.response!.data;
            } else {
              errorData = {'error': error.response!.data};
            }
            final exception = ErrorException(
                error.response!.statusCode!,
                errorResponseFromMap != null
                    ? errorResponseFromMap(errorData)
                    : MessageResponse.fromMap(error.response!.data)
                // : MessageResponse.fromMap(errorData,code:error.response!.statusCode.toString()),
                );
            return Left(
              _failureHandler.handle(
                request: request,
                exception: exception,
                response: error.response,
              ),
            );
          } catch (exception) {
            return Left(
              _failureHandler.handle(
                request: request,
                exception: exception,
                response: response,
              ),
            );
          }
        } else {
          final exception = ServerException(error.response);
          return Left(
            _failureHandler.handle(
              request: request,
              exception: exception,
              response: error.response,
            ),
          );
        }
      }
      return Left(
        _failureHandler.handle(
          request: request,
          exception: error,
          response: error.response,
        ),
      );
    } catch (exception) {
      dio2curl(response?.requestOptions, isMultiPart: request.multiPart);
      return Left(
        _failureHandler.handle(
          request: request,
          exception: exception,
          response: response,
        ),
      );
    }
  }
}
