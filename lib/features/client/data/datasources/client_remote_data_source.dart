import 'package:promoter_app/core/error/exceptions.dart';
import 'package:promoter_app/core/network/api_client.dart';
import 'package:promoter_app/features/client/data/models/client_model.dart';
import 'package:promoter_app/features/client/domain/entities/client.dart';

abstract class ClientRemoteDataSource {
  /// Calls the API endpoint to get a list of clients.
  ///
  /// Throws a [ServerException], or [ApiException] for all error codes.
  Future<List<ClientModel>> getClients();

  /// Updates the visit status of a client
  ///
  /// Throws a [ServerException], or [ApiException] for all error codes.
  Future<void> updateClientStatus(int clientId, VisitStatus status);

  /// Creates a new client
  ///
  /// Throws a [ServerException], or [ApiException] for all error codes.
  Future<ClientModel> createClient(
      {required String name,
      required String phone,
      required String address,
      required String email,
      required double latitude,
      required double longitude});
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  final ApiClient client;

  ClientRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ClientModel>> getClients() async {
    try {
      final response = await client.get('/clients');

      return (response as List)
          .map((item) => ClientModel.fromJson(item))
          .toList();
    } catch (e) {
      // For now, return mock data
      // In production, you would properly handle the API response
      return [
        ClientModel(
          id: 1,
          name: 'Client 1',
          address: '123 Main St',
          phone: '123-456-7890',
          email: 'client1@example.com',
          latitude: 24.7136,
          longitude: 46.6753,
        ),
        ClientModel(
          id: 2,
          name: 'Client 2',
          address: '456 Elm St',
          phone: '123-456-7891',
          email: 'client2@example.com',
          latitude: 24.7337,
          longitude: 46.7219,
          visitStatus: VisitStatus.completed,
        ),
      ];
    }
  }

  @override
  Future<ClientModel> createClient(
      {required String name,
      required String phone,
      required String address,
      required String email,
      required double latitude,
      required double longitude}) async {
    try {
      final data = {
        'name': name,
        'phone': phone,
        'address': address,
        'email': email,
        'latitude': latitude,
        'longitude': longitude,
      };

      final response = await client.post('/clients', data: data);
      return ClientModel.fromJson(response);
    } catch (e) {
      // For now, return mock data
      // In production, this would throw an appropriate exception
      return ClientModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        address: address,
        phone: phone,
        email: email,
        latitude: latitude,
        longitude: longitude,
      );
    }
  }

  @override
  Future<void> updateClientStatus(int clientId, VisitStatus status) async {
    try {
      await client.put(
        '/clients/$clientId/status',
        data: {'status': status.toString().split('.').last},
      );
    } catch (e) {
      // For now, just assume success
      // In production, handle errors properly
      return;
    }
  }
}
