import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:promoter_app/core/error/failures.dart';
import 'package:promoter_app/core/usecases/usecase.dart';
import 'package:promoter_app/features/client/domain/entities/client.dart';
import 'package:promoter_app/features/client/domain/repositories/client_repository.dart';

class UpdateClientStatusUsecase
    implements UseCase<void, UpdateClientStatusParams> {
  final ClientRepository repository;

  UpdateClientStatusUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateClientStatusParams params) {
    return repository.updateClientStatus(params.clientId, params.status);
  }
}

class UpdateClientStatusParams extends Equatable {
  final int clientId;
  final VisitStatus status;

  const UpdateClientStatusParams({
    required this.clientId,
    required this.status,
  });

  @override
  List<Object> get props => [clientId, status];
}
