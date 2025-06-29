import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nyoba_modul_5/models/destination.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:nyoba_modul_5/utils/app_constants.dart';
import 'package:nyoba_modul_5/utils/location_service.dart';
import 'package:nyoba_modul_5/widgets/map_view.dart';
import 'package:nyoba_modul_5/widgets/destination_carousel.dart';
import 'package:nyoba_modul_5/screens/map/edit_destination_screen.dart';
import 'package:nyoba_modul_5/screens/map/destination_detail_screen.dart';
import 'package:nyoba_modul_5/services/destination_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}


class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late final AnimatedMapController _animatedMapController;
  late final PageController _pageController;
  late TextEditingController _searchController;
  LatLng? _userLocation;
  LatLng? _highlightedDestination;
  String? _distanceTimeInfo;
  bool _isMapReady = false;
  List<LatLng> _routePoints = [];
  List<Destination> _currentDestinations = [];
  List<Destination> _filteredDestinations = [];
  late Stream<List<Destination>> _destinationsStream;
  final DestinationService _destinationService = DestinationService();
  Timer? _debounceTimer;
  bool _isLoading = true;
  bool _showDistanceInfo = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _pageController = PageController(viewportFraction: 0.8);
    _animatedMapController = AnimatedMapController(vsync: this);
    _checkLocationAndGet();
    
    _destinationsStream = _destinationService.getDestinations();
    _destinationsStream.listen((destinations) {
      if (mounted) {
        setState(() {
          _currentDestinations = destinations;
          _filteredDestinations = destinations;
          _isLoading = false;
        });
      }
    });

    _pageController.addListener(() {
      if (_pageController.hasClients) {
        int? currentPage = _pageController.page?.round();
        if (currentPage != null && currentPage < _filteredDestinations.length) {
          _onDestinationSelected(currentPage);
        }
      }
    });

    _searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDestinations = _currentDestinations;
      } else {
        _filteredDestinations = _currentDestinations.where((destination) {
          return destination.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _pageController.dispose();
    _animatedMapController.dispose();
    super.dispose();
  }

  Future<void> _getDirections(LatLng start, LatLng end) async {
    try {
      final OpenRouteService client = OpenRouteService(
        apiKey: openRouteServiceApiKey,
      );

      final List<ORSCoordinate> routeCoordinates = await client
          .directionsRouteCoordsGet(
            startCoordinate: ORSCoordinate(
              latitude: start.latitude,
              longitude: start.longitude,
            ),
            endCoordinate: ORSCoordinate(
              latitude: end.latitude,
              longitude: end.longitude,
            ),
          );

      final List<LatLng> points = routeCoordinates
          .map((coord) => LatLng(coord.latitude, coord.longitude))
          .toList();

      setState(() {
        _routePoints = points;
      });
    } catch (e) {
      debugPrint('Error getting directions: $e');
      setState(() {
        _routePoints = [];
      });
    }
  }

  Future<void> _checkLocationAndGet() async {
    setState(() => _isLoading = true);
    final locationService = LocationService();
    Position? position = await locationService.getCurrentLocation();

    if (position != null) {
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        if (_isMapReady) {
          _animateToUserLocation();
        }
      }
    } else {
      setState(() => _isLoading = false);
      _showLocationDeniedNotification();
    }
  }

  void _animateToUserLocation() {
    if (_userLocation != null && _isMapReady) {
      _animatedMapController.animateTo(
        dest: _userLocation!,
        zoom: 12.0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showLocationDeniedNotification() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Akses lokasi ditolak. Harap aktifkan lokasi Anda untuk pengalaman terbaik.',
        ),
        action: SnackBarAction(
          label: 'Pengaturan',
          onPressed: () {
            Geolocator.openAppSettings();
          },
        ),
      ),
    );
  }

  void _onDestinationSelected(int index) {
    if (!mounted || index >= _filteredDestinations.length) return;

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final destination = _filteredDestinations[index];
      if (destination.location == null) return;

      LatLng destLatLng = LatLng(
        destination.location.latitude,
        destination.location.longitude,
      );

      if (mounted) {
        setState(() {
          _highlightedDestination = destLatLng;
          _showDistanceInfo = true;
        });
      }

      if (_isMapReady) {
        _animatedMapController.animateTo(
          dest: destLatLng,
          zoom: 12.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }

      if (_userLocation != null) {
        _getDirections(_userLocation!, destLatLng);
        _getDistanceAndTime(_userLocation!, destLatLng);
      }
    });
  }

  Future<void> _getDistanceAndTime(LatLng start, LatLng end) async {
    try {
      final double distanceMeters = Geolocator.distanceBetween(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );

      final double distanceKm = distanceMeters / 1000;
      const double averageSpeedKmPerHour = 40.0;
      final double durationHours = distanceKm / averageSpeedKmPerHour;
      final int durationMinutes = (durationHours * 60).round();

      if (mounted) {
        setState(() {
          _distanceTimeInfo =
              '${distanceKm.toStringAsFixed(2)} km • $durationMinutes menit';
        });
      }
    } catch (e) {
      debugPrint('Error getting distance and time: $e');
      if (mounted) {
        setState(() {
          _distanceTimeInfo = 'Gagal mengambil informasi rute';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapView(
            userLocation: _userLocation,
            destinations: _filteredDestinations,
            animatedMapController: _animatedMapController,
            highlightedDestination: _highlightedDestination,
            routePoints: _routePoints,
            onMapReady: () => setState(() => _isMapReady = true),
          ),
          
          // Top Bar with Back Button, Distance Info, and Location Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                  
                  // Distance and Time Info
                  if (_showDistanceInfo && _distanceTimeInfo != null)
                    AnimatedOpacity(
                      opacity: _showDistanceInfo ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.directions_car,
                              color: Colors.blue,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _distanceTimeInfo!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Location Button
                  GestureDetector(
                    onTap: () {
                      if (_userLocation != null) {
                        _animatedMapController.animateTo(
                          dest: _userLocation!,
                          zoom: 14.0,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _showLocationDeniedNotification();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Modern Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari destinasi...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _filteredDestinations = _currentDestinations;
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          
          // Add Destination Button
          Positioned(
            bottom: 230,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditDestinationScreen(),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, size: 30),
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          
          // Destination Carousel
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            height: 200,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDestinations.isEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Tidak ada destinasi yang ditemukan',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    : DestinationCarousel(
                        destinations: _filteredDestinations,
                        onDestinationTapped: (destination) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DestinationDetailScreen(
                                destination: destination,
                                userLocation: _userLocation,
                              ),
                            ),
                          ).then((returnedDestination) {
                            if (returnedDestination != null &&
                                returnedDestination is Destination) {
                              final index = _filteredDestinations.indexWhere(
                                (d) => d.id == returnedDestination.id,
                              );

                              if (index != -1) {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                _onDestinationSelected(index);
                              }
                            }
                          });
                        },
                        pageController: _pageController,
                        onDestinationSelected: _onDestinationSelected,
                      ),
          ),
        ],
      ),
    );
  }
}