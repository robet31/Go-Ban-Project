import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:nyoba_modul_5/models/destination.dart';
import 'package:nyoba_modul_5/screens/map/destination_detail_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:nyoba_modul_5/widgets/destination_list_tile.dart';

class AllDestinationsScreen extends StatelessWidget {
  final String title;
  final List<Destination> destinations;
  final Position? userPosition;

  const AllDestinationsScreen({
    super.key,
    required this.title,
    required this.destinations,
    this.userPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF141E46),
          ),
        ),
        backgroundColor: const Color(0xFF8DECB4),
        iconTheme: const IconThemeData(color: Color(0xFF141E46)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          final destination = destinations[index];
          return InkWell(
            onTap: () {
              gmaps.LatLng? userLatLng;
              if (userPosition != null) {
                userLatLng =
                    gmaps.LatLng(userPosition!.latitude, userPosition!.longitude);
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DestinationDetailScreen(
                    destination: destination,
                    userLocation: userLatLng != null ? latlong2.LatLng(userLatLng.latitude, userLatLng.longitude) : null,
                  ),
                ),
              );
            },
            child: DestinationListTile(
              destination: destination,
              userPosition: userPosition,
            ),
          );
        },
      ),
    );
  }
}