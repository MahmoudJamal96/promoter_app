import 'dart:convert';
import 'package:promoter_app/core/error/exceptions.dart';
import 'package:promoter_app/features/auth/data/models/token_model.dart';
import 'package:promoter_app/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  /// Gets the cached [UserModel] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<UserModel> getLastUser();

  /// Caches the [UserModel] and sets isLoggedIn to true.
  Future<void> cacheUser(UserModel userToCache);

  /// Caches the auth token
  Future<void> cacheToken(TokenModel tokenToCache);

  /// Gets the cached auth token
  Future<TokenModel?> getToken();

  /// Clears the cached user data and sets isLoggedIn to false.
  Future<void> clearUserCache();
}

const CACHED_USER = 'CACHED_USER';
const CACHED_TOKEN = 'CACHED_TOKEN';
const IS_LOGGED_IN = 'IS_LOGGED_IN';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel> getLastUser() {
    final jsonString = sharedPreferences.getString(CACHED_USER);
    if (jsonString != null) {
      return Future.value(UserModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheUser(UserModel userToCache) {
    return Future.wait([
      sharedPreferences.setString(
        CACHED_USER,
        json.encode(userToCache.toJson()),
      ),
      sharedPreferences.setBool(IS_LOGGED_IN, true),
    ]);
  }

  @override
  Future<void> cacheToken(TokenModel tokenToCache) {
    return sharedPreferences.setString(
      CACHED_TOKEN,
      json.encode(tokenToCache.toJson()),
    );
  }

  @override
  Future<TokenModel?> getToken() async {
    final jsonString = sharedPreferences.getString(CACHED_TOKEN);
    if (jsonString != null) {
      return TokenModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> clearUserCache() {
    return Future.wait([
      sharedPreferences.remove(CACHED_USER),
      sharedPreferences.remove(CACHED_TOKEN),
      sharedPreferences.setBool(IS_LOGGED_IN, false),
    ]);
  }
}
