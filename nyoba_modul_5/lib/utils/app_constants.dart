import 'package:latlong2/latlong.dart' hide LatLng;
// import '../models/destination.dart';
import 'package:nyoba_modul_5/models/destination.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const String openRouteServiceApiKey = '5b3ce3597851110001cf62486f3b75436b1a4aa487ffd6f3afc1407f';

final List<Destination> sampleDestinations = [
  Destination(
    name: 'Pianemo Island',
    description: 'Pianemo island in West Papua is considered a small archipel...',
    imageUrls: ['https://cdn.shortpixel.ai/spai/q_lossy+ret_img+to_webp/www.indonesia.travel/content/dam/assets/tourism_development/raja-ampat/Raja%20Ampat.jpg/jcr:content/renditions/cq5dam.thumbnail.700.466.jpeg'],
    location: LatLng(-0.5283, 130.6559),
  ),
  Destination(
    name: 'Labuan Bajo',
    description: 'Gerbang menuju Taman Nasional Komodo, terkenal dengan komodo dan keindahan bawah lautnya.',
    imageUrls: ['https://www.indonesia.travel/content/dam/assets/tourism_development/labuan-bajo/Labuan%20Bajo%20Small%20Thumbnail.jpg/jcr:content/renditions/cq5dam.thumbnail.700.466.jpeg'],
    location: LatLng(-8.4897, 119.8973),
  ),
  Destination(
    name: 'Mboera',
    description: 'Destinasi tersembunyi dengan pemandangan alam yang menakjubkan dan suasana tenang.',
    imageUrls: ['https://via.placeholder.com/150/FFD700/000000?text=Mboera'],
    location: LatLng(-8.4020, 119.8247),
  ),
  Destination(
    name: 'Toerlaing',
    description: 'Terkenal dengan hamparan sawah hijau dan desa tradisional yang ramah.',
    imageUrls: ['https://via.placeholder.com/150/87CEEB/000000?text=Toerlaing'],
    location: LatLng(-8.3000, 120.0000),
  ),
  Destination(
    name: 'Goang',
    description: 'Surga bagi pecinta petualangan dengan gua-gua alami dan trekking yang menantang.',
    imageUrls: ['https://via.placeholder.com/150/98FB98/000000?text=Goang'],
    location: LatLng(-8.6000, 119.9000),
  ),
  Destination(
    name: 'Sessok',
    description: 'Desa pesisir yang menawarkan keindahan pantai dan kehidupan nelayan lokal yang otentik.',
    imageUrls: ['https://via.placeholder.com/150/ADD8E6/000000?text=Sessok'],
    location: LatLng(-8.6500, 120.0500),
  ),
  Destination(
    name: 'Nangolele',
    description: 'Destinasi terpencil yang cocok untuk relaksasi dan menikmati keheningan alam.',
    imageUrls: ['https://via.placeholder.com/150/DA70D6/000000?text=Nangolele'],
    location: LatLng(-8.5000, 120.2000),
  ),
  Destination(
    name: 'Rawa',
    description: 'Kawasan rawa yang kaya akan keanekaragaman hayati dan cocok untuk pengamatan burung.',
    imageUrls: ['https://via.placeholder.com/150/C0C0C0/000000?text=Rawa'],
    location: LatLng(-8.3500, 120.1500),
  ),
  Destination(
    name: 'Limbung',
    description: 'Menawarkan pemandangan pegunungan yang megah dan udara sejuk pegunungan.',
    imageUrls: ['https://via.placeholder.com/150/F08080/000000?text=Limbung'],
    location: LatLng(-8.4000, 120.1000),
  ),
  Destination(
    name: 'Rekas',
    description: 'Desa yang dikenal dengan tradisi dan kerajinan tangan lokalnya yang unik.',
    imageUrls: ['https://via.placeholder.com/150/FF6347/000000?text=Rekas'],
    location: LatLng(-8.3800, 120.0800),
  ),
];