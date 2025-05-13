import 'package:promoter_app/features/client/domain/entities/client.dart';

class ClientModel extends Client {
  const ClientModel({
    required super.id,
    required super.name,
    required super.address,
    required super.phone,
    required super.email,
    required super.latitude,
    required super.longitude,
    super.image,
    super.visitStatus,
    super.distance,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      image: json['image'],
      visitStatus: json['visitStatus'] != null
          ? VisitStatusExtension.fromString(json['visitStatus'])
          : VisitStatus.pending,
      distance: json['distance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'image': image,
      'visitStatus': visitStatus.toString().split('.').last,
      'distance': distance,
    };
  }
}
