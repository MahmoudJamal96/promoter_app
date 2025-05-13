import 'package:promoter_app/core/data/request/base_request.dart';

import '../profile_api.dart';

class LoggersHttpRequestModel with Request, GetRequest {
  final ProfileApi profile;
  final Map<String, dynamic>? query;

  LoggersHttpRequestModel(this.profile, {this.query});

  @override
  String get path => profile.path;

  @override
  Future<Map<String, dynamic>?> get queryParameters async => query;
}
