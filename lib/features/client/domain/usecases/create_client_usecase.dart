import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:promoter_app/core/error/failures.dart';
import 'package:promoter_app/core/usecases/usecase.dart';
import 'package:promoter_app/features/client/domain/entities/client.dart';
import 'package:promoter_app/features/client/domain/repositories/client_repository.dart';

class CreateClientUsecase implements UseCase<Client, CreateClientParams> {
  final ClientRepository repository;

  CreateClientUsecase(this.repository);

  @override
  Future<Either<Failure, Client>> call(CreateClientParams params) {
    return repository.createClient(
      name: params.name,
      phone: params.phone,
      address: params.address,
      email: params.email ?? '',
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class CreateClientParams extends Equatable {
  final String name;
  final String phone;
  final String address;
  final String? email;
  final double latitude;
  final double longitude;

  const CreateClientParams({
    required this.name,
    required this.phone,
    required this.address,
    this.email,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [name, phone, address, email, latitude, longitude];
}
