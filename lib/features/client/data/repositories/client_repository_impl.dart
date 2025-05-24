import 'package:dartz/dartz.dart';
import 'package:promoter_app/core/error/exceptions.dart';
import 'package:promoter_app/core/error/failures.dart';
import 'package:promoter_app/core/network/network_info.dart';
import 'package:promoter_app/features/client/data/datasources/client_remote_data_source.dart';
import 'package:promoter_app/features/client/domain/entities/client.dart';
import 'package:promoter_app/features/client/domain/repositories/client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ClientRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Client>>> getClients() async {
    if (await networkInfo.isConnected) {
      try {
        final clients = await remoteDataSource.getClients();
        return Right(clients);
      } on ServerException {
        return Left(ServerFailure());
      } on TimeoutException {
        return Left(TimeoutFailure());
      } on ApiException catch (e) {
        return Left(ApiFailure(message: e.message, code: e.code));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, Client>> createClient({
    required String name,
    required String phone,
    required String address,
    required String email,
    required double latitude,
    required double longitude,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final client = await remoteDataSource.createClient(
          name: name,
          phone: phone,
          address: address,
          email: email,
          latitude: latitude,
          longitude: longitude,
        );
        return Right(client);
      } on ServerException {
        return Left(ServerFailure());
      } on TimeoutException {
        return Left(TimeoutFailure());
      } on ApiException catch (e) {
        return Left(ApiFailure(message: e.message, code: e.code));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateClientStatus(
    int clientId,
    VisitStatus status,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateClientStatus(clientId, status);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      } on TimeoutException {
        return Left(TimeoutFailure());
      } on ApiException catch (e) {
        return Left(ApiFailure(message: e.message, code: e.code));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }
}
