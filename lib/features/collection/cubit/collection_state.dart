part of 'collection_cubit.dart';

abstract class CollectionState extends Equatable {
  const CollectionState();

  @override
  List<Object?> get props => [];
}

class CollectionInitial extends CollectionState {}

class CollectionLoading extends CollectionState {}

class CollectionLoaded extends CollectionState {
  final List<Collection> collections;

  const CollectionLoaded(this.collections);

  @override
  List<Object?> get props => [collections];
}

class CollectionError extends CollectionState {
  final String message;

  const CollectionError(this.message);

  @override
  List<Object?> get props => [message];
}

class CollectionCreating extends CollectionState {}

class CollectionCreated extends CollectionState {
  final Collection collection;

  const CollectionCreated(this.collection);

  @override
  List<Object?> get props => [collection];
}
