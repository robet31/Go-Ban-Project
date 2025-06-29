import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:nyoba_modul_5/models/destination.dart';

// Helper function to format price to Rupiah
String formatRupiah(String price) {
  if (price.isEmpty) return price;
  
  // Remove non-digit characters
  final cleanPrice = price.replaceAll(RegExp(r'[^\d]'), '');
  final number = int.tryParse(cleanPrice);
  
  if (number == null) return price;
  
  // Format to Rupiah currency
  return 'Rp${number.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  )}';
}

class DestinationDetailScreen extends StatelessWidget {
  final Destination destination;
  final LatLng? userLocation;

  const DestinationDetailScreen({
    super.key, 
    required this.destination,
    required this.userLocation,
  });

  // Function to open WhatsApp
  void _openWhatsApp() async {
    const phone = '+6281515450611';
    const message = 'Halo, saya ingin bertanya tentang layanan tambal ban/service kendaraan. Apakah bisa datang ke lokasi saya?';
    final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(
        Uri.parse('https://web.whatsapp.com/send?phone=$phone&text=${Uri.encodeComponent(message)}'),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundWidget = destination.imageUrls.isNotEmpty
        ? CarouselSlider(
            options: CarouselOptions(
              height: 300,
              viewportFraction: 1.0,
              autoPlay: true,
              enableInfiniteScroll: true,
            ),
            items: destination.imageUrls.map((url) {
              return Builder(
                builder: (BuildContext context) {
                  return Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.broken_image, size: 50)),
                      );
                    },
                  );
                },
              );
            }).toList(),
          )
        : Container(
            color: Colors.grey[200],
            child: const Center(child: Icon(Icons.image, size: 50)),
          );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: backgroundWidget,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          destination.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (destination.price != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            formatRupiah(destination.price!),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Rating and location
                  Row(
                    children: [
                      if (destination.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 24),
                            const SizedBox(width: 4),
                            Text(
                              destination.rating.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${destination.reviews?.length ?? 0} reviews)',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(
                                destination: destination,
                                userLocation: userLocation,
                              ),
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.red),
                            SizedBox(width: 4),
                            Text(
                              'View on Map',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Overview
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    destination.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  // Facilities
                  const Text(
                    'Facilities',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      FacilityChip(icon: Icons.wifi, label: 'WiFi'),
                      FacilityChip(icon: Icons.restaurant, label: 'Restaurant'),
                      FacilityChip(icon: Icons.local_parking, label: 'Parking'),
                      FacilityChip(icon: Icons.pool, label: 'Swimming Pool'),
                      FacilityChip(icon: Icons.ac_unit, label: 'Air Conditioner'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // WhatsApp button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _openWhatsApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat, size: 26, color: Colors.white),
                          const SizedBox(width: 12),
                          const Text(
                            'PESAN SEKARANG',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FacilityChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const FacilityChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.blue),
      label: Text(label),
      backgroundColor: Colors.blue[50],
    );
  }
}

class MapScreen extends StatefulWidget {
  final Destination destination;
  final LatLng? userLocation;

  const MapScreen({
    super.key,
    required this.destination,
    required this.userLocation,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late final AnimatedMapController animatedMapController;
  late List<LatLng> routePoints;
  double distance = 0;
  String estimatedTime = '';

  @override
  void initState() {
    super.initState();
    animatedMapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Initialize route points
    routePoints = [];
    
    // Calculate route if locations are available
    if (widget.userLocation != null) {
      final destLocation = widget.destination.location;
      
      routePoints = [
        widget.userLocation!,
        LatLng(destLocation.latitude, destLocation.longitude),
      ];
      
      // Calculate distance
      final Distance distanceCalculator = Distance();
      distance = distanceCalculator(
        widget.userLocation!,
        LatLng(destLocation.latitude, destLocation.longitude),
      ) / 1000; // Convert to kilometers
      
      // Calculate estimated time
      calculateEstimatedTime();
    }
  }

  void calculateEstimatedTime() {
    // Different speed estimates for different distance ranges
    if (distance < 5) {
      // Short distance - walking speed (5 km/h)
      final timeInMinutes = (distance / 5) * 60;
      estimatedTime = '${timeInMinutes.toStringAsFixed(0)} min (jalan kaki)';
    } else if (distance < 50) {
      // Medium distance - city driving (30 km/h)
      final timeInMinutes = (distance / 30) * 60;
      estimatedTime = '${timeInMinutes.toStringAsFixed(0)} min (berkendara)';
    } else {
      // Long distance - highway driving (60 km/h)
      final timeInHours = distance / 60;
      estimatedTime = '${timeInHours.toStringAsFixed(1)} jam (berkendara)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final destLocation = widget.destination.location;
    return Scaffold(
      appBar: AppBar(
        title: Text('Lokasi: ${widget.destination.name}'),
      ),
      body: Column(
        children: [
          // Information bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.userLocation != null)
                  Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.space_dashboard, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Jarak: ${distance.toStringAsFixed(2)} km',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Perkiraan Waktu: $estimatedTime',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  const Text(
                    'Aktifkan lokasi untuk melihat jarak dan waktu tempuh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: animatedMapController.mapController,
                  options: MapOptions(
                    initialCenter: widget.userLocation ?? 
                        LatLng(destLocation.latitude, destLocation.longitude),
                    initialZoom: widget.userLocation != null ? 12 : 15,
                    minZoom: 3,
                    maxZoom: 18,
                    onMapReady: () {
                      animatedMapController.animateTo(
                        dest: LatLng(destLocation.latitude, destLocation.longitude),
                        zoom: 15,
                      );
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.nyobabaruhehe',
                    ),
                    // User location marker
                    if (widget.userLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: widget.userLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    // Destination marker
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            destLocation.latitude,
                            destLocation.longitude,
                          ),
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    // Route polyline
                    if (routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            strokeWidth: 4,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                  ],
                ),
                // Zoom controls
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100, right: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          heroTag: 'zoomIn',
                          mini: true,
                          onPressed: () => animatedMapController.animatedZoomIn(),
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(height: 10),
                        FloatingActionButton(
                          heroTag: 'zoomOut',
                          mini: true,
                          onPressed: () => animatedMapController.animatedZoomOut(),
                          child: const Icon(Icons.remove),
                        ),
                      ],
                    ),
                  ),
                ),
                // Center on destination button
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30, right: 20),
                    child: FloatingActionButton(
                      heroTag: 'center',
                      mini: true,
                      onPressed: () {
                        animatedMapController.animateTo(
                          dest: LatLng(
                            destLocation.latitude,
                            destLocation.longitude,
                          ),
                          zoom: 15,
                        );
                      },
                      child: const Icon(Icons.center_focus_strong),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}