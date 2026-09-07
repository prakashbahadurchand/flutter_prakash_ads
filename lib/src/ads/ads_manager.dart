import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_constants.dart';
import 'ad_event.dart';
import 'app_open_ad_manager.dart';
import 'consent_manager.dart';
import 'custom_ad_model.dart';

/// Centralized manager for configuring AdMob IDs, initializing Google Mobile Ads SDK,
/// managing custom/house ads, handling GDPR/CPRA consent, coordinating full-screen ad presentation,
/// and managing ad-free / premium status.
class AdsManager {
  AdsManager._();

  static final AdsManager instance = AdsManager._();

  bool _isInitialized = false;
  bool isShowingFullScreenAd = false;
  InitializationStatus? _initializationStatus;

  // Global reactive notifier for ad removal / IAP ad-free subscriptions
  static final ValueNotifier<bool> adsEnabledNotifier =
      ValueNotifier<bool>(true);

  // Global event listener & stream for analytics (Firebase, Adjust, AppsFlyer)
  static final StreamController<AdEvent> _adEventController =
      StreamController<AdEvent>.broadcast();
  static OnAdEventCallback? _onAdEventCallback;

  // Global custom ad click handler
  static void Function(CustomAdModel ad)? onCustomAdClicked;

  // Registered custom / house ads for offline fallbacks or custom campaigns
  static List<CustomAdModel> _customAds = const [];

  /// Global toggle for network checking. Enabled by default.
  ///
  /// NOTE: Even when `true`, network connectivity is ONLY checked if custom/house
  /// ads have been configured via [setupCustomAds] or if a custom ad fallback widget
  /// is explicitly provided. If no custom ads exist, network checking is bypassed
  /// completely for optimal performance.
  static bool enableNetworkCheck = true;

  bool get isInitialized => _isInitialized;
  InitializationStatus? get initializationStatus => _initializationStatus;

  /// Whether ads are enabled globally. Set to `false` when user purchases "Remove Ads" / Premium.
  static bool get isAdsEnabled => adsEnabledNotifier.value;

  /// Whether custom / house ads have been registered via [setupCustomAds].
  static bool get hasCustomAds => _customAds.isNotEmpty;

  /// Determines if an ad format has any custom fallback ad available.
  ///
  /// Returns `true` if a [customOfflineWidget] is provided, or a [customAd] is
  /// provided, or [showOfflineFallback] is `true` AND [hasCustomAds] is `true`.
  static bool hasCustomAdForFallback({
    CustomAdModel? customAd,
    dynamic customOfflineWidget,
    bool showOfflineFallback = true,
  }) {
    return customOfflineWidget != null ||
        customAd != null ||
        (showOfflineFallback && hasCustomAds);
  }

  /// Enables or disables ads globally (e.g. for In-App Purchase "Remove Ads" / VIP users).
  ///
  /// When set to `false`:
  /// - Mounted Banner & Native ad widgets instantly collapse and dispose their ad objects.
  /// - Interstitial & App Open ads are skipped and dismiss callbacks trigger immediately.
  static void setAdsEnabled(bool enabled) {
    adsEnabledNotifier.value = enabled;
    developer.log('Ads enabled status set to: $enabled', name: 'AdsManager');
  }

  /// Stream of all ad lifecycle and analytics events across all ad formats.
  static Stream<AdEvent> get adEventStream => _adEventController.stream;

  /// Currently configured custom / house ads.
  static List<CustomAdModel> get customAds => List.unmodifiable(_customAds);

  /// Configures custom ads (e.g. for offline fallbacks or house campaigns).
  ///
  /// Example:
  /// ```dart
  /// AdsManager.setupCustomAds([
  ///   CustomAdModel(
  ///     imageUrl: 'assets/images/pro_promo.png',
  ///     title: 'Upgrade to Pro',
  ///     description: 'Remove ads, unlock cloud sync, and access premium features.',
  ///     link: 'https://myapp.com/pro',
  ///     callToAction: 'Upgrade Now',
  ///   ),
  /// ]);
  /// ```
  static void setupCustomAds(List<CustomAdModel> ads) {
    _customAds = List.from(ads);
  }

  /// Retrieves a custom ad by index, or a random custom ad, or `null` if none registered.
  static CustomAdModel? getCustomAd({int? index}) {
    if (_customAds.isEmpty) return null;
    if (index != null && index >= 0 && index < _customAds.length) {
      return _customAds[index];
    }
    return _customAds[Random().nextInt(_customAds.length)];
  }

  /// Clears registered custom ads.
  static void clearCustomAds() {
    _customAds = const [];
  }

  /// Registers a global callback for receiving ad events (e.g. for Firebase Analytics logging).
  ///
  /// Example:
  /// ```dart
  /// AdsManager.onAdEvent((event) {
  ///   FirebaseAnalytics.instance.logEvent(
  ///     name: 'ad_${event.type.name}',
  ///     parameters: {
  ///       'ad_format': event.format.name,
  ///       'ad_unit_id': event.adUnitId ?? '',
  ///     },
  ///   );
  /// });
  /// ```
  static void onAdEvent(OnAdEventCallback callback) {
    _onAdEventCallback = callback;
  }

  /// Clears the global ad event listener callback.
  static void removeAdEventListener() {
    _onAdEventCallback = null;
  }

  /// Internal dispatcher for emitting an ad event to both the listener callback and broadcast stream.
  static void emitAdEvent(AdEvent event) {
    if (kDebugMode) {
      developer.log(
        'AdEvent emitted: ${event.format.name} -> ${event.type.name} (adUnit: ${event.adUnitId})',
        name: 'AdsManager',
      );
    }
    _onAdEventCallback?.call(event);
    if (!_adEventController.isClosed) {
      _adEventController.add(event);
    }
  }

  /// Whether to use official Google test ads instead of real ads.
  static bool get useTestAds => AdConstants.useTestAds;
  static set useTestAds(bool value) => AdConstants.useTestAds = value;

  /// Configures real/production App IDs for Android and iOS.
  static void setRealAppIds({
    String? androidAppId,
    String? iosAppId,
  }) {
    AdConstants.setRealAppIds(
      androidAppId: androidAppId,
      iosAppId: iosAppId,
    );
  }

  /// Configures real/production Ad Unit IDs for all supported ad formats.
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
    AdConstants.setRealAdUnitIds(
      androidBanner: androidBanner,
      androidInterstitial: androidInterstitial,
      androidRewarded: androidRewarded,
      androidRewardedInterstitial: androidRewardedInterstitial,
      androidNative: androidNative,
      androidAppOpen: androidAppOpen,
      iosBanner: iosBanner,
      iosInterstitial: iosInterstitial,
      iosRewarded: iosRewarded,
      iosRewardedInterstitial: iosRewardedInterstitial,
      iosNative: iosNative,
      iosAppOpen: iosAppOpen,
    );
  }

  /// Convenience method to configure both App IDs and Ad Unit IDs in a single call.
  static void setRealAds({
    String? androidAppId,
    String? iosAppId,
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
    bool? useTestAds,
  }) {
    if (useTestAds != null) {
      AdConstants.useTestAds = useTestAds;
    }
    AdConstants.setRealAppIds(
      androidAppId: androidAppId,
      iosAppId: iosAppId,
    );
    AdConstants.setRealAdUnitIds(
      androidBanner: androidBanner,
      androidInterstitial: androidInterstitial,
      androidRewarded: androidRewarded,
      androidRewardedInterstitial: androidRewardedInterstitial,
      androidNative: androidNative,
      androidAppOpen: androidAppOpen,
      iosBanner: iosBanner,
      iosInterstitial: iosInterstitial,
      iosRewarded: iosRewarded,
      iosRewardedInterstitial: iosRewardedInterstitial,
      iosNative: iosNative,
      iosAppOpen: iosAppOpen,
    );
  }

  /// Updates Google Mobile Ads request configuration (COPPA, Families Policy, test devices, content rating).
  static Future<void> updateRequestConfiguration({
    List<String>? testDeviceIds,
    int? tagForChildDirectedTreatment,
    int? tagForUnderAgeOfConsent,
    String? maxAdContentRating,
  }) async {
    if (!AdConstants.isPlatformSupported) return;
    // ignore: deprecated_member_use
    final configuration = RequestConfiguration(
      testDeviceIds: testDeviceIds,
      // ignore: deprecated_member_use
      tagForChildDirectedTreatment: tagForChildDirectedTreatment,
      // ignore: deprecated_member_use
      tagForUnderAgeOfConsent: tagForUnderAgeOfConsent,
      maxAdContentRating: maxAdContentRating,
    );
    await MobileAds.instance.updateRequestConfiguration(configuration);
  }

  /// Registers test device IDs for AdMob test ad verification.
  static Future<void> setTestDeviceIds(List<String> testDeviceIds) async {
    await updateRequestConfiguration(testDeviceIds: testDeviceIds);
  }

  /// Requests User Messaging Platform (UMP) GDPR / CPRA Consent.
  static Future<ConsentResult> requestConsent({
    ConsentDebugSettings? debugSettings,
  }) {
    return ConsentManager.instance.requestConsent(
      debugSettings: debugSettings,
    );
  }

  /// Checks if ads can be requested based on consent status.
  static Future<bool> canRequestAds() {
    return ConsentManager.instance.canRequestAds();
  }

  /// Checks if privacy options (revocation form) are required for this user.
  static Future<bool> isPrivacyOptionsRequired() {
    return ConsentManager.instance.isPrivacyOptionsRequired();
  }

  /// Shows the Privacy Options Form for GDPR/CPRA consent modification.
  static Future<FormError?> showPrivacyOptionsForm() {
    return ConsentManager.instance.showPrivacyOptionsForm();
  }

  /// Resets consent state (useful for debug testing).
  static Future<void> resetConsent() {
    return ConsentManager.instance.resetConsent();
  }

  /// Resets all global state (useful in automated tests or user sign-out flows).
  static void reset() {
    AdConstants.reset();
    clearCustomAds();
    removeAdEventListener();
    onCustomAdClicked = null;
    enableNetworkCheck = true;
    setAdsEnabled(true);
  }

  /// Initializes the Google Mobile Ads SDK.
  /// [testDeviceIds]: Optional list of test device IDs to register for testing.
  Future<InitializationStatus> initialize({List<String>? testDeviceIds}) async {
    if (_isInitialized && _initializationStatus != null) {
      developer.log(
        'Google Mobile Ads SDK already initialized',
        name: 'AdsManager',
      );
      return _initializationStatus!;
    }

    if (!AdConstants.isPlatformSupported) {
      developer.log(
        'Google Mobile Ads is only supported on Android & iOS. Skipping native SDK initialization.',
        name: 'AdsManager',
      );
      _isInitialized = true;
      _initializationStatus = InitializationStatus({});
      return _initializationStatus!;
    }

    if (testDeviceIds != null && testDeviceIds.isNotEmpty) {
      await setTestDeviceIds(testDeviceIds);
    }

    _initializationStatus = await MobileAds.instance.initialize();
    _isInitialized = true;

    if (kDebugMode) {
      developer.log(
        'Google Mobile Ads SDK initialized successfully: ${_initializationStatus!.adapterStatuses}',
        name: 'AdsManager',
      );
    }

    return _initializationStatus!;
  }

  /// Initializes the App Open Ad lifecycle manager.
  Future<void> initializeAppOpenAd() async {
    await AppOpenAdManager.instance.initialize();
  }

  /// Temporarily suppresses or re-enables App Open ads (e.g. during onboarding or payment flows).
  static void setAppOpenSuppressed(bool suppressed) {
    AppOpenAdManager.instance.setSuppressed(suppressed);
  }

  /// Ensures AdsManager is initialized before proceeding with ad requests.
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Helper to create a standard [AdRequest].
  static AdRequest createAdRequest({
    List<String>? keywords,
    String? contentUrl,
    bool? nonPersonalizedAds,
  }) {
    return AdRequest(
      keywords: keywords,
      contentUrl: contentUrl,
      nonPersonalizedAds: nonPersonalizedAds,
    );
  }
}

/// Convenience alias for [AdsManager].
typedef AdManager = AdsManager;
