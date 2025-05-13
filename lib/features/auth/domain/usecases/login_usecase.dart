import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:promoter_app/core/error/failures.dart';
import 'package:promoter_app/core/usecases/usecase.dart';
import 'package:promoter_app/features/auth/domain/entities/user.dart';
import 'package:promoter_app/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecase implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
