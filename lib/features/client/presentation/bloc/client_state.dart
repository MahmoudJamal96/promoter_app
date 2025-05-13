part of 'client_bloc.dart';

abstract class ClientState extends Equatable {
  const ClientState();

  @override
  List<Object?> get props => [];
}

class ClientInitial extends ClientState {}

class ClientLoading extends ClientState {}

class ClientLoaded extends ClientState {
  final List<Client> clients;
  final List<Client> filteredClients;
  final String searchQuery;
  final VisitStatus? filterStatus;

  const ClientLoaded({
    required this.clients,
    required this.filteredClients,
    required this.searchQuery,
    this.filterStatus,
  });

  @override
  List<Object?> get props =>
      [clients, filteredClients, searchQuery, filterStatus];
}

class ClientError extends ClientState {
  final String message;

  const ClientError(this.message);

  @override
  List<Object> get props => [message];
}
