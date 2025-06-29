// lib/ad_helper.dart
import 'package:flutter/foundation.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    }
    return 'ca-app-pub-2552969431971131/5473053990'; // ID Banner Produksi
  }

  static String get nativeAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/2247696110'; // Test ID
    }
    return 'ca-app-pub-2552969431971131/4192596061'; // ID Native Ads Produksi
  }

  static String get appOpenAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/3419835294'; // Test ID
    }
    return 'ca-app-pub-2552969431971131/4080097183'; // ID App Open Ad Produksi
  }

  // Tambahkan untuk Interstitial Ad
  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    }
    return 'ca-app-pub-2552969431971131/7920922234'; // ID Interstitial Produksi
  }
}