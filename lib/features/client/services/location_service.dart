import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/client_model.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  final StreamController<Position> _positionStreamController =
      StreamController<Position>.broadcast();

  Stream<Position> get positionStream => _positionStreamController.stream;
  Position? get currentPosition => _currentPosition;

  Future<void> initialize() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'خدمات الموقع غير مفعلة';
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'تم رفض صلاحيات الموقع';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'تم رفض صلاحيات الموقع بشكل دائم، يرجى تفعيلها من إعدادات التطبيق';
    }

    // Get current position
    _currentPosition = await Geolocator.getCurrentPosition();

    // Start position stream
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update if moved 10 meters
      ),
    ).listen((Position position) {
      _currentPosition = position;
      _positionStreamController.add(position);
    });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) /
        1000; // Convert to km
  }

  List<Client> sortClientsByDistance(
      List<Client> clients, Position promoterPosition) {
    final List<Client> sortedClients = clients.map((client) {
      final distance = calculateDistance(
        promoterPosition.latitude,
        promoterPosition.longitude,
        client.latitude,
        client.longitude,
      );

      return client.copyWith(distanceToPromoter: distance);
    }).toList();

    sortedClients
        .sort((a, b) => a.distanceToPromoter.compareTo(b.distanceToPromoter));

    return sortedClients;
  }

  void dispose() {
    _positionStreamController.close();
  }
}
