import 'package:flutter/material.dart';

enum VisitStatus { visited, notVisited, postponed }

class Client {
  final int id;
  final String name;
  final String? phone;
  final String address;
  final String? shopName;
  final String? email; // Added email field
  final double balance;
  final String lastPurchase;
  final double latitude;
  final double longitude;
  final VisitStatus visitStatus;
  final double distanceToPromoter; // in km
  final String? code; // Code for client
  final int? stateId; // State/Governorate ID
  final int? cityId; // City ID
  final int? typeOfWorkId; // Type of work ID
  final int? responsibleId; // Responsible ID

  const Client({
    required this.id,
    required this.name,
    this.phone,
    this.shopName,
    required this.address,
    this.email,
    required this.balance,
    required this.lastPurchase,
    required this.latitude,
    required this.longitude,
    this.visitStatus = VisitStatus.notVisited,
    this.distanceToPromoter = 0,
    this.code,
    this.stateId,
    this.cityId,
    this.typeOfWorkId,
    this.responsibleId,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    // Parse visit status from string or int
    VisitStatus parseVisitStatus(dynamic status) {
      if (status == null) return VisitStatus.notVisited;

      if (status is String) {
        switch (status.toLowerCase()) {
          case 'completed':
            return VisitStatus.visited;
          case 'postponed':
            return VisitStatus.postponed;
          default:
            return VisitStatus.notVisited;
        }
      } else if (status is int) {
        switch (status) {
          case 1:
            return VisitStatus.visited;
          case 2:
            return VisitStatus.postponed;
          default:
            return VisitStatus.notVisited;
        }
      }
      return VisitStatus.notVisited;
    }

    print(
        "mahmoud mmemem ${double.tryParse(json['longitude']?.toString() ?? '') ?? double.tryParse(json['lon']?.toString() ?? '') ?? double.tryParse(json['Long']?.toString() ?? '') ?? 0.0}");

    return Client(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'],
      address: json['address'] ?? '',
      email: json['email'],
      balance: (json['balance'] != null)
          ? (json['balance'] is int
              ? (json['balance'] as int).toDouble()
              : (json['balance'] as num?)?.toDouble() ?? 0.0)
          : 0.0,
      lastPurchase: json['last_purchase'] ?? json['lastPurchase'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ??
          double.tryParse(json['lat']?.toString() ?? '') ??
          double.tryParse(json['Lat']?.toString() ?? '') ??
          0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ??
          double.tryParse(json['lon']?.toString() ?? '') ??
          double.tryParse(json['Long']?.toString() ?? '') ??
          0.0,
      visitStatus: parseVisitStatus(json['last_meeting_status'] ?? json['last_meeting_status']),
      distanceToPromoter: (json['distance_to_promoter'] != null ||
              json['distanceToPromoter'] != null)
          ? ((json['distance_to_promoter'] ?? json['distanceToPromoter']) is int
              ? (json['distance_to_promoter'] ?? json['distanceToPromoter'] as int).toDouble()
              : (json['distance_to_promoter'] ?? json['distanceToPromoter'] as num?)?.toDouble() ??
                  0.0)
          : 0.0,
      code: json['code'],
      stateId: json['state_id'] ?? json['stateId'],
      cityId: json['city_id'] ?? json['cityId'],
      typeOfWorkId: json['type_of_work_id'] ?? json['typeOfWorkId'],
      responsibleId: json['responsible_id'] ?? json['responsibleId'],
    );
  }

  // Convert Client object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'balance': balance,
      'last_purchase': lastPurchase,
      'latitude': latitude,
      'longitude': longitude,
      'lat': latitude, // Added for API compatibility
      'lon': longitude, // Added for API compatibility
      'visit_status': visitStatus.index,
      'distance_to_promoter': distanceToPromoter,
      'code': code,
      'state_id': stateId,
      'city_id': cityId,
      'type_of_work_id': typeOfWorkId,
      'responsible_id': responsibleId,
    };
  }

  Client copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? email,
    double? balance,
    String? lastPurchase,
    double? latitude,
    double? longitude,
    VisitStatus? visitStatus,
    double? distanceToPromoter,
    String? code,
    int? stateId,
    int? cityId,
    int? typeOfWorkId,
    int? responsibleId,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      balance: balance ?? this.balance,
      lastPurchase: lastPurchase ?? this.lastPurchase,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      visitStatus: visitStatus ?? this.visitStatus,
      distanceToPromoter: distanceToPromoter ?? this.distanceToPromoter,
      code: code ?? this.code,
      stateId: stateId ?? this.stateId,
      cityId: cityId ?? this.cityId,
      typeOfWorkId: typeOfWorkId ?? this.typeOfWorkId,
      responsibleId: responsibleId ?? this.responsibleId,
    );
  }

  // Helper methods for UI display
  Color getStatusColor() {
    switch (visitStatus) {
      case VisitStatus.visited:
        return Colors.green;
      case VisitStatus.notVisited:
        return Colors.red;
      case VisitStatus.postponed:
        return Colors.orange;
    }
  }

  IconData getStatusIcon() {
    switch (visitStatus) {
      case VisitStatus.visited:
        return Icons.check_circle;
      case VisitStatus.notVisited:
        return Icons.cancel;
      case VisitStatus.postponed:
        return Icons.access_time;
    }
  }

  String getStatusText() {
    switch (visitStatus) {
      case VisitStatus.visited:
        return 'تمت الزيارة';
      case VisitStatus.notVisited:
        return 'لم تتم الزيارة';
      case VisitStatus.postponed:
        return 'تم تأجيلها';
    }
  }

  String formatDistance() {
    if (distanceToPromoter < 1) {
      return '${(distanceToPromoter * 1000).toStringAsFixed(0)} متر';
    }
    return '${distanceToPromoter.toStringAsFixed(1)} كم';
  }
}
