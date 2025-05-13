part of 'logger_cubit.dart';

abstract class LoggerState {
  const LoggerState();
}

class LoggerInitial extends LoggerState {}

class LoggerRequestSent extends LoggerState {
  final RequestOptions options;

  LoggerRequestSent(this.options);
}

class LoggerResponseReceived extends LoggerState {
  final Response response;

  LoggerResponseReceived(this.response);
}

class LoggerErrorOccurred extends LoggerState {
  final DioException error;

  LoggerErrorOccurred(this.error);
}

class LoggerGeneralError extends LoggerState {
  final String message;
  final StackTrace stackTrace;

  LoggerGeneralError(this.message, this.stackTrace);
}
