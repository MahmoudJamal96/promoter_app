import 'package:equatable/equatable.dart';

enum VisitStatus {
  pending,
  completed,
  missed,
}

extension VisitStatusExtension on VisitStatus {
  static VisitStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return VisitStatus.completed;
      case 'missed':
        return VisitStatus.missed;
      default:
        return VisitStatus.pending;
    }
  }
}

class Client extends Equatable {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final double latitude;
  final double longitude;
  final String? image;
  final VisitStatus visitStatus;
  final double? distance;

  const Client({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.latitude,
    required this.longitude,
    this.image,
    this.visitStatus = VisitStatus.pending,
    this.distance,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        phone,
        email,
        latitude,
        longitude,
        image,
        visitStatus,
        distance,
      ];
}
