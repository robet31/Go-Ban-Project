// services/location_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {

  

  static Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> hasPermission() async {
    return await Permission.location.isGranted;
  }
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Jika layanan lokasi mati, kita tidak bisa lanjut
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Jika izin ditolak, kita tidak bisa lanjut
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Jika izin ditolak permanen, kita tidak bisa lanjut
      return null;
    }

    // Jika semua izin sudah diberikan, dapatkan lokasi
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<void> saveUserLocation() async {
    try {
      final position = await getCurrentLocation();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
          'location': GeoPoint(position!.latitude, position.longitude),
          'lastLocationUpdate': FieldValue.serverTimestamp(),
        });
    } catch (e) {
      print('Error getting location: $e');
    }
  }
}