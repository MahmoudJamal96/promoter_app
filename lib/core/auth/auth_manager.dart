import 'package:promoter_app/core/network/api_client.dart';
import 'package:promoter_app/features/auth/data/datasources/auth_local_data_source.dart';

class AuthManager {
  final AuthLocalDataSource localDataSource;
  final ApiClient apiClient;

  AuthManager({
    required this.localDataSource,
    required this.apiClient,
  });

  /// Initializes the auth state by checking for a stored token
  /// and setting it in the API client if found
  Future<bool> initializeAuth() async {
    try {
      final token = await localDataSource.getToken();

      if (token != null) {
        apiClient.setToken(token.accessToken);
        return true;
      }

      return false;
    } catch (e) {
      print('Error initializing auth: $e');
      return false;
    }
  }
}
