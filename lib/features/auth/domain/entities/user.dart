import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? image;
  final String? phone;
  final String? role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    this.phone,
    this.role,
  });

  @override
  List<Object?> get props => [id, name, email, image, phone, role];
}
