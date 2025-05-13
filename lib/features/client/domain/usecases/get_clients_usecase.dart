import 'package:dartz/dartz.dart';
import 'package:promoter_app/core/error/failures.dart';
import 'package:promoter_app/core/usecases/usecase.dart';
import 'package:promoter_app/features/client/domain/entities/client.dart';
import 'package:promoter_app/features/client/domain/repositories/client_repository.dart';

class GetClientsUsecase implements UseCase<List<Client>, NoParams> {
  final ClientRepository repository;

  GetClientsUsecase(this.repository);

  @override
  Future<Either<Failure, List<Client>>> call(NoParams params) {
    return repository.getClients();
  }
}
