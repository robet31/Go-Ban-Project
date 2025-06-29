// lib/interstitial_ad_manager.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  void loadAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          
          // Set callback untuk penanganan setelah iklan ditutup
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              loadAd(); // Muat ulang iklan setelah ditutup
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              loadAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  void showAd() {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      print('Interstitial Ad is not ready yet.');
    }
  }

  bool get isAdLoaded => _isAdLoaded;
}