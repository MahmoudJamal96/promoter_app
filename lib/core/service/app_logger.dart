import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

bool get shouldLog => !kReleaseMode;

class AppLogger {
  AppLogger._();

  static var _instance = AppLogger._();

  static AppLogger get instance => _instance;

  static void newInstance() => _instance = AppLogger._();
  final _logger = Logger();

  // final _alice =
  //     (AppFlavor.appFlavor != Flavors.production || kDebugMode) && !testMode
  //         ? Alice(
  //             showInspectorOnShake: true,
  //           )
  //         : null;

  // AliceDioInterceptor? get aliceInterceptor => _alice?.getDioInterceptor();
  // GlobalKey<NavigatorState>? get navigatorKey => _alice?.getNavigatorKey();

  void log(String message, {
    LogLevel? logLevel,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (shouldLog) {
      _logger.log(
        logLevel.toLevel(),
        message,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  nothing,
}

extension LogLevelExtention on LogLevel? {
  Level toLevel() {
    switch (this) {
      case null:
      case LogLevel.verbose:
        return Level.verbose;
      case LogLevel.debug:
        return Level.debug;
      case LogLevel.info:
        return Level.info;
      case LogLevel.warning:
        return Level.warning;
      case LogLevel.error:
        return Level.error;
      case LogLevel.nothing:
        return Level.nothing;
    }
  }
}
