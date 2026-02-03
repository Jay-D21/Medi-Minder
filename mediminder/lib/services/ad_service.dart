import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Test IDs for development, Real IDs for production
  // Note: Using real IDs during dev can lead to ban. Standard practice is test IDs.
  // However, user provided specific IDs. I will use them but typically should be conditional.
  // For safety in this "demo" code, I'll use the user provided IDs but add a note.

  static const String bannerAdUnitId = 'ca-app-pub-5797130278067710/4519488333';
  static const String interstitialAdUnitId =
      'ca-app-pub-5797130278067710/4415546555';

  Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  BannerAd createBannerAd(
      {required Function(Ad) onLoaded,
      required Function(Ad, LoadAdError) onFailed}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (ad, error) {
          onFailed(ad, error);
          ad.dispose();
        },
      ),
    );
  }

  void loadInterstitialAd(
      {required Function(InterstitialAd) onLoaded,
      required Function(LoadAdError) onFailed}) {
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
