enum ErrorStatus {
  validationError,
  authorizationError,
  authenticationError,
  resourceNotFoundError,
  methodNotAllowedError,
  updateVersionError,
  unknownError,
}

enum HTTPCodes {
  success,
  error,
  invalidToken,
  serviceNotAvailable,
  unknown,
}

class StatusChecker {
  final success = [200, 201, 202, 204];
  final validationError = [400, 406, 409, 422];
  final authorizationError = [401];
  final authenticationError = [403];
  final methodNotAllowedError = [405];
  final resourceNotFoundError = [410];

  // final invalidToken = [406];
  final updateVersion = [451];
  final serviceNotAvailable = [404, ..._range(500, 599)];

  HTTPCodes call(int? statusCode) {
    final error = validationError +
        // authorizationError +
        resourceNotFoundError +
        methodNotAllowedError;

    final authError = authorizationError + authenticationError;
    if (success.contains(statusCode)) return HTTPCodes.success;
    if (error.contains(statusCode)) return HTTPCodes.error;
    if (authError.contains(statusCode)) return HTTPCodes.invalidToken;
    if (serviceNotAvailable.contains(statusCode)) {
      return HTTPCodes.serviceNotAvailable;
    }
    if (updateVersion.contains(statusCode)) return HTTPCodes.error;

    return HTTPCodes.unknown;
  }

  ErrorStatus getErrorState(int? statusCode) {
    if (validationError.contains(statusCode)) {
      return ErrorStatus.validationError;
    } else if (authorizationError.contains(statusCode)) {
      return ErrorStatus.authorizationError;
    } else if (authenticationError.contains(statusCode)) {
      return ErrorStatus.authenticationError;
    } else if (resourceNotFoundError.contains(statusCode)) {
      return ErrorStatus.resourceNotFoundError;
    } else if (methodNotAllowedError.contains(statusCode)) {
      return ErrorStatus.methodNotAllowedError;
    } else if (updateVersion.contains(statusCode)) {
      return ErrorStatus.updateVersionError;
    }
    return ErrorStatus.unknownError;
  }
}

Iterable<int> _range(int from, int to) =>
    Iterable<int>.generate(to - from + 1, (i) => i + from);
