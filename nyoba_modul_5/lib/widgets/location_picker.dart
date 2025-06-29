import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPicker extends StatefulWidget {
  final LatLng? initialLocation;
  final ValueChanged<LatLng> onLocationSelected;

  const LocationPicker({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng? _selectedLocation;
  bool _isLocationConfirmed = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lokasi:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedLocation != null
                      ? '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}'
                      : 'Belum ada lokasi dipilih',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectOnMap,
                icon: const Icon(Icons.map),
                label: const Text('Pilih di Peta'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectedLocation != null && !_isLocationConfirmed
                    ? () {
                        setState(() => _isLocationConfirmed = true);
                        widget.onLocationSelected(_selectedLocation!);
                      }
                    : null,
                icon: const Icon(Icons.check),
                label: const Text('Konfirmasi'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        if (_isLocationConfirmed)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Lokasi telah dikonfirmasi',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _selectOnMap() async {
    final location = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionScreen(initialLocation: _selectedLocation),
      ),
    );

    if (location != null) {
      setState(() {
        _selectedLocation = location;
        _isLocationConfirmed = false;
      });
    }
  }
}

class MapSelectionScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const MapSelectionScreen({Key? key, this.initialLocation}) : super(key: key);

  @override
  _MapSelectionScreenState createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation;
    
    // Delay untuk memastikan peta sudah siap
    Future.delayed(Duration(milliseconds: 500), () {
      if (_selectedLocation != null) {
        _mapController.move(_selectedLocation!, 18);
      }
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Lokasi"),
        actions: [
          if (_selectedLocation != null)
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: () => Navigator.pop(context, _selectedLocation),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation ?? const LatLng(-0.5283, 130.6559),
              initialZoom: 18.0,
              maxZoom: 22.0,
              onTap: (tapPosition, point) {
                setState(() => _selectedLocation = point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.nyobabaruhehe',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                  ],
                ),
            ],
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  onPressed: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  ),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  onPressed: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  ),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                if (_selectedLocation != null) {
                  _mapController.move(_selectedLocation!, 18);
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),
          if (_selectedLocation != null)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                color: Colors.black54,
                child: Text(
                  'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedLocation != null) {
            Navigator.pop(context, _selectedLocation);
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}