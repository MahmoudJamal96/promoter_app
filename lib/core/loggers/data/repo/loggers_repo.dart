import 'package:promoter_app/qara_ksa.dart';

import '../model/loggers_base.dart';
import '../profile_api.dart';
import '../request/logger_http_request.dart';
import '../request/poster_http_request.dart';

class LoggersRepo {
  // ignore: unused_field
  final APIsManager _apIsManager;

  LoggersRepo(this._apIsManager);

  Future<Either<Failure, LoggersBase>> log(LoggersBase logger, ProfileApi profile,
      {Map<String, dynamic>? query, Map<String, dynamic>? mockResponse}) async {
    final result = await _apIsManager.send(
      request: LoggersHttpRequestModel(profile, query: query),
      responseFromMap: (map) => logger.fromMap(map),
    );
    return result;
  }


  Future<Either<Failure, LoggersBase>> post(LoggersBase logger, ProfileApi profile,
      {required RequestModel requestModel,
        Map<String, dynamic>? query,
        Map<String, dynamic>? mockResponse}) async {
    final result = await _apIsManager.send(
      request: PosterHttpRequestModel(profile, requestModel, query: query),
      responseFromMap: logger.fromMap,
    );
    return result;
  }
}
