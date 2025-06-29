// lib/models/destination.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' hide LatLng;

class Destination {
  final String? id;
  final String name;
  final String description;
  final List<String> imageUrls; // Ubah menjadi List
  final LatLng location;
  final String? price;
  final double? rating;

  var reviewsCount;

  var reviews;

  Destination({
    this.id,
    required this.name,
    required this.description,
    required this.imageUrls, // Diubah menjadi List
    required this.location,
    this.price,
    this.rating,
  });

  // Konversi dari Firestore ke object
  factory Destination.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    // Penanganan yang lebih baik untuk lokasi
    GeoPoint? geoPoint;
    if (data['location'] != null && data['location'] is GeoPoint) {
      geoPoint = data['location'] as GeoPoint;
    } else {
      // Jika lokasi tidak ada, gunakan default
      geoPoint = const GeoPoint(0, 0);
    }

    // Handle image URLs
    List<String> imageUrls = [];
    if (data['imageUrls'] is List) {
      imageUrls = (data['imageUrls'] as List).map((e) => e.toString()).toList();
    } else if (data['imageUrl1s'] is String) {
      imageUrls = [data['imageUrl1s'] as String];
    }

    return Destination(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrls: imageUrls,
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      price: data['price'],
      rating: data['rating'] != null 
          ? (data['rating'] is int ? (data['rating'] as int).toDouble() : data['rating'] as double) 
          : null,
    );
  }
  

  // Konversi ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrls': imageUrls,
      'location': GeoPoint(location.latitude, location.longitude),
      if (price != null) 'price': price,
      if (rating != null) 'rating': rating,
    };
  }
}