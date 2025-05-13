import 'package:dartz/dartz.dart';
import 'package:promoter_app/core/error/exceptions.dart';
import 'package:promoter_app/core/error/failures.dart';
import 'package:promoter_app/core/network/network_info.dart';
import 'package:promoter_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:promoter_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:promoter_app/features/auth/data/models/user_model.dart';
import 'package:promoter_app/features/auth/domain/entities/user.dart';
import 'package:promoter_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        print("mahmoud2");
        final (userModel, tokenModel) =
            await remoteDataSource.login(email, password);

        print("mahmoud");

        // Cache both the user and token
        await Future.wait([
          localDataSource.cacheUser(userModel),
          localDataSource.cacheToken(tokenModel)
        ]);

        // Set the token in the API client for future requests
        remoteDataSource.client.setToken(tokenModel.accessToken);

        return Right(userModel);
      } on UnauthorizedException {
        return Left(UnauthorizedFailure());
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
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearUserCache();
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getLastUser();
      return Right(userModel);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
