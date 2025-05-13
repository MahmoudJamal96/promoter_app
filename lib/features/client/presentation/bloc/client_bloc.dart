import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:promoter_app/core/error/failures.dart';
import 'package:promoter_app/core/usecases/usecase.dart';
import 'package:promoter_app/features/client/domain/entities/client.dart';
import 'package:promoter_app/features/client/domain/usecases/get_clients_usecase.dart';
import 'package:promoter_app/features/client/domain/usecases/update_client_status_usecase.dart';
import 'package:promoter_app/features/client/services/location_service.dart';

part 'client_event.dart';
part 'client_state.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final GetClientsUsecase getClientsUsecase;
  final UpdateClientStatusUsecase? updateClientStatusUsecase;
  final LocationService locationService = LocationService();
  StreamSubscription<Position>? _positionSubscription;

  ClientBloc({
    required this.getClientsUsecase,
    this.updateClientStatusUsecase,
  }) : super(ClientInitial()) {
    on<LoadClientsEvent>(_onLoadClients);
    on<SearchClientsEvent>(_onSearchClients);
    on<FilterClientsByStatusEvent>(_onFilterClients);
    on<UpdateClientStatusEvent>(_onUpdateClientStatus);
    on<SortClientsByDistanceEvent>(_onSortClientsByDistance);

    // Initialize location service
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      await locationService.initialize();

      // Listen for position updates
      _positionSubscription = locationService.positionStream.listen((position) {
        // Sort clients by distance whenever the position changes and we have clients
        if (state is ClientLoaded) {
          add(SortClientsByDistanceEvent());
        }
      });
    } catch (e) {
      // Handle location errors
      print('Error initializing location: $e');
    }
  }

  Future<void> _onLoadClients(
    LoadClientsEvent event,
    Emitter<ClientState> emit,
  ) async {
    emit(ClientLoading());

    final clientsResult = await getClientsUsecase(NoParams());

    clientsResult.fold(
      (failure) => emit(ClientError(_mapFailureToMessage(failure))),
      (clients) {
        // Sort clients by distance if location is available
        final sortedClients = _sortByDistance(clients);
        emit(ClientLoaded(
          clients: clients,
          filteredClients: sortedClients,
          searchQuery: '',
          filterStatus: null,
        ));
      },
    );
  }

  void _onSearchClients(
    SearchClientsEvent event,
    Emitter<ClientState> emit,
  ) {
    if (state is ClientLoaded) {
      final currentState = state as ClientLoaded;
      final query = event.query.toLowerCase();

      List<Client> filteredClients = currentState.clients;

      // Apply search filter
      if (query.isNotEmpty) {
        filteredClients = filteredClients
            .where((client) =>
                client.name.toLowerCase().contains(query) ||
                client.address.toLowerCase().contains(query) ||
                client.phone.contains(query) ||
                client.email.toLowerCase().contains(query))
            .toList();
      }

      // Apply status filter if exists
      if (currentState.filterStatus != null) {
        filteredClients = filteredClients
            .where((client) => client.visitStatus == currentState.filterStatus)
            .toList();
      }

      // Sort by distance
      filteredClients = _sortByDistance(filteredClients);

      emit(ClientLoaded(
        clients: currentState.clients,
        filteredClients: filteredClients,
        searchQuery: event.query,
        filterStatus: currentState.filterStatus,
      ));
    }
  }

  void _onFilterClients(
    FilterClientsByStatusEvent event,
    Emitter<ClientState> emit,
  ) {
    if (state is ClientLoaded) {
      final currentState = state as ClientLoaded;
      final query = currentState.searchQuery.toLowerCase();

      List<Client> filteredClients = currentState.clients;

      // Apply search filter
      if (query.isNotEmpty) {
        filteredClients = filteredClients
            .where((client) =>
                client.name.toLowerCase().contains(query) ||
                client.address.toLowerCase().contains(query) ||
                client.phone.contains(query) ||
                client.email.toLowerCase().contains(query))
            .toList();
      }

      // Apply status filter
      if (event.status != null) {
        filteredClients = filteredClients
            .where((client) => client.visitStatus == event.status)
            .toList();
      }

      // Sort by distance
      filteredClients = _sortByDistance(filteredClients);

      emit(ClientLoaded(
        clients: currentState.clients,
        filteredClients: filteredClients,
        searchQuery: currentState.searchQuery,
        filterStatus: event.status,
      ));
    }
  }

  Future<void> _onUpdateClientStatus(
    UpdateClientStatusEvent event,
    Emitter<ClientState> emit,
  ) async {
    if (updateClientStatusUsecase == null) return;

    if (state is ClientLoaded) {
      final currentState = state as ClientLoaded;

      // Optimistically update the client in the UI
      final updatedClients = currentState.clients.map((client) {
        if (client.id == event.clientId) {
          // Create a new client with the updated status
          // This assumes your Client entity has a copyWith method or similar
          return Client(
            id: client.id,
            name: client.name,
            address: client.address,
            phone: client.phone,
            email: client.email,
            latitude: client.latitude,
            longitude: client.longitude,
            image: client.image,
            visitStatus: event.status,
            distance: client.distance,
          );
        }
        return client;
      }).toList();

      // Apply current search and filters
      List<Client> filteredClients = _applyFilters(
        updatedClients,
        currentState.searchQuery,
        currentState.filterStatus,
      );

      // Sort by distance
      filteredClients = _sortByDistance(filteredClients);

      // Update the UI immediately
      emit(ClientLoaded(
        clients: updatedClients,
        filteredClients: filteredClients,
        searchQuery: currentState.searchQuery,
        filterStatus: currentState.filterStatus,
      ));

      // Send the update to the server
      final result = await updateClientStatusUsecase!(
        UpdateClientStatusParams(
          clientId: event.clientId,
          status: event.status,
        ),
      );

      // Handle server response
      result.fold(
        (failure) {
          // If there's an error, revert back
          emit(ClientError(_mapFailureToMessage(failure)));
          add(LoadClientsEvent());
        },
        (_) {
          // Success, already updated the UI
        },
      );
    }
  }

  void _onSortClientsByDistance(
    SortClientsByDistanceEvent event,
    Emitter<ClientState> emit,
  ) {
    if (state is ClientLoaded) {
      final currentState = state as ClientLoaded;

      final sortedClients = _sortByDistance(currentState.filteredClients);

      emit(ClientLoaded(
        clients: currentState.clients,
        filteredClients: sortedClients,
        searchQuery: currentState.searchQuery,
        filterStatus: currentState.filterStatus,
      ));
    }
  }

  List<Client> _applyFilters(
    List<Client> clients,
    String searchQuery,
    VisitStatus? filterStatus,
  ) {
    List<Client> result = clients;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result
          .where((client) =>
              client.name.toLowerCase().contains(query) ||
              client.address.toLowerCase().contains(query) ||
              client.phone.contains(query) ||
              client.email.toLowerCase().contains(query))
          .toList();
    }

    // Apply status filter
    if (filterStatus != null) {
      result =
          result.where((client) => client.visitStatus == filterStatus).toList();
    }

    return result;
  }

  List<Client> _sortByDistance(List<Client> clients) {
    final position = locationService.currentPosition;
    if (position == null) return clients;

    // Create a new list to avoid modifying the original
    final List<Client> sortedClients = List.from(clients);

    // Calculate distance for each client
    sortedClients.sort((a, b) {
      final distanceA = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        a.latitude,
        a.longitude,
      );

      final distanceB = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        b.latitude,
        b.longitude,
      );

      return distanceA.compareTo(distanceB);
    });

    return sortedClients;
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error';
      case NoInternetFailure:
        return 'No internet connection';
      case TimeoutFailure:
        return 'Connection timeout';
      case ApiFailure:
        return (failure as ApiFailure).message;
      default:
        return 'Unexpected error';
    }
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
