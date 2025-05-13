import 'package:flutter/material.dart';

enum VisitStatus { visited, notVisited, postponed }

class Client {
  final int id;
  final String name;
  final String phone;
  final String address;
  final double balance;
  final String lastPurchase;
  final double latitude;
  final double longitude;
  final VisitStatus visitStatus;
  final double distanceToPromoter; // in km

  const Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.balance,
    required this.lastPurchase,
    required this.latitude,
    required this.longitude,
    this.visitStatus = VisitStatus.notVisited,
    this.distanceToPromoter = 0,
  });

  Client copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    double? balance,
    String? lastPurchase,
    double? latitude,
    double? longitude,
    VisitStatus? visitStatus,
    double? distanceToPromoter,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      balance: balance ?? this.balance,
      lastPurchase: lastPurchase ?? this.lastPurchase,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      visitStatus: visitStatus ?? this.visitStatus,
      distanceToPromoter: distanceToPromoter ?? this.distanceToPromoter,
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
