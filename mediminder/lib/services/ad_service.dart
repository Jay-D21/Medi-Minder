import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Use test ads in debug mode, real ads in production
  static String get bannerAdUnitId {
    if (kDebugMode) {
      // Google's test banner ad unit ID - always shows ads
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    return 'ca-app-pub-5797130278067710/4519488333';
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      // Google's test interstitial ad unit ID
      return 'ca-app-pub-3940256099942544/1033173712';
    }
    return 'ca-app-pub-5797130278067710/4415546555';
  }

  Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  BannerAd createBannerAd({
    required Function(Ad) onLoaded,
    required Function(Ad, LoadAdError) onFailed,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: ${error.message}');
          onFailed(ad, error);
          ad.dispose();
        },
      ),
    );
  }

  void loadInterstitialAd({
    required Function(InterstitialAd) onLoaded,
    required Function(LoadAdError) onFailed,
  }) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: onFailed,
      ),
    );
  }
}
