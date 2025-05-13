part of 'client_cubit.dart';

abstract class ClientState extends Equatable {
  final bool isLoading;
  final String? error;

  const ClientState({
    this.isLoading = false,
    this.error,
  });

  ClientState copyWith({
    bool? isLoading,
    String? error,
  });

  @override
  List<Object?> get props => [isLoading, error];
}

class ClientInitial extends ClientState {
  const ClientInitial({
    super.isLoading = false,
    super.error,
  });

  @override
  ClientState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return ClientInitial(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ClientLoaded extends ClientState {
  final List<Client> clients;
  final List<Client> sortedClients;
  final Position? promoterPosition;
  final String searchQuery;
  final VisitStatus? filterStatus;

  const ClientLoaded({
    required this.clients,
    required this.sortedClients,
    this.promoterPosition,
    required this.searchQuery,
    this.filterStatus,
    super.isLoading = false,
    super.error,
  });

  @override
  ClientState copyWith({
    List<Client>? clients,
    List<Client>? sortedClients,
    Position? promoterPosition,
    String? searchQuery,
    VisitStatus? filterStatus,
    bool? isLoading,
    String? error,
  }) {
    return ClientLoaded(
      clients: clients ?? this.clients,
      sortedClients: sortedClients ?? this.sortedClients,
      promoterPosition: promoterPosition ?? this.promoterPosition,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus ?? this.filterStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        clients,
        sortedClients,
        promoterPosition,
        searchQuery,
        filterStatus,
        isLoading,
        error,
      ];
}
