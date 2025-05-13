import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

// General failures
class ServerFailure extends Failure {
  final String message;

  ServerFailure({this.message = 'Server error'});

  @override
  List<Object> get props => [message];
}

class NoInternetFailure extends Failure {
  @override
  List<Object> get props => [];
}

class CacheFailure extends Failure {
  @override
  List<Object> get props => [];
}

class TimeoutFailure extends Failure {
  @override
  List<Object> get props => [];
}

class UnauthorizedFailure extends Failure {
  @override
  List<Object> get props => [];
}

class NotFoundFailure extends Failure {
  @override
  List<Object> get props => [];
}

class ApiFailure extends Failure {
  final String message;
  final int code;

  ApiFailure({required this.message, this.code = 0});

  @override
  List<Object> get props => [message, code];
}
