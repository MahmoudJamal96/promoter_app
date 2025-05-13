class ServerException implements Exception {}

class NoInternetConnectionException implements Exception {}

class CacheException implements Exception {}

class TimeoutException implements Exception {}

class UnauthorizedException implements Exception {}

class NotFoundException implements Exception {}

class RequestCancelledException implements Exception {}

class ApiException implements Exception {
  final String message;
  final int code;

  ApiException({required this.message, this.code = 0});

  @override
  String toString() => 'ApiException: $message (Code: $code)';
}
