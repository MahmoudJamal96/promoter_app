import 'package:dartz/dartz.dart';
import 'package:promoter_app/core/error/failures.dart';
import 'package:promoter_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
}
