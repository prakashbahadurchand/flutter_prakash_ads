import 'dart:io';
import 'package:flutter/foundation.dart';

/// Provides AdMob App and Ad Unit IDs for all supported ad formats.
/// Supports runtime configuration for real IDs and switches based on [useTestAds].
class AdConstants {
  const AdConstants._();

  /// Defaults to `true` in debug mode. Set to `false` for production.
  static bool useTestAds = kDebugMode;

  /// Optional override for testing platform behaviors.
  @visibleForTesting
  static bool? isAndroidOverride;

  /// Optional override for testing platform behaviors.
  @visibleForTesting
  static bool? isIosOverride;

  /// Whether current platform is Android (considering testing overrides).
  static bool get isAndroid =>
      isAndroidOverride ?? (!kIsWeb && Platform.isAndroid);

  /// Whether current platform is iOS (considering testing overrides).
  static bool get isIOS => isIosOverride ?? (!kIsWeb && Platform.isIOS);

  /// Returns whether Google Mobile Ads is supported on the current runtime platform (Android / iOS).
  static bool get isPlatformSupported => isAndroid || isIOS;

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
  static String androidRealBanner2 = '';
  static String androidRealBanner3 = '';

  static String androidRealInterstitial = '';
  static String androidRealRewarded = '';
  static String androidRealRewardedInterstitial = '';

  static String androidRealNative = '';
  static String androidRealNative2 = '';
  static String androidRealNative3 = '';

  static String androidRealAppOpen = '';

  // ---------------------------------------------------------------------------
  // Real Ad Unit IDs - iOS (Configurable at runtime)
  // ---------------------------------------------------------------------------
  static String iosRealBanner = '';
  static String iosRealBanner2 = '';
  static String iosRealBanner3 = '';

  static String iosRealInterstitial = '';
  static String iosRealRewarded = '';
  static String iosRealRewardedInterstitial = '';

  static String iosRealNative = '';
  static String iosRealNative2 = '';
  static String iosRealNative3 = '';

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

  /// Configures real ad unit IDs specifically for Android.
  static void setRealAndroidAdUnitIds({
    String? banner,
    String? banner2,
    String? banner3,
    String? native,
    String? native2,
    String? native3,
    String? interstitial,
    String? rewardedInterstitial,
    String? rewarded,
    String? appOpen,
  }) {
    if (banner != null) androidRealBanner = banner;
    if (banner2 != null) androidRealBanner2 = banner2;
    if (banner3 != null) androidRealBanner3 = banner3;
    if (native != null) androidRealNative = native;
    if (native2 != null) androidRealNative2 = native2;
    if (native3 != null) androidRealNative3 = native3;
    if (interstitial != null) androidRealInterstitial = interstitial;
    if (rewardedInterstitial != null) {
      androidRealRewardedInterstitial = rewardedInterstitial;
    }
    if (rewarded != null) androidRealRewarded = rewarded;
    if (appOpen != null) androidRealAppOpen = appOpen;
  }

  /// Configures real ad unit IDs specifically for iOS.
  static void setRealIosAdUnitIds({
    String? banner,
    String? banner2,
    String? banner3,
    String? native,
    String? native2,
    String? native3,
    String? interstitial,
    String? rewardedInterstitial,
    String? rewarded,
    String? appOpen,
  }) {
    if (banner != null) iosRealBanner = banner;
    if (banner2 != null) iosRealBanner2 = banner2;
    if (banner3 != null) iosRealBanner3 = banner3;
    if (native != null) iosRealNative = native;
    if (native2 != null) iosRealNative2 = native2;
    if (native3 != null) iosRealNative3 = native3;
    if (interstitial != null) iosRealInterstitial = interstitial;
    if (rewardedInterstitial != null) {
      iosRealRewardedInterstitial = rewardedInterstitial;
    }
    if (rewarded != null) iosRealRewarded = rewarded;
    if (appOpen != null) iosRealAppOpen = appOpen;
  }

  /// Configures real ad unit IDs across Android and iOS.
  static void setRealAdUnitIds({
    String? androidBanner,
    String? androidBanner2,
    String? androidBanner3,
    String? androidNative,
    String? androidNative2,
    String? androidNative3,
    String? androidInterstitial,
    String? androidRewardedInterstitial,
    String? androidRewarded,
    String? androidAppOpen,
    String? iosBanner,
    String? iosBanner2,
    String? iosBanner3,
    String? iosNative,
    String? iosNative2,
    String? iosNative3,
    String? iosInterstitial,
    String? iosRewardedInterstitial,
    String? iosRewarded,
    String? iosAppOpen,
  }) {
    setRealAndroidAdUnitIds(
      banner: androidBanner,
      banner2: androidBanner2,
      banner3: androidBanner3,
      native: androidNative,
      native2: androidNative2,
      native3: androidNative3,
      interstitial: androidInterstitial,
      rewardedInterstitial: androidRewardedInterstitial,
      rewarded: androidRewarded,
      appOpen: androidAppOpen,
    );

    setRealIosAdUnitIds(
      banner: iosBanner,
      banner2: iosBanner2,
      banner3: iosBanner3,
      native: iosNative,
      native2: iosNative2,
      native3: iosNative3,
      interstitial: iosInterstitial,
      rewardedInterstitial: iosRewardedInterstitial,
      rewarded: iosRewarded,
      appOpen: iosAppOpen,
    );
  }

  /// Resets real ad units and test mode configuration to default state.
  static void reset() {
    useTestAds = kDebugMode;
    isAndroidOverride = null;
    isIosOverride = null;
    androidRealAppId = '';
    iosRealAppId = '';

    androidRealBanner = '';
    androidRealBanner2 = '';
    androidRealBanner3 = '';
    androidRealInterstitial = '';
    androidRealRewarded = '';
    androidRealRewardedInterstitial = '';
    androidRealNative = '';
    androidRealNative2 = '';
    androidRealNative3 = '';
    androidRealAppOpen = '';

    iosRealBanner = '';
    iosRealBanner2 = '';
    iosRealBanner3 = '';
    iosRealInterstitial = '';
    iosRealRewarded = '';
    iosRealRewardedInterstitial = '';
    iosRealNative = '';
    iosRealNative2 = '';
    iosRealNative3 = '';
    iosRealAppOpen = '';
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------
  static String get appId {
    if (isAndroid) {
      return (useTestAds || androidRealAppId.isEmpty)
          ? androidTestAppId
          : androidRealAppId;
    }
    if (isIOS) {
      return (useTestAds || iosRealAppId.isEmpty) ? iosTestAppId : iosRealAppId;
    }
    return '';
  }

  /// Primary banner ad unit ID (Unit 1).
  static String get bannerAdUnitId => getBannerAdUnitId(unitIndex: 1);

  /// Secondary banner ad unit ID (Unit 2).
  /// Falls back to [bannerAdUnitId] if unit 2 is not configured.
  static String get bannerAdUnitId2 => getBannerAdUnitId(unitIndex: 2);

  /// Tertiary banner ad unit ID (Unit 3).
  /// Falls back to [bannerAdUnitId2] (and then [bannerAdUnitId]) if unit 3 is not configured.
  static String get bannerAdUnitId3 => getBannerAdUnitId(unitIndex: 3);

  /// Resolves the Banner Ad Unit ID for the specified [unitIndex] (1, 2, or 3) with cascade fallback.
  /// - Unit 1: Returns configured real Unit 1 (or Google test ad if [useTestAds] or unconfigured).
  /// - Unit 2: Returns configured real Unit 2, or falls back to Unit 1.
  /// - Unit 3: Returns configured real Unit 3, or falls back to Unit 2 (which may fall back to Unit 1).
  static String getBannerAdUnitId({int unitIndex = 1}) {
    if (isAndroid) {
      if (useTestAds) return androidTestBanner;
      if (unitIndex <= 1) {
        return androidRealBanner.isNotEmpty
            ? androidRealBanner
            : androidTestBanner;
      } else if (unitIndex == 2) {
        if (androidRealBanner2.isNotEmpty) return androidRealBanner2;
        return androidRealBanner.isNotEmpty
            ? androidRealBanner
            : androidTestBanner;
      } else {
        if (androidRealBanner3.isNotEmpty) return androidRealBanner3;
        if (androidRealBanner2.isNotEmpty) return androidRealBanner2;
        return androidRealBanner.isNotEmpty
            ? androidRealBanner
            : androidTestBanner;
      }
    }
    if (isIOS) {
      if (useTestAds) return iosTestBanner;
      if (unitIndex <= 1) {
        return iosRealBanner.isNotEmpty ? iosRealBanner : iosTestBanner;
      } else if (unitIndex == 2) {
        if (iosRealBanner2.isNotEmpty) return iosRealBanner2;
        return iosRealBanner.isNotEmpty ? iosRealBanner : iosTestBanner;
      } else {
        if (iosRealBanner3.isNotEmpty) return iosRealBanner3;
        if (iosRealBanner2.isNotEmpty) return iosRealBanner2;
        return iosRealBanner.isNotEmpty ? iosRealBanner : iosTestBanner;
      }
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (isAndroid) {
      return (useTestAds || androidRealInterstitial.isEmpty)
          ? androidTestInterstitial
          : androidRealInterstitial;
    }
    if (isIOS) {
      return (useTestAds || iosRealInterstitial.isEmpty)
          ? iosTestInterstitial
          : iosRealInterstitial;
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (isAndroid) {
      return (useTestAds || androidRealRewarded.isEmpty)
          ? androidTestRewarded
          : androidRealRewarded;
    }
    if (isIOS) {
      return (useTestAds || iosRealRewarded.isEmpty)
          ? iosTestRewarded
          : iosRealRewarded;
    }
    return '';
  }

  static String get rewardedInterstitialAdUnitId {
    if (isAndroid) {
      return (useTestAds || androidRealRewardedInterstitial.isEmpty)
          ? androidTestRewardedInterstitial
          : androidRealRewardedInterstitial;
    }
    if (isIOS) {
      return (useTestAds || iosRealRewardedInterstitial.isEmpty)
          ? iosTestRewardedInterstitial
          : iosRealRewardedInterstitial;
    }
    return '';
  }

  /// Primary native ad unit ID (Unit 1).
  static String get nativeAdUnitId => getNativeAdUnitId(unitIndex: 1);

  /// Secondary native ad unit ID (Unit 2).
  /// Falls back to [nativeAdUnitId] if unit 2 is not configured.
  static String get nativeAdUnitId2 => getNativeAdUnitId(unitIndex: 2);

  /// Tertiary native ad unit ID (Unit 3).
  /// Falls back to [nativeAdUnitId2] (and then [nativeAdUnitId]) if unit 3 is not configured.
  static String get nativeAdUnitId3 => getNativeAdUnitId(unitIndex: 3);

  /// Resolves the Native Ad Unit ID for the specified [unitIndex] (1, 2, or 3) with cascade fallback.
  /// - Unit 1: Returns configured real Unit 1 (or Google test ad if [useTestAds] or unconfigured).
  /// - Unit 2: Returns configured real Unit 2, or falls back to Unit 1.
  /// - Unit 3: Returns configured real Unit 3, or falls back to Unit 2 (which may fall back to Unit 1).
  static String getNativeAdUnitId({int unitIndex = 1}) {
    if (isAndroid) {
      if (useTestAds) return androidTestNative;
      if (unitIndex <= 1) {
        return androidRealNative.isNotEmpty
            ? androidRealNative
            : androidTestNative;
      } else if (unitIndex == 2) {
        if (androidRealNative2.isNotEmpty) return androidRealNative2;
        return androidRealNative.isNotEmpty
            ? androidRealNative
            : androidTestNative;
      } else {
        if (androidRealNative3.isNotEmpty) return androidRealNative3;
        if (androidRealNative2.isNotEmpty) return androidRealNative2;
        return androidRealNative.isNotEmpty
            ? androidRealNative
            : androidTestNative;
      }
    }
    if (isIOS) {
      if (useTestAds) return iosTestNative;
      if (unitIndex <= 1) {
        return iosRealNative.isNotEmpty ? iosRealNative : iosTestNative;
      } else if (unitIndex == 2) {
        if (iosRealNative2.isNotEmpty) return iosRealNative2;
        return iosRealNative.isNotEmpty ? iosRealNative : iosTestNative;
      } else {
        if (iosRealNative3.isNotEmpty) return iosRealNative3;
        if (iosRealNative2.isNotEmpty) return iosRealNative2;
        return iosRealNative.isNotEmpty ? iosRealNative : iosTestNative;
      }
    }
    return '';
  }

  static String get appOpenAdUnitId {
    if (isAndroid) {
      return (useTestAds || androidRealAppOpen.isEmpty)
          ? androidTestAppOpen
          : androidRealAppOpen;
    }
    if (isIOS) {
      return (useTestAds || iosRealAppOpen.isEmpty)
          ? iosTestAppOpen
          : iosRealAppOpen;
    }
    return '';
  }
}
