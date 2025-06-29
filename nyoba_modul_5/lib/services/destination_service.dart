// lib/services/destination_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:latlong2/latlong.dart' hide LatLng;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import '../models/destination.dart';
import 'package:nyoba_modul_5/models/destination.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DestinationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Dio _dio = Dio();

  // Upload multiple images ke Cloudinary
  Future<List<String>> uploadImages(List<File> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      final compressedImage = await _compressImage(image.path);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          compressedImage.path,
          filename: 'image.jpg',
        ),
        'upload_preset': 'tz1jldlq',
      });

      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/duncrb8jk/image/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        imageUrls.add(response.data['secure_url']);
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    }
    return imageUrls;
  }

  // Kompres gambar
  Future<File> _compressImage(String path) async {
    final original = File(path);
    final imageBytes = await original.readAsBytes();
    final image = img.decodeImage(imageBytes)!;

    final compressed = img.copyResize(image, width: 1200, maintainAspect: true);

    final tempFile = File('${original.path}_compressed.jpg');
    await tempFile.writeAsBytes(img.encodeJpg(compressed, quality: 85));
    return tempFile;
  }

  // CRUD Operations
  Future<String> addDestination(Destination destination) async {
    final docRef = await _firestore
        .collection('coba-coba')
        .add(destination.toMap());
    return docRef.id;
  }

  Future<void> updateDestination(Destination destination) async {
    await _firestore
        .collection('coba-coba')
        .doc(destination.id)
        .update(destination.toMap());
  }

  Future<void> deleteDestination(String id) async {
    await _firestore.collection('coba-coba').doc(id).delete();
  }

  Stream<List<Destination>> getDestinations() {
    return _firestore.collection('coba-coba').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return Destination.fromFirestore(doc);
        } catch (e) {
          print("Error parsing document ${doc.id}: $e");
          // Return default destination if parsing fails
          return Destination(
            id: doc.id,
            name: 'Error Destination',
            description: 'Failed to load data',
            imageUrls: [],
            location: LatLng(0, 0),
            price: null,
            rating: null,
          );
        }
      }).toList();
    });
  }
}
