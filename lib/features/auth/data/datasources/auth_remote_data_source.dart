import 'dart:developer';

import 'package:promoter_app/core/error/exceptions.dart';
import 'package:promoter_app/core/network/api_client.dart';
import 'package:promoter_app/features/auth/data/models/token_model.dart';
import 'package:promoter_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// The API client used for making requests
  ApiClient get client;

  /// Calls the API endpoint to login a user.
  ///
  /// Throws a [ServerException], [UnauthorizedException], or [ApiException] for all error codes.
  /// Returns a tuple containing the user model and token model.
  Future<(UserModel, TokenModel)> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  final ApiClient client;

  AuthRemoteDataSourceImpl({required this.client});
  @override
  Future<(UserModel, TokenModel)> login(String email, String password) async {
    try {
      final response = await client.post(
        '/auth/login',
        data: {
          'phone': email,
          'password': password,
        },
      );
      print("Mahmoud Sub");
      if (response == null) {
        throw ApiException(message: 'No response from server');
      }

      // Extract user data
      Map<String, dynamic> userData;
      if (response['data'] != null && response['data'] is Map<String, dynamic>) {
        userData = response['data'];
        log('User data: $userData');
      } else if (response['user'] != null && response['user'] is Map<String, dynamic>) {
        userData = response['user'];
        log('User data: $userData');
      } else {
        throw ApiException(message: 'Invalid user data format in response');
      }

      print("Mahmoud Sub221");
      // Extract token data
      String token;
      if (response['access_token'] != null) {
        token = response['access_token'];
      } else if (response['token'] != null) {
        token = response['token'];
      } else if (response['data']?['token'] != null) {
        token = response['data']['token'];
      } else if (response['user']?['token'] != null) {
        token = response['user']['token'];
      } else {
        throw ApiException(message: 'No token found in response');
      }
      print("Mahmoud Sub22");
      // Create user and token models
      final userModel = UserModel.fromJson(userData);
      final tokenModel = TokenModel(accessToken: token);
      print("Mahmoud Sub111");
      return (userModel, tokenModel);
    } catch (e) {
      // Let the repository handle the error
      rethrow;
    }
  }
}
