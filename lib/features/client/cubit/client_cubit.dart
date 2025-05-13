import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:equatable/equatable.dart';
import '../models/client_model.dart';
import '../services/location_service.dart';

part 'client_state.dart';

class ClientCubit extends Cubit<ClientState> {
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _positionSubscription;

  ClientCubit() : super(const ClientInitial()) {
    _initializeLocationAndClients();
  }

  Future<void> _initializeLocationAndClients() async {
    emit(state.copyWith(isLoading: true));

    try {
      await _locationService.initialize();
      final position = _locationService.currentPosition;

      // Listen for position updates
      _positionSubscription =
          _locationService.positionStream.listen((position) {
        _updatePosition(position);
      });

      // Load mock clients
      _loadMockClients(position);
    } catch (e) {
      // Handle errors
      print('Error initializing location: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _loadMockClients(Position? position) {
    // Mock clients with coordinates
    final clients = [
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

    final sortedClients = position != null
        ? _locationService.sortClientsByDistance(clients, position)
        : clients;

    emit(ClientLoaded(
      clients: clients,
      sortedClients: sortedClients,
      promoterPosition: position,
      searchQuery: '',
      filterStatus: null,
    ));
  }

  void _updatePosition(Position position) {
    if (state is ClientLoaded) {
      final currentState = state as ClientLoaded;
      final sortedClients = _locationService.sortClientsByDistance(
        currentState.clients,
        position,
      );

      emit(currentState.copyWith(
        sortedClients: sortedClients,
        promoterPosition: position,
      ));
    }
  }

  void setSearchQuery(String query) {
    if (state is ClientLoaded) {
      final currentState = state as ClientLoaded;
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  void setFilterStatus(VisitStatus? status) {
    if (state is ClientLoaded) {
      final currentState = state as ClientLoaded;
      emit(currentState.copyWith(filterStatus: status));
    }
  }

  void addClient(Client client) {
    if (state is ClientLoaded) {
      final currentState = state as ClientLoaded;
      final newClients = List<Client>.from(currentState.clients)..add(client);

      final sortedClients = currentState.promoterPosition != null
          ? _locationService.sortClientsByDistance(
              newClients,
              currentState.promoterPosition!,
            )
          : newClients;

      emit(currentState.copyWith(
        clients: newClients,
        sortedClients: sortedClients,
      ));
    }
  }

  void updateClientStatus(int clientId, VisitStatus status) {
    if (state is ClientLoaded) {
      final currentState = state as ClientLoaded;
      final clients = List<Client>.from(currentState.clients);

      final index = clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        clients[index] = clients[index].copyWith(visitStatus: status);

        final sortedClients = currentState.promoterPosition != null
            ? _locationService.sortClientsByDistance(
                clients,
                currentState.promoterPosition!,
              )
            : clients;

        emit(currentState.copyWith(
          clients: clients,
          sortedClients: sortedClients,
        ));
      }
    }
  }

  List<Client> getFilteredClients() {
    if (state is! ClientLoaded) return [];

    final currentState = state as ClientLoaded;
    List<Client> result = currentState.sortedClients.isEmpty
        ? currentState.clients
        : currentState.sortedClients;

    if (currentState.searchQuery.isNotEmpty) {
      result = result.where((client) {
        final name = client.name.toLowerCase();
        final phone = client.phone.toLowerCase();
        final address = client.address.toLowerCase();
        final query = currentState.searchQuery.toLowerCase();
        return name.contains(query) ||
            phone.contains(query) ||
            address.contains(query);
      }).toList();
    }

    if (currentState.filterStatus != null) {
      result = result
          .where((client) => client.visitStatus == currentState.filterStatus)
          .toList();
    }

    return result;
  }

  double calculateTotalBalance() {
    if (state is! ClientLoaded) return 0.0;
    final currentState = state as ClientLoaded;
    return currentState.clients
        .fold(0, (total, client) => total + client.balance);
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
