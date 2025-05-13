import 'package:dartz/dartz.dart';
import 'package:promoter_app/core/error/failures.dart';
import 'package:promoter_app/core/usecases/usecase.dart';
import 'package:promoter_app/features/auth/domain/entities/user.dart';
import 'package:promoter_app/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUsecase implements UseCase<User, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUsecase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
