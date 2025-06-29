import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyoba_modul_5/models/destination.dart';

class DestinationListTile extends StatelessWidget {
  final Destination destination;
  final Position? userPosition;
  final VoidCallback? onTap; // Tambahkan ini

  const DestinationListTile({
    super.key,
    required this.destination,
    required this.userPosition, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        destination.imageUrls.isNotEmpty ? destination.imageUrls.first : null;

    // Fungsi untuk menghitung jarak
    String getDistance() {
      if (userPosition == null) {
        return '... km';
      }
      final distanceInMeters = Geolocator.distanceBetween(
        userPosition!.latitude,
        userPosition!.longitude,
        destination.location.latitude,
        destination.location.longitude,
      );
      final distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        // onTap: () {
        //   // Navigasi ke detail screen (tambahkan nanti jika perlu)
        // },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl ?? 'https://via.placeholder.com/150', // Gambar placeholder
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 80),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination.description,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        Row(
                          children: [
                            Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              destination.rating?.toStringAsFixed(1) ?? 'N/A',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Jarak
                        Text(
                          getDistance(),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}