import 'package:promoter_app/core/data/models/request_model.dart';
import 'package:promoter_app/core/data/request/base_request.dart';

import '../profile_api.dart';

class PosterHttpRequestModel with Request, PostRequest {
  final ProfileApi profile;
  final Map<String, dynamic>? query;
  final RequestModel _requestModel;

  PosterHttpRequestModel(this.profile, this._requestModel, {this.query});

  @override
  String get path => profile.path;

  @override
  Future<Map<String, dynamic>?> get queryParameters async => query;

  @override
  RequestModel get requestModel => _requestModel;
}
