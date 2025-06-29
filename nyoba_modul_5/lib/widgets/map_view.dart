// lib/widgets/map_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import '../models/destination.dart';

class MapView extends StatelessWidget {
  final LatLng? userLocation;
  final List<Destination> destinations;
  final AnimatedMapController animatedMapController;
  final LatLng? highlightedDestination;
  final List<LatLng> routePoints;
  final VoidCallback onMapReady;

  const MapView({
    Key? key,
    this.userLocation,
    required this.destinations,
    required this.animatedMapController,
    this.highlightedDestination,
    required this.routePoints,
    required this.onMapReady,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: animatedMapController.mapController,
      options: MapOptions(
        initialCenter: userLocation ?? const LatLng(-0.5283, 130.6559),
        initialZoom: 9.2,
        minZoom: 3,
        maxZoom: 18,
        onMapReady: onMapReady,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.nyobabaruhehe',
        ),
        // Marker untuk lokasi pengguna
        if (userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: userLocation!,
                width: 40.0,
                height: 40.0,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 30.0,
                ),
              ),
            ],
          ),
        // Marker untuk destinasi
        // Di MapView widget:
        MarkerLayer(
          markers:
              destinations
                  .map((destination) {
                    if (destination.location == null) return null;

                    final isHighlighted =
                        highlightedDestination != null &&
                        highlightedDestination!.latitude ==
                            destination.location.latitude &&
                        highlightedDestination!.longitude ==
                            destination.location.longitude;

                    return Marker(
                      point: LatLng(
                        destination.location.latitude,
                        destination.location.longitude,
                      ),
                      width: isHighlighted ? 60.0 : 40.0,
                      height: isHighlighted ? 60.0 : 40.0,
                      child: Icon(
                        Icons.location_pin,
                        color: isHighlighted ? Colors.redAccent : Colors.orange,
                        size: isHighlighted ? 50.0 : 35.0,
                      ),
                    );
                  })
                  .whereType<Marker>()
                  .toList(),
        ),
        // Polyline untuk rute
        PolylineLayer(
          polylines: [
            if (routePoints.isNotEmpty)
              Polyline(
                points: routePoints,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
          ],
        ),
      ],
    );
  }
}
