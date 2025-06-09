import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/di/injection_container.dart';
import '../models/client_model.dart';
import '../models/location_models.dart';

class ClientService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ClientService({ApiClient? apiClient}) : _apiClient = apiClient ?? sl();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Get Egyptian states
  List<State> getEgyptStates() {
    return egyptStates;
  }

  // Fetch states from API
  Future<List<State>> fetchStates() async {
    try {
      final response = await _apiClient.get('/get-states');

      if (response != null && response['data'] != null) {
        // Handle potential pagination format
        final statesData = response['data'] is List
            ? response['data']
            : response['data']['data'] ?? [];

        return List<State>.from(statesData
            .map((state) => State(id: state['id'], name: state['name'])));
      }

      // Fall back to hardcoded data if API fails
      return egyptStates;
    } catch (e) {
      print('Error fetching states: $e');
      return egyptStates;
    }
  }

  // Get cities for a specific state
  List<City> getCitiesByState(int stateId) {
    return egyptCities.where((city) => city.stateId == stateId).toList();
  }

  // Fetch cities by state from API
  Future<List<City>> fetchCitiesByState(int stateId) async {
    try {
      // Assuming the API follows REST conventions: /get-cities?state_id=X
      final response = await _apiClient.get('/get-cities?state_id=$stateId');

      if (response != null && response['data'] != null) {
        final citiesData = response['data'] is List
            ? response['data']
            : response['data']['data'] ?? [];

        return List<City>.from(citiesData.map((city) =>
            City(id: city['id'], name: city['name'], stateId: stateId)));
      }

      // Fall back to hardcoded data if API fails
      return getCitiesByState(stateId);
    } catch (e) {
      print('Error fetching cities: $e');
      return getCitiesByState(stateId);
    }
  }

  // Get all cities
  List<City> getAllCities() {
    return egyptCities;
  }

  // Get work types
  List<WorkType> getWorkTypes() {
    return workTypes;
  }

  // Fetch work types from API
  Future<List<WorkType>> fetchWorkTypes() async {
    try {
      final response = await _apiClient.get('/get-type-of-work');

      if (response != null && response['data'] != null) {
        final typesData = response['data'] is List
            ? response['data']
            : response['data']['data'] ?? [];

        return List<WorkType>.from(typesData
            .map((type) => WorkType(id: type['id'], name: type['name'])));
      }

      // Fall back to hardcoded data if API fails
      return workTypes;
    } catch (e) {
      print('Error fetching work types: $e');
      return workTypes;
    }
  }

  // Fetch responsible persons from API
  Future<List<Responsible>> fetchResponsibles() async {
    try {
      final response = await _apiClient.get('/get-responsible');

      if (response != null && response['data'] != null) {
        final responsiblesData = response['data'] is List
            ? response['data']
            : response['data']['data'] ?? [];

        return List<Responsible>.from(responsiblesData.map(
            (person) => Responsible(id: person['id'], name: person['name'])));
      }

      // Return empty list if API fails
      return [];
    } catch (e) {
      print('Error fetching responsibles: $e');
      return [];
    }
  }

  Future<List<Client>> getClients() async {
    final response = await _apiClient.get('/get-clients');

    // Handle direct list response format
    if (response is List) {
      return response.map((json) => _mapJsonToClient(json)).toList();
    }

    // Handle nested pagination format from API: data -> data -> [clients]
    if (response['data'] != null &&
        response['data']['data'] != null &&
        response['data']['data'] is List) {
      final List<dynamic> clientsData = response['data']['data'];
      return clientsData.map((json) => _mapJsonToClient(json)).toList();
    }

    // Handle alternative format: data -> [clients]
    if (response['data'] != null && response['data'] is List) {
      final List<dynamic> clientsData = response['data'];
      return clientsData.map((json) => _mapJsonToClient(json)).toList();
    }

    // Return empty list if format is unexpected
    return [];
  }

  Future<Client> createClient({
    required String name,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    String code = '',
    int responsibleId = 1,
    int stateId = 1,
    int cityId = 1,
    int typeOfWorkId = 1,
  }) async {
    final data = {
      'name': name,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'lat': latitude,
      'long': longitude,
      'Lat': latitude,
      'Long': longitude,
      'code': code,
      'responsible_id': responsibleId,
      'state_id': stateId,
      'city_id': cityId,
      'type_of_work_id': typeOfWorkId,
    };

    final response = await _apiClient.post('/new-client', data: data);

    // Parse response based on API format
    final clientData = response['data'] ?? response;
    return _mapJsonToClient(clientData);
  }

  Future<void> updateClientStatus(int clientId, VisitStatus status) async {
    String statusValue;
    switch (status) {
      case VisitStatus.visited:
        statusValue = 'visited';
        break;
      case VisitStatus.notVisited:
        statusValue = 'not_visited';
        break;
      case VisitStatus.postponed:
        statusValue = 'postponed';
        break;
    }

    await _apiClient.put(
      '/clients/$clientId/status',
      data: {'status': statusValue},
    );
  } // Helper method to map JSON to Client model

  Client _mapJsonToClient(Map<String, dynamic> json) {
    // Extract state and city info from nested objects if available
    int? stateId = json['state_id'];
    int? cityId = json['city_id'];

    // Handle nested state object if present
    if (json['state'] != null && json['state'] is Map) {
      stateId = json['state']['id'];
    }

    // Handle nested city object if present
    if (json['city'] != null && json['city'] is Map) {
      cityId = json['city']['id'];
    }

    // Parse address - use a default value if missing
    String address = json['address'] ?? '';

    // If address is still empty and we have state/city info, try to create a basic address
    if (address.isEmpty && (stateId != null || cityId != null)) {
      String stateName = '';
      String cityName = '';

      if (json['state'] != null && json['state']['name'] != null) {
        stateName = json['state']['name'];
      }

      if (json['city'] != null && json['city']['name'] != null) {
        cityName = json['city']['name'];
      }

      // Construct a basic address from available location info
      if (cityName.isNotEmpty || stateName.isNotEmpty) {
        address =
            [cityName, stateName].where((part) => part.isNotEmpty).join(', ');
      }
    }

    // Handle different API response formats
    return Client(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: address,
      code: json['code'], // Add code
      stateId: stateId, // State ID from direct field or nested object
      cityId: cityId, // City ID from direct field or nested object
      typeOfWorkId: json['type_of_work_id'], // Add type_of_work_id
      responsibleId: json['responsible_id'], // Add responsible_id
      balance: json['balance']?.toDouble() ?? 0.0,
      lastPurchase: json['last_purchase'] ??
          json['created_at']?.toString().split('T')[0] ??
          DateTime.now().toString().split(' ')[0],
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ??
          double.tryParse(json['lat']?.toString() ?? '') ??
          double.tryParse(json['Lat']?.toString() ?? '') ??
          0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ??
          double.tryParse(json['lon']?.toString() ?? '') ??
          double.tryParse(json['Long']?.toString() ?? '') ??
          0.0,
      visitStatus: _mapApiStatusToModel(json['status'] ?? ''),
      distanceToPromoter: json['distance']?.toDouble() ?? 0.0,
    );
  }

  // Helper method to map API status string to VisitStatus enum
  VisitStatus _mapApiStatusToModel(String status) {
    switch (status.toLowerCase()) {
      case 'visited':
        return VisitStatus.visited;
      case 'not_visited':
      case 'notvisited':
        return VisitStatus.notVisited;
      case 'postponed':
        return VisitStatus.postponed;
      default:
        return VisitStatus.notVisited;
    }
  }
}
