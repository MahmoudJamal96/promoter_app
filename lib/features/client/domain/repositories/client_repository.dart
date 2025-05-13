import 'package:dartz/dartz.dart';
import 'package:promoter_app/core/error/failures.dart';
import 'package:promoter_app/features/client/domain/entities/client.dart';

abstract class ClientRepository {
  Future<Either<Failure, List<Client>>> getClients();
  Future<Either<Failure, void>> updateClientStatus(
      int clientId, VisitStatus status);
}
