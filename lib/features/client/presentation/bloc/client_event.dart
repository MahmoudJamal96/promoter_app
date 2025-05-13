part of 'client_bloc.dart';

abstract class ClientEvent extends Equatable {
  const ClientEvent();

  @override
  List<Object?> get props => [];
}

class LoadClientsEvent extends ClientEvent {}

class SearchClientsEvent extends ClientEvent {
  final String query;

  const SearchClientsEvent(this.query);

  @override
  List<Object> get props => [query];
}

class FilterClientsByStatusEvent extends ClientEvent {
  final VisitStatus? status;

  const FilterClientsByStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class UpdateClientStatusEvent extends ClientEvent {
  final int clientId;
  final VisitStatus status;

  const UpdateClientStatusEvent({
    required this.clientId,
    required this.status,
  });

  @override
  List<Object> get props => [clientId, status];
}

class SortClientsByDistanceEvent extends ClientEvent {}
