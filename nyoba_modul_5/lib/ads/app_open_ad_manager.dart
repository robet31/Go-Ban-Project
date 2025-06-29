// lib/app_open_ad_manager.dart
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isAdAvailable = false;
  DateTime? _lastShownTime;

  void loadAd() {
    AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAdAvailable = true;
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _isAdAvailable = false;
              ad.dispose();
              _lastShownTime = DateTime.now();
              Future.delayed(const Duration(seconds: 1), loadAd);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _isAdAvailable = false;
              ad.dispose();
              Future.delayed(const Duration(seconds: 1), loadAd);
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isAdAvailable = false;
          debugPrint('AppOpenAd failed to load: $error');
          Future.delayed(const Duration(seconds: 10), loadAd);
        },
      ),
    );
  }

  void showAdIfAvailable() {
    // Kurangi waktu cooldown untuk testing
    final cooldown = kDebugMode 
        ? const Duration(seconds: 30) 
        : const Duration(minutes: 1);
    
    if (_lastShownTime != null && 
        DateTime.now().difference(_lastShownTime!) < cooldown) {
      debugPrint('App Open Ad skipped: Cooldown period');
      return;
    }
    
    if (_isAdAvailable && _appOpenAd != null) {
      _appOpenAd!.show();
    } else {
      debugPrint('App Open Ad not available - loading new one');
      loadAd();
    }
  }
}