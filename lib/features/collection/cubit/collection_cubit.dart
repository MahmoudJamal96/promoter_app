import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:promoter_app/features/collection/models/collection_model.dart';
import 'package:promoter_app/features/collection/services/collection_service.dart';
import 'package:promoter_app/core/di/injection_container.dart';

part 'collection_state.dart';

class CollectionCubit extends Cubit<CollectionState> {
  final CollectionService _collectionService;

  CollectionCubit({CollectionService? collectionService})
      : _collectionService = collectionService ?? sl(),
        super(CollectionInitial());

  Future<void> fetchCollections({int? clientId}) async {
    emit(CollectionLoading());
    try {
      final collections =
          await _collectionService.getCollections(clientId: clientId);
      emit(CollectionLoaded(collections));
    } catch (e) {
      emit(CollectionError(e.toString()));
    }
  }

  Future<void> createCollection({
    required int clientId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    emit(CollectionCreating());
    try {
      final collection = await _collectionService.createCollection(
        clientId: clientId,
        amount: amount,
        paymentMethod: paymentMethod,
        referenceNumber: referenceNumber,
        notes: notes,
      );
      emit(CollectionCreated(collection));
      // Optionally, refresh the list of collections
      fetchCollections(); // Or fetchCollections(clientId: clientId) if relevant
    } catch (e) {
      emit(CollectionError(e.toString()));
    }
  }
}
