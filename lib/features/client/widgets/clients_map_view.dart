import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/client_model.dart';

class ClientsMapView extends StatefulWidget {
  final List<Client> clients;
  final Position promoterPosition;
  final Function(Client) onClientSelected;
  final VisitStatus? filterStatus;

  const ClientsMapView({
    Key? key,
    required this.clients,
    required this.promoterPosition,
    required this.onClientSelected,
    this.filterStatus,
  }) : super(key: key);

  @override
  State<ClientsMapView> createState() => _ClientsMapViewState();
}

class _ClientsMapViewState extends State<ClientsMapView> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  @override
  void didUpdateWidget(ClientsMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clients != widget.clients ||
        oldWidget.filterStatus != widget.filterStatus ||
        oldWidget.promoterPosition != widget.promoterPosition) {
      _createMarkers();
    }
  }

  void _createMarkers() {
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
    final filteredClients = widget.filterStatus != null
        ? widget.clients
            .where((client) => client.visitStatus == widget.filterStatus)
            .toList()
        : widget.clients;

    // Add client markers
    for (final client in filteredClients) {
      final marker = Marker(
        markerId: MarkerId('client_${client.id}'),
        position: LatLng(client.latitude, client.longitude),
        infoWindow: InfoWindow(
          title: client.name,
          snippet: '${client.getStatusText()} - ${client.formatDistance()}',
          onTap: () => widget.onClientSelected(client),
        ),
        icon: _getMarkerIcon(client.visitStatus),
      );

      markers.add(marker);

      // Add polyline from promoter to client
      polylines.add(
        Polyline(
          polylineId: PolylineId('route_${client.id}'),
          points: [
            LatLng(widget.promoterPosition.latitude,
                widget.promoterPosition.longitude),
            LatLng(client.latitude, client.longitude),
          ],
          color: client.getStatusColor().withOpacity(0.7),
          width: 3,
        ),
      );
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
  }

  BitmapDescriptor _getMarkerIcon(VisitStatus status) {
    switch (status) {
      case VisitStatus.visited:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case VisitStatus.notVisited:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case VisitStatus.postponed:
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GoogleMap(
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
        myLocationEnabled: false, // Disable to avoid permission issues
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        mapToolbarEnabled: true,
        compassEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          try {
            if (!_controller.isCompleted) {
              _controller.complete(controller);
            }
            // Ensure markers are updated after map creation
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _createMarkers();
              }
            });
            print('Google Map created successfully');
          } catch (e) {
            print('Error creating map: $e');
          }
        },
        onCameraMove: (CameraPosition position) {
          // Optional: Add camera movement handling
        },
      ),
    );
  }

  Future<void> animateToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }
}
