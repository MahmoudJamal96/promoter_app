import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/client_model.dart';
import '../services/location_service.dart';

class ClientProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  List<Client> _clients = [];
  List<Client> _sortedClients = [];
  Position? _promoterPosition;
  bool _isLoading = true;
  String _searchQuery = '';
  VisitStatus? _filterStatus;
  StreamSubscription<Position>? _positionSubscription;

  // Getters
  List<Client> get clients => _clients;
  List<Client> get sortedClients => _sortedClients;
  Position? get promoterPosition => _promoterPosition;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  VisitStatus? get filterStatus => _filterStatus;

  ClientProvider() {
    _initializeLocationAndClients();
  }

  Future<void> _initializeLocationAndClients() async {
    try {
      await _locationService.initialize();
      _promoterPosition = _locationService.currentPosition;

      // Listen for position updates
      _positionSubscription =
          _locationService.positionStream.listen((position) {
        _promoterPosition = position;
        if (_clients.isNotEmpty) {
          _sortClientsByDistance();
        }
        notifyListeners();
      });

      // Load mock clients
      _loadMockClients();
    } catch (e) {
      // Handle errors
      print('Error initializing location: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadMockClients() {
    // Mock clients with coordinates
    _clients = [
      Client(
        id: 1,
        name: 'أحمد محمود',
        phone: '01012345678',
        address: 'القاهرة، مصر',
        balance: 500.0,
        lastPurchase: '2025-04-20',
        latitude: 30.0444, // Cairo coordinates
        longitude: 31.2357,
        visitStatus: VisitStatus.visited,
      ),
      Client(
        id: 2,
        name: 'محمد عبدالله',
        phone: '01098765432',
        address: 'الإسكندرية، مصر',
        balance: 1200.0,
        lastPurchase: '2025-04-15',
        latitude: 31.2001, // Alexandria coordinates
        longitude: 29.9187,
        visitStatus: VisitStatus.notVisited,
      ),
      Client(
        id: 3,
        name: 'سارة أحمد',
        phone: '01112233445',
        address: 'طنطا، مصر',
        balance: 0.0,
        lastPurchase: '2025-04-22',
        latitude: 30.7865, // Tanta coordinates
        longitude: 31.0004,
        visitStatus: VisitStatus.postponed,
      ),
      Client(
        id: 4,
        name: 'حسين علي',
        phone: '01023456789',
        address: 'المنصورة، مصر',
        balance: 750.0,
        lastPurchase: '2025-04-05',
        latitude: 31.0409, // Mansoura coordinates
        longitude: 31.3785,
        visitStatus: VisitStatus.notVisited,
      ),
      Client(
        id: 5,
        name: 'فاطمة محمد',
        phone: '01034567890',
        address: 'أسيوط، مصر',
        balance: 300.0,
        lastPurchase: '2025-04-18',
        latitude: 27.1783, // Assiut coordinates
        longitude: 31.1859,
        visitStatus: VisitStatus.visited,
      ),
    ];

    _sortClientsByDistance();
    _isLoading = false;
    notifyListeners();
  }

  void _sortClientsByDistance() {
    if (_promoterPosition == null) return;

    _sortedClients = _locationService.sortClientsByDistance(
      _clients,
      _promoterPosition!,
    );

    notifyListeners();
  }

  List<Client> getFilteredClients() {
    List<Client> result = _sortedClients.isEmpty ? _clients : _sortedClients;

    if (_searchQuery.isNotEmpty) {
      result = result.where((client) {
        final name = client.name.toLowerCase();
        final phone = client.phone?.toLowerCase() ?? "";
        final address = client.address.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) ||
            phone.contains(query) ||
            address.contains(query);
      }).toList();
    }

    if (_filterStatus != null) {
      result = result
          .where((client) => client.visitStatus == _filterStatus)
          .toList();
    }

    return result;
  }

  double calculateTotalBalance() {
    return _clients.fold(0, (total, client) => total + client.balance);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(VisitStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void addClient(Client client) {
    _clients.add(client);
    _sortClientsByDistance();
    notifyListeners();
  }

  void updateClientStatus(int clientId, VisitStatus status) {
    final index = _clients.indexWhere((c) => c.id == clientId);
    if (index != -1) {
      _clients[index] = _clients[index].copyWith(visitStatus: status);
      _sortClientsByDistance();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
