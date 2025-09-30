import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:http/http.dart' as http;
import 'package:promoter_app/core/utils/sound_manager.dart';

import '../models/client_model.dart';

class ClientsMapView extends StatefulWidget {
  final List<Client> clients;
  final Position promoterPosition;
  final Function(Client) onClientSelected;
  final VisitStatus? filterStatus;
  final String? googleApiKey;

  const ClientsMapView({
    super.key,
    required this.clients,
    required this.promoterPosition,
    required this.onClientSelected,
    this.filterStatus,
    this.googleApiKey =
        'AIzaSyBftjKL2CCLFMxoDnA5Eaq8SeUsRTWdnIU', // Replace with your actual API key
  });

  @override
  State<ClientsMapView> createState() => _ClientsMapViewState();
}

class _ClientsMapViewState extends State<ClientsMapView> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoadingRoutes = false;
  String _routingStatus = '';

  // Color scheme for different clients
  final List<double> _clientColors = [
    BitmapDescriptor.hueRed,
    BitmapDescriptor.hueOrange,
    BitmapDescriptor.hueYellow,
    BitmapDescriptor.hueGreen,
    BitmapDescriptor.hueBlue,
    BitmapDescriptor.hueViolet,
    BitmapDescriptor.hueMagenta,
    BitmapDescriptor.hueRose,
    BitmapDescriptor.hueCyan,
    BitmapDescriptor.hueAzure,
  ];

  @override
  void initState() {
    super.initState();
    _createMarkersAndRoutes();
  }

  @override
  void didUpdateWidget(ClientsMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clients != widget.clients ||
        oldWidget.filterStatus != widget.filterStatus ||
        oldWidget.promoterPosition != widget.promoterPosition) {
      _createMarkersAndRoutes();
    }
  }

  Future<void> _createMarkersAndRoutes() async {
    setState(() {
      _isLoadingRoutes = true;
      _routingStatus = 'جاري تحديد المسارات...';
    });

    final Set<Marker> markers = {};
    final Set<Polyline> polylines = {};

    // Add promoter marker
    markers.add(
      Marker(
        markerId: const MarkerId('promoter'),
        position: LatLng(
          widget.promoterPosition.latitude,
          widget.promoterPosition.longitude,
        ),
        infoWindow: const InfoWindow(title: 'موقعي الحالي'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Filter clients if needed
    // final filteredClients = widget.filterStatus != null
    //     ? widget.clients.where((client) => client.visitStatus == widget.filterStatus).toList()
    //     : widget.clients;
    final filteredClients = [
      // Cairo Clients
      const Client(
        id: 1,
        name: 'أحمد محمد علي',
        phone: '+201012345678',
        address: 'شارع التحرير، وسط البلد، القاهرة',
        shopName: 'محل أحمد للإلكترونيات',
        email: 'ahmed.mohamed@gmail.com',
        balance: 15000.50,
        lastPurchase: '2024-12-15',
        latitude: 30.0444,
        longitude: 31.2357,
        visitStatus: VisitStatus.visited,
        distanceToPromoter: 2.5,
        code: 'CLT001',
        stateId: 1, // Cairo
        cityId: 1,
        typeOfWorkId: 1,
        responsibleId: 101,
      ),

      const Client(
        id: 2,
        name: 'فاطمة السيد حسن',
        phone: '+201098765432',
        address: 'مدينة نصر، القاهرة الجديدة',
        shopName: 'بوتيك فاطمة للأزياء',
        email: 'fatma.sayed@yahoo.com',
        balance: 8750.25,
        lastPurchase: '2024-12-10',
        latitude: 30.0626,
        longitude: 31.3219,
        visitStatus: VisitStatus.notVisited,
        distanceToPromoter: 5.8,
        code: 'CLT002',
        stateId: 1, // Cairo
        cityId: 2,
        typeOfWorkId: 2,
        responsibleId: 102,
      ),

      const Client(
        id: 3,
        name: 'محمود عبد الرحمن',
        phone: '+201123456789',
        address: 'المعادي، القاهرة',
        shopName: 'صيدلية المعادي',
        email: 'mahmoud.abdelrahman@hotmail.com',
        balance: 22300.75,
        lastPurchase: '2024-12-18',
        latitude: 29.9602,
        longitude: 31.2669,
        visitStatus: VisitStatus.postponed,
        distanceToPromoter: 12.3,
        code: 'CLT003',
        stateId: 1, // Cairo
        cityId: 3,
        typeOfWorkId: 3,
        responsibleId: 101,
      ),

      // Alexandria Clients
      const Client(
        id: 4,
        name: 'سارة أحمد فتحي',
        phone: '+201234567890',
        address: 'سيدي جابر، الإسكندرية',
        shopName: 'مكتبة سارة',
        email: 'sara.ahmed@gmail.com',
        balance: 12500.00,
        lastPurchase: '2024-12-12',
        latitude: 31.2156,
        longitude: 29.9553,
        visitStatus: VisitStatus.visited,
        distanceToPromoter: 185.4,
        code: 'CLT004',
        stateId: 2, // Alexandria
        cityId: 4,
        typeOfWorkId: 1,
        responsibleId: 103,
      ),

      const Client(
        id: 5,
        name: 'خالد محمد رضا',
        phone: '+201345678901',
        address: 'العطارين، الإسكندرية',
        shopName: 'مطعم خالد للمأكولات البحرية',
        email: 'khaled.mohamed@outlook.com',
        balance: 18900.30,
        lastPurchase: '2024-12-20',
        latitude: 31.1975,
        longitude: 29.9097,
        visitStatus: VisitStatus.notVisited,
        distanceToPromoter: 192.7,
        code: 'CLT005',
        stateId: 2, // Alexandria
        cityId: 5,
        typeOfWorkId: 4,
        responsibleId: 103,
      ),

      // Giza Clients
      const Client(
        id: 6,
        name: 'نور الدين عبد الله',
        phone: '+201456789012',
        address: 'الهرم، الجيزة',
        shopName: 'ورشة نور الدين للسيارات',
        email: 'noureldeen.abdullah@gmail.com',
        balance: 9850.60,
        lastPurchase: '2024-12-08',
        latitude: 29.9792,
        longitude: 31.1342,
        visitStatus: VisitStatus.visited,
        distanceToPromoter: 8.9,
        code: 'CLT006',
        stateId: 3, // Giza
        cityId: 6,
        typeOfWorkId: 5,
        responsibleId: 104,
      ),

      const Client(
        id: 7,
        name: 'مريم حسام الدين',
        phone: '+201567890123',
        address: 'الدقي، الجيزة',
        shopName: 'صالون مريم للتجميل',
        email: 'mariam.hossam@gmail.com',
        balance: 7200.15,
        lastPurchase: '2024-12-14',
        latitude: 30.0384,
        longitude: 31.2018,
        visitStatus: VisitStatus.postponed,
        distanceToPromoter: 6.2,
        code: 'CLT007',
        stateId: 3, // Giza
        cityId: 7,
        typeOfWorkId: 6,
        responsibleId: 104,
      ),

      // Mansoura - Dakahlia Clients
      const Client(
        id: 8,
        name: 'عمر صلاح الدين',
        phone: '+201678901234',
        address: 'وسط المدينة، المنصورة، الدقهلية',
        shopName: 'محل عمر للأدوات المنزلية',
        email: 'omar.salah@yahoo.com',
        balance: 11400.80,
        lastPurchase: '2024-12-16',
        latitude: 31.0364,
        longitude: 31.3807,
        visitStatus: VisitStatus.visited,
        distanceToPromoter: 120.5,
        code: 'CLT008',
        stateId: 4, // Dakahlia
        cityId: 8,
        typeOfWorkId: 1,
        responsibleId: 105,
      ),

      const Client(
        id: 9,
        name: 'هدى عبد العزيز',
        phone: '+201789012345',
        address: 'شارع الجمهورية، المنصورة',
        shopName: 'معرض هدى للأثاث',
        email: 'hoda.abdelaziz@gmail.com',
        balance: 25600.40,
        lastPurchase: '2024-12-22',
        latitude: 31.0420,
        longitude: 31.3785,
        visitStatus: VisitStatus.notVisited,
        distanceToPromoter: 118.3,
        code: 'CLT009',
        stateId: 4, // Dakahlia
        cityId: 8,
        typeOfWorkId: 7,
        responsibleId: 105,
      ),

      // Tanta - Gharbia Clients
      const Client(
        id: 10,
        name: 'يوسف محمد الشافعي',
        phone: '+201890123456',
        address: 'شارع سعد زغلول، طنطا، الغربية',
        shopName: 'عيادة د. يوسف الشافعي',
        email: 'youssef.shafei@gmail.com',
        balance: 31200.90,
        lastPurchase: '2024-12-19',
        latitude: 30.7865,
        longitude: 31.0004,
        visitStatus: VisitStatus.visited,
        distanceToPromoter: 95.7,
        code: 'CLT010',
        stateId: 5, // Gharbia
        cityId: 9,
        typeOfWorkId: 8,
        responsibleId: 106,
      ),

      // Aswan Clients
      const Client(
        id: 11,
        name: 'أمل عبد الناصر',
        phone: '+201901234567',
        address: 'كورنيش النيل، أسوان',
        shopName: 'فندق أمل النوبي',
        email: 'amal.abdelnasser@hotmail.com',
        balance: 45800.25,
        lastPurchase: '2024-12-21',
        latitude: 24.0889,
        longitude: 32.8998,
        visitStatus: VisitStatus.postponed,
        distanceToPromoter: 678.4,
        code: 'CLT011',
        stateId: 6, // Aswan
        cityId: 10,
        typeOfWorkId: 9,
        responsibleId: 107,
      ),

      // Luxor Clients
      const Client(
        id: 12,
        name: 'رامي جمال الدين',
        phone: '+201012345987',
        address: 'البر الشرقي، الأقصر',
        shopName: 'وكالة رامي للسياحة',
        email: 'ramy.gamal@gmail.com',
        balance: 19700.55,
        lastPurchase: '2024-12-11',
        latitude: 25.6872,
        longitude: 32.6396,
        visitStatus: VisitStatus.visited,
        distanceToPromoter: 512.8,
        code: 'CLT012',
        stateId: 7, // Luxor
        cityId: 11,
        typeOfWorkId: 10,
        responsibleId: 107,
      ),

      // Sharm El Sheikh - South Sinai
      const Client(
        id: 13,
        name: 'ليلى محمد حسين',
        phone: '+201123459876',
        address: 'نعمة باي، شرم الشيخ، جنوب سيناء',
        shopName: 'مركز ليلى للغوص',
        email: 'layla.hussein@yahoo.com',
        balance: 13450.70,
        lastPurchase: '2024-12-13',
        latitude: 27.9158,
        longitude: 34.3300,
        visitStatus: VisitStatus.notVisited,
        distanceToPromoter: 458.9,
        code: 'CLT013',
        stateId: 8, // South Sinai
        cityId: 12,
        typeOfWorkId: 11,
        responsibleId: 108,
      ),

      // Port Said Clients
      const Client(
        id: 14,
        name: 'طارق عبد الرحيم',
        phone: '+201234567543',
        address: 'شارع الجمهورية، بورسعيد',
        shopName: 'شركة طارق للشحن البحري',
        email: 'tarek.abdelrahim@gmail.com',
        balance: 52300.85,
        lastPurchase: '2024-12-23',
        latitude: 31.2653,
        longitude: 32.3020,
        visitStatus: VisitStatus.visited,
        distanceToPromoter: 165.2,
        code: 'CLT014',
        stateId: 9, // Port Said
        cityId: 13,
        typeOfWorkId: 12,
        responsibleId: 109,
      ),

      // Suez Clients
      const Client(
        id: 15,
        name: 'سلمى أحمد فؤاد',
        phone: '+201345676543',
        address: 'الأربعين، السويس',
        shopName: 'مصنع سلمى للملابس',
        email: 'salma.fouad@outlook.com',
        balance: 28900.45,
        lastPurchase: '2024-12-17',
        latitude: 29.9668,
        longitude: 32.5498,
        visitStatus: VisitStatus.postponed,
        distanceToPromoter: 134.7,
        code: 'CLT015',
        stateId: 10, // Suez
        cityId: 14,
        typeOfWorkId: 13,
        responsibleId: 110,
      ),
    ];
    // Check if API key is valid
    if (widget.googleApiKey == null || widget.googleApiKey!.isEmpty) {
      setState(() {
        _routingStatus = 'تحذير: مفتاح Google API غير صحيح - سيتم استخدام خطوط مستقيمة';
      });
      await Future.delayed(const Duration(seconds: 2)); // Show the warning
    }

    int successfulRoutes = 0;
    int failedRoutes = 0;

    // Add client markers and get routes
    for (int i = 0; i < filteredClients.length; i++) {
      final client = filteredClients[i];

      setState(() {
        _routingStatus = 'جاري تحديد المسار للعميل ${i + 1} من ${filteredClients.length}';
      });

      // Add client marker
      final combinedColor = _getCombinedMarkerIcon(client.visitStatus, i);
      final marker = Marker(
        markerId: MarkerId('client_${client.id}'),
        position: LatLng(client.latitude, client.longitude),
        infoWindow: InfoWindow(
          title: client.name,
          snippet: '${client.getStatusText()} - ${client.formatDistance()}',
          onTap: () {
            SoundManager().playClickSound();
            widget.onClientSelected(client);
          },
        ),
        icon: combinedColor,
      );
      markers.add(marker);

      // Get driving route from promoter to client
      try {
        final routePoints = await _getRouteBetweenPoints(
          LatLng(widget.promoterPosition.latitude, widget.promoterPosition.longitude),
          LatLng(client.latitude, client.longitude),
        );

        if (routePoints.isNotEmpty) {
          polylines.add(
            Polyline(
              polylineId: PolylineId('route_${client.id}'),
              points: routePoints,
              color: _getPolylineColor(client.visitStatus, i).withOpacity(0.7),
              width: 4,
              patterns: _getPolylinePattern(client.visitStatus),
              geodesic: true,
              jointType: JointType.round,
              endCap: Cap.roundCap,
              startCap: Cap.roundCap,
            ),
          );
          successfulRoutes++;
          print('✅ Successfully got route for client ${client.name}');
        } else {
          throw Exception('Empty route returned');
        }
      } catch (e) {
        failedRoutes++;
        print('❌ Error getting route for client ${client.name}: $e');

        // Fallback to straight line with different styling to show it's not a real route
        polylines.add(
          Polyline(
            polylineId: PolylineId('fallback_route_${client.id}'),
            points: [
              LatLng(widget.promoterPosition.latitude, widget.promoterPosition.longitude),
              LatLng(client.latitude, client.longitude),
            ],
            color: Colors.grey.withOpacity(0.5),
            width: 2,
            //patterns: [PatternItem.dash(5), PatternItem.gap(10)], // Heavy dashed for fallback
            geodesic: false, // Straight line
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
      _isLoadingRoutes = false;
      _routingStatus = 'تم إنشاء $successfulRoutes مسار بنجاح، فشل في $failedRoutes مسار';
    });

    // Hide status after a few seconds
    if (successfulRoutes > 0 || failedRoutes > 0) {
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        _routingStatus = '';
      });
    }
  }

  // Enhanced routing method with better error handling and debugging
  Future<List<LatLng>> _getRouteBetweenPoints(LatLng origin, LatLng destination) async {
    if (widget.googleApiKey == null || widget.googleApiKey!.isEmpty) {
      throw Exception('Google API Key is required for routing');
    }

    final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'mode=driving&'
        'language=ar&'
        'region=eg&'
        'alternatives=false&' // Get single best route
        'avoid=tolls&' // Avoid tolls for better local routing
        'key=${widget.googleApiKey}';

    print('🌐 Making API call to: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Flutter-App/1.0',
        },
      ).timeout(const Duration(seconds: 10)); // Add timeout

      print('📡 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 API Response Status: ${data['status']}');

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polylinePoints = route['overview_polyline']['points'];

          // Decode the polyline points
          final List<List<num>> decodedPoints = decodePolyline(polylinePoints);
          print('🗺️ Decoded ${decodedPoints.length} route points');

          return decodedPoints
              .map((point) => LatLng(point[0].toDouble(), point[1].toDouble()))
              .toList();
        } else {
          // Log the exact error from Google
          String errorMessage = 'Unknown error';
          if (data['error_message'] != null) {
            errorMessage = data['error_message'];
          }
          print('❌ Google Directions API Error: ${data['status']} - $errorMessage');
          throw Exception('Google Directions API Error: ${data['status']} - $errorMessage');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode} - ${response.body}');
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } on TimeoutException {
      print('⏱️ Request timeout');
      throw Exception('Request timeout - check your internet connection');
    } catch (e) {
      print('💥 Network/Parsing Error: $e');
      rethrow;
    }
  }

  // Alternative routing using OpenRouteService (free alternative)
  Future<List<LatLng>> _getRouteUsingOpenRouteService(LatLng origin, LatLng destination) async {
    // Get a free API key from openrouteservice.org
    const String apiKey = '5b3ce3597851110001cf62484ec38f19740741109f6a967e0ae1a646';

    if (apiKey == 'YOUR_OPENROUTESERVICE_API_KEY') {
      throw Exception('OpenRouteService API Key is required');
    }

    final String url = 'https://api.openrouteservice.org/v2/directions/driving-car?'
        'api_key=$apiKey&'
        'start=${origin.longitude},${origin.latitude}&'
        'end=${destination.longitude},${destination.latitude}';

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['features'][0]['geometry']['coordinates'] as List;

        return coordinates
            .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
            .toList();
      } else {
        throw Exception('OpenRouteService Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error with OpenRouteService: $e');
      rethrow;
    }
  }

  // Method to switch between routing services
  Future<List<LatLng>> _getRouteWithFallback(LatLng origin, LatLng destination) async {
    try {
      // Try Google Directions first
      return await _getRouteBetweenPoints(origin, destination);
    } catch (e) {
      print('Google Directions failed, trying OpenRouteService: $e');
      try {
        // Fallback to OpenRouteService
        return await _getRouteUsingOpenRouteService(origin, destination);
      } catch (e2) {
        print('OpenRouteService also failed: $e2');
        rethrow;
      }
    }
  }

  // Get polyline patterns based on visit status
  List<PatternItem> _getPolylinePattern(VisitStatus status) {
    switch (status) {
      case VisitStatus.visited:
        return []; // Solid line
      case VisitStatus.notVisited:
        return [PatternItem.dash(20), PatternItem.gap(10)]; // Dashed line
      case VisitStatus.postponed:
        return [PatternItem.dot, PatternItem.gap(10)]; // Dotted line
    }
  }

  // Original status-based coloring
  BitmapDescriptor _getMarkerIconByStatus(VisitStatus status) {
    switch (status) {
      case VisitStatus.visited:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case VisitStatus.notVisited:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case VisitStatus.postponed:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

  // Unique color per client (cycling through available colors)
  BitmapDescriptor _getUniqueMarkerIcon(int clientIndex) {
    final colorIndex = clientIndex % _clientColors.length;
    return BitmapDescriptor.defaultMarkerWithHue(_clientColors[colorIndex]);
  }

  // Combined approach: status-based with unique variations
  BitmapDescriptor _getCombinedMarkerIcon(VisitStatus status, int clientIndex) {
    double baseHue;

    switch (status) {
      case VisitStatus.visited:
        baseHue = 120 + (clientIndex % 6) * 10;
        break;
      case VisitStatus.notVisited:
        baseHue = (clientIndex % 6) * 5;
        break;
      case VisitStatus.postponed:
        baseHue = 30 + (clientIndex % 6) * 5;
        break;
    }

    return BitmapDescriptor.defaultMarkerWithHue(baseHue);
  }

  // Get polyline color that matches the marker
  Color _getPolylineColor(VisitStatus status, int clientIndex) {
    switch (status) {
      case VisitStatus.visited:
        return Colors.green;
      case VisitStatus.notVisited:
        return Colors.red;
      case VisitStatus.postponed:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.promoterPosition.latitude,
              widget.promoterPosition.longitude,
            ),
            zoom: 14,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapToolbarEnabled: true,
          compassEnabled: true,
          trafficEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            try {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
              print('Google Map created successfully');
            } catch (e) {
              print('Error creating map: $e');
            }
          },
          onCameraMove: (CameraPosition position) {
            // Optional: Add camera movement handling
          },
        ),
        // Enhanced loading indicator with status
        if (_isLoadingRoutes)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        _routingStatus,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // Status message overlay
        if (!_isLoadingRoutes && _routingStatus.isNotEmpty)
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              color: _routingStatus.contains('تحذير') ? Colors.orange[100] : Colors.green[100],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _routingStatus,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        _routingStatus.contains('تحذير') ? Colors.orange[800] : Colors.green[800],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> animateToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  // Fit all markers and routes in view
  Future<void> fitAllMarkersInView() async {
    if (_markers.isEmpty) return;

    final GoogleMapController controller = await _controller.future;

    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLng = _markers.first.position.longitude;

    for (final marker in _markers) {
      minLat = math.min(minLat, marker.position.latitude);
      maxLat = math.max(maxLat, marker.position.latitude);
      minLng = math.min(minLng, marker.position.longitude);
      maxLng = math.max(maxLng, marker.position.longitude);
    }

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }

  // Helper method to get client color for legend or other UI elements
  Color getClientColor(int clientIndex, VisitStatus status) {
    return _getPolylineColor(status, clientIndex);
  }

  // Enhanced route info method with better error handling
  Future<Map<String, dynamic>?> getRouteInfo(Client client) async {
    if (widget.googleApiKey == null || widget.googleApiKey!.isEmpty) {
      return null;
    }

    final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${widget.promoterPosition.latitude},${widget.promoterPosition.longitude}&'
        'destination=${client.latitude},${client.longitude}&'
        'mode=driving&'
        'language=ar&'
        'region=eg&'
        'key=${widget.googleApiKey}';

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0]['legs'][0];
          return {
            'distance': route['distance']['text'],
            'duration': route['duration']['text'],
            'distanceValue': route['distance']['value'], // in meters
            'durationValue': route['duration']['value'], // in seconds
          };
        }
      }
    } catch (e) {
      print('Error getting route info: $e');
    }

    return null;
  }

  // Method to manually test API key
  Future<bool> testApiKey() async {
    if (widget.googleApiKey == null || widget.googleApiKey!.isEmpty) {
      return false;
    }

    try {
      final testUrl = 'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=30.0444,31.2357&' // Cairo coordinates
          'destination=30.0626,31.2497&' // Another Cairo location
          'mode=driving&'
          'key=${widget.googleApiKey}';

      final response = await http.get(Uri.parse(testUrl)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'OK';
      }
    } catch (e) {
      print('API Key test failed: $e');
    }

    return false;
  }
}
