import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class AdProvider with ChangeNotifier {
  final AdService _adService = AdService();

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  // Interstitial Logic
  InterstitialAd? _interstitialAd;
  DateTime? _lastInterstitialTime;
  static const Duration _interstitialInterval = Duration(minutes: 3);

  AdProvider() {
    _adService.init();
    _loadInterstitial();
  }

  void setPremiumStatus(bool isPremium) {
    _isPremium = isPremium;
    if (_isPremium) {
      // Clean up ads if user upgrades
      _interstitialAd?.dispose();
      _interstitialAd = null;
    } else {
      _loadInterstitial();
    }
    notifyListeners();
  }

  void _loadInterstitial() {
    if (_isPremium) return;

    _adService.loadInterstitialAd(
      onLoaded: (ad) {
        _interstitialAd = ad;
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _loadInterstitial(); // Preload next one
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _loadInterstitial();
          },
        );
      },
      onFailed: (error) {
        debugPrint('Interstitial loading failed: $error');
        // Retry logic could go here
      },
    );
  }

  // Returns true if ad was shown, false otherwise
  bool showInterstitialIfReady() {
    if (_isPremium || _interstitialAd == null) return false;

    final now = DateTime.now();
    if (_lastInterstitialTime != null &&
        now.difference(_lastInterstitialTime!) < _interstitialInterval) {
      return false; // Frequency cap hit
    }

    _interstitialAd!.show();
    _lastInterstitialTime = now;
    _interstitialAd = null; // Cleared, relying on callback to reload
    return true;
  }

  // Navigation Logic
  int _screenChangeCount = 0;
  static const int _adTriggerThreshold = 5;

  void incrementNavigationCount() {
    if (_isPremium) return;

    _screenChangeCount++;
    debugPrint('Screen change count: $_screenChangeCount');

    if (_screenChangeCount >= _adTriggerThreshold) {
      // Try to show ad
      final shown = showInterstitialIfReady();
      if (shown) {
        _screenChangeCount = 0;
      }
      // If not shown (due to time limit or not loaded), we keep the count high
      // so it tries again on next screen change.
    }
  }

  // Banner Helper
  BannerAd createBanner(VoidCallback onLoaded) {
    return _adService.createBannerAd(
      onLoaded: (_) => onLoaded(),
      onFailed: (ad, error) => debugPrint('Banner failed: $error'),
    );
  }
}
