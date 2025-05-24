import '../../../core/network/api_client.dart';
import '../../../core/di/injection_container.dart';
import '../models/client_model.dart';

class ClientApiService {
  final ApiClient _apiClient;

  ClientApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? sl();

  // Get clients from API
  Future<List<Client>> getClients() async {
    try {
      final response = await _apiClient.get('/get-clients');

      if (response == null) {
        throw Exception('Failed to load clients: Empty response');
      }

      final List<dynamic> clientsData = response['data'] ?? [];
      return clientsData.map((json) => Client.fromJson(json)).toList();
    } catch (e) {
      print('Error getting clients: $e');
      rethrow;
    }
  }
}
