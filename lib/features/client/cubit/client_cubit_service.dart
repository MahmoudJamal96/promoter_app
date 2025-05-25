import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:promoter_app/qara_ksa.dart';
import '../models/client_model.dart';
import '../services/location_service.dart';
import '../services/client_service.dart';
import 'client_state.dart'; // Changed from part to import

class ClientCubit extends Cubit<ClientState> {
  final LocationService _locationService = LocationService();
  final ClientService _clientService;
  StreamSubscription<Position>? _positionSubscription;

  ClientCubit(this._clientService) : super(const ClientInitial()) {
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

      // Load clients from API using service
      await _loadClients(position);
    } catch (e) {
      // Handle errors
      print('Error initializing location or loading clients: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _loadClients(Position? position) async {
    try {
      final clients = await _clientService.getClients();

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
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
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
      // Pass null explicitly to reset the filter (for "All" option)
      emit(currentState.copyWith(filterStatus: status));
    }
  }

  Future<void> addClient(Client client) async {
    try {
      final newClient = await _clientService.createClient(
        name: client.name,
        phone: client.phone ?? "",
        address: client.address,
        latitude: client.latitude,
        longitude: client.longitude,
        code: client.code ?? '',
        stateId: client.stateId ?? 1,
        cityId: client.cityId ?? 1,
        typeOfWorkId: client.typeOfWorkId ?? 1,
        responsibleId: client.responsibleId ?? 1,
      );

      if (state is ClientLoaded) {
        final currentState = state as ClientLoaded;
        final newClients = List<Client>.from(currentState.clients)
          ..add(newClient);

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
    } catch (e) {
      if (state is ClientLoaded) {
        emit((state as ClientLoaded).copyWith(
          error: 'فشل في إضافة العميل: ${e.toString()}',
        ));
      }
    }
  }

  Future<void> updateClientStatus(int clientId, VisitStatus status) async {
    if (state is ClientLoaded) {
      final currentState = state as ClientLoaded;
      final clients = List<Client>.from(currentState.clients);

      // Optimistically update UI
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

        // Then update in API
        try {
          await _clientService.updateClientStatus(clientId, status);
        } catch (e) {
          // If API call fails, revert the state and show error
          emit(currentState.copyWith(
              error: 'فشل في تحديث حالة العميل: ${e.toString()}'));
          _loadClients(currentState.promoterPosition); // Reload from API
        }
      }
    }
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
