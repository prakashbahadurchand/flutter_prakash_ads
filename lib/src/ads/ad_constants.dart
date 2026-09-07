import 'dart:io';
import 'package:flutter/foundation.dart';

/// Provides AdMob App and Ad Unit IDs for all supported ad formats.
/// Supports runtime configuration for real IDs and switches based on [useTestAds].
class AdConstants {
  const AdConstants._();

  /// Defaults to `true` in debug mode. Set to `false` for production.
  static bool useTestAds = kDebugMode;

  /// Returns whether Google Mobile Ads is supported on the current runtime platform (Android / iOS).
  static bool get isPlatformSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // ---------------------------------------------------------------------------
  // Test App & Ad Unit IDs (Google Official)
  // ---------------------------------------------------------------------------
  static const String androidTestAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String iosTestAppId = 'ca-app-pub-3940256099942544~1458002511';

  static const String androidTestBanner =
      'ca-app-pub-3940256099942544/6300978111';
  static const String androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String androidTestRewarded =
      'ca-app-pub-3940256099942544/5224354917';
  static const String androidTestRewardedInterstitial =
      'ca-app-pub-3940256099942544/5354046379';
  static const String androidTestNative =
      'ca-app-pub-3940256099942544/2247696110';
  static const String androidTestAppOpen =
      'ca-app-pub-3940256099942544/9257390408';

  static const String iosTestBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const String iosTestInterstitial =
      'ca-app-pub-3940256099942544/4411468910';
  static const String iosTestRewarded =
      'ca-app-pub-3940256099942544/1712485313';
  static const String iosTestRewardedInterstitial =
      'ca-app-pub-3940256099942544/6978759866';
  static const String iosTestNative = 'ca-app-pub-3940256099942544/3986624511';
  static const String iosTestAppOpen = 'ca-app-pub-3940256099942544/5575463023';

  // ---------------------------------------------------------------------------
  // Real App IDs (Configurable at runtime)
  // ---------------------------------------------------------------------------
  static String androidRealAppId = '';
  static String iosRealAppId = '';

  // ---------------------------------------------------------------------------
  // Real Ad Unit IDs - Android (Configurable at runtime)
  // ---------------------------------------------------------------------------
  static String androidRealBanner = '';
  static String androidRealInterstitial = '';
  static String androidRealRewarded = '';
  static String androidRealRewardedInterstitial = '';
  static String androidRealNative = '';
  static String androidRealAppOpen = '';

  // ---------------------------------------------------------------------------
  // Real Ad Unit IDs - iOS (Configurable at runtime)
  // ---------------------------------------------------------------------------
  static String iosRealBanner = '';
  static String iosRealInterstitial = '';
  static String iosRealRewarded = '';
  static String iosRealRewardedInterstitial = '';
  static String iosRealNative = '';
  static String iosRealAppOpen = '';

  // ---------------------------------------------------------------------------
  // Initialization Methods
  // ---------------------------------------------------------------------------
  static void setRealAppIds({
    String? androidAppId,
    String? iosAppId,
  }) {
    if (androidAppId != null) androidRealAppId = androidAppId;
    if (iosAppId != null) iosRealAppId = iosAppId;
  }

  static void setRealAdUnitIds({
    String? androidBanner,
    String? androidInterstitial,
    String? androidRewarded,
    String? androidRewardedInterstitial,
    String? androidNative,
    String? androidAppOpen,
    String? iosBanner,
    String? iosInterstitial,
    String? iosRewarded,
    String? iosRewardedInterstitial,
    String? iosNative,
    String? iosAppOpen,
  }) {
    if (androidBanner != null) {
      androidRealBanner = androidBanner;
    }
    if (androidInterstitial != null) {
      androidRealInterstitial = androidInterstitial;
    }
    if (androidRewarded != null) {
      androidRealRewarded = androidRewarded;
    }
    if (androidRewardedInterstitial != null) {
      androidRealRewardedInterstitial = androidRewardedInterstitial;
    }
    if (androidNative != null) {
      androidRealNative = androidNative;
    }
    if (androidAppOpen != null) {
      androidRealAppOpen = androidAppOpen;
    }

    if (iosBanner != null) {
      iosRealBanner = iosBanner;
    }
    if (iosInterstitial != null) {
      iosRealInterstitial = iosInterstitial;
    }
    if (iosRewarded != null) {
      iosRealRewarded = iosRewarded;
    }
    if (iosRewardedInterstitial != null) {
      iosRealRewardedInterstitial = iosRewardedInterstitial;
    }
    if (iosNative != null) {
      iosRealNative = iosNative;
    }
    if (iosAppOpen != null) {
      iosRealAppOpen = iosAppOpen;
    }
  }

  /// Resets real ad units and test mode configuration to default state.
  static void reset() {
    useTestAds = kDebugMode;
    androidRealAppId = '';
    iosRealAppId = '';
    androidRealBanner = '';
    androidRealInterstitial = '';
    androidRealRewarded = '';
    androidRealRewardedInterstitial = '';
    androidRealNative = '';
    androidRealAppOpen = '';
    iosRealBanner = '';
    iosRealInterstitial = '';
    iosRealRewarded = '';
    iosRealRewardedInterstitial = '';
    iosRealNative = '';
    iosRealAppOpen = '';
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------
  static String get appId {
    if (!kIsWeb && Platform.isAndroid) {
      return (useTestAds || androidRealAppId.isEmpty)
          ? androidTestAppId
          : androidRealAppId;
    }
    if (!kIsWeb && Platform.isIOS) {
      return (useTestAds || iosRealAppId.isEmpty) ? iosTestAppId : iosRealAppId;
    }
    return '';
  }

  static String get bannerAdUnitId {
    if (!kIsWeb && Platform.isAndroid) {
      return (useTestAds || androidRealBanner.isEmpty)
          ? androidTestBanner
          : androidRealBanner;
    }
    if (!kIsWeb && Platform.isIOS) {
      return (useTestAds || iosRealBanner.isEmpty)
          ? iosTestBanner
          : iosRealBanner;
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (!kIsWeb && Platform.isAndroid) {
      return (useTestAds || androidRealInterstitial.isEmpty)
          ? androidTestInterstitial
          : androidRealInterstitial;
    }
    if (!kIsWeb && Platform.isIOS) {
      return (useTestAds || iosRealInterstitial.isEmpty)
          ? iosTestInterstitial
          : iosRealInterstitial;
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (!kIsWeb && Platform.isAndroid) {
      return (useTestAds || androidRealRewarded.isEmpty)
          ? androidTestRewarded
          : androidRealRewarded;
    }
    if (!kIsWeb && Platform.isIOS) {
      return (useTestAds || iosRealRewarded.isEmpty)
          ? iosTestRewarded
          : iosRealRewarded;
    }
    return '';
  }

  static String get rewardedInterstitialAdUnitId {
    if (!kIsWeb && Platform.isAndroid) {
      return (useTestAds || androidRealRewardedInterstitial.isEmpty)
          ? androidTestRewardedInterstitial
          : androidRealRewardedInterstitial;
    }
    if (!kIsWeb && Platform.isIOS) {
      return (useTestAds || iosRealRewardedInterstitial.isEmpty)
          ? iosTestRewardedInterstitial
          : iosRealRewardedInterstitial;
    }
    return '';
  }

  static String get nativeAdUnitId {
    if (!kIsWeb && Platform.isAndroid) {
      return (useTestAds || androidRealNative.isEmpty)
          ? androidTestNative
          : androidRealNative;
    }
    if (!kIsWeb && Platform.isIOS) {
      return (useTestAds || iosRealNative.isEmpty)
          ? iosTestNative
          : iosRealNative;
    }
    return '';
  }

  static String get appOpenAdUnitId {
    if (!kIsWeb && Platform.isAndroid) {
      return (useTestAds || androidRealAppOpen.isEmpty)
          ? androidTestAppOpen
          : androidRealAppOpen;
    }
    if (!kIsWeb && Platform.isIOS) {
      return (useTestAds || iosRealAppOpen.isEmpty)
          ? iosTestAppOpen
          : iosRealAppOpen;
    }
    return '';
  }
}
