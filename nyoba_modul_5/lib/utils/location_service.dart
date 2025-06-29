// lib/services/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
// Tidak ada impor UI Flutter langsung di sini, pertahankan pemisahan kekhawatiran.

class LocationService {
  // Callbacks untuk UI untuk menangani status izin/layanan.
  // Ini memungkinkan layanan untuk menginformasikan UI tanpa secara langsung memanipulasinya.
  final Function(String message)? onPermissionDenied;
  final Function(String message)? onServiceDisabled;
  final Function()? onPermissionPermanentlyDenied;

  LocationService({this.onPermissionDenied, this.onServiceDisabled, this.onPermissionPermanentlyDenied});

  Future<Position?> getCurrentLocation() async {
    // 1. Memeriksa apakah layanan lokasi diaktifkan pada perangkat.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Layanan lokasi dinonaktifkan. Informasikan pengguna melalui callback.
      print('Layanan lokasi dinonaktifkan.'); // Untuk logging konsol
      onServiceDisabled?.call('Layanan lokasi dinonaktifkan. Mohon aktifkan layanan lokasi di pengaturan perangkat Anda.');
      return null;
    }

    // 2. Memeriksa status izin lokasi aplikasi.
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Izin ditolak sebelumnya, coba minta izin lagi.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Izin masih ditolak setelah permintaan kedua.
        print('Izin lokasi ditolak'); // Untuk logging konsol
        onPermissionDenied?.call('Izin lokasi ditolak. Aplikasi memerlukan izin lokasi untuk berfungsi.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Izin ditolak secara permanen. Pengguna harus mengaktifkannya secara manual dari pengaturan aplikasi.
      print('Izin lokasi ditolak secara permanen, kami tidak dapat meminta izin.'); // Untuk logging konsol
      onPermissionPermanentlyDenied?.call(); // Memicu callback untuk meminta pembukaan pengaturan
      return null;
    }

    // Jika sampai di sini, izin diberikan dan layanan lokasi aktif.
    // Lanjutkan untuk mendapatkan posisi perangkat.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  /// Metode untuk membuka pengaturan aplikasi, biasanya dipanggil dari lapisan UI
  /// setelah izin lokasi ditolak secara permanen.
  Future<void> openAppSettingsForLocation() async {
    await openAppSettings(); // Fungsi dari permission_handler
  }
}