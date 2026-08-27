import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Supported Google Mobile Ads ad formats.
enum AdFormat {
  banner,
  native,
  interstitial,
  rewarded,
  rewardedInterstitial,
  appOpen,
}

/// Lifecycle and analytics event types for Google Mobile Ads.
enum AdEventType {
  /// Ad loaded successfully and is ready to display or cache.
  loaded,

  /// Ad failed to load from AdMob network.
  failedToLoad,

  /// Full-screen ad showed on screen.
  showedFullScreen,

  /// Full-screen ad was dismissed by user or completed.
  dismissedFullScreen,

  /// Full-screen ad failed to present on screen.
  failedToShowFullScreen,

  /// User tapped/clicked the ad.
  clicked,

  /// Impression was recorded by Google Mobile Ads SDK.
  impression,

  /// Impression-level ad revenue (ILRD) paid event triggered.
  paid,

  /// User successfully watched rewarded ad and earned the reward.
  rewardEarned,
}

/// Represents a standardized ad event for analytics logging (e.g. Firebase Analytics, AppsFlyer, Adjust).
class AdEvent {
  AdEvent({
    required this.format,
    required this.type,
    this.adUnitId,
    this.adError,
    this.loadAdError,
    this.valueMicros,
    this.currencyCode,
    this.precision,
    this.rewardItem,
    this.extras,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// The format of the ad (banner, native, interstitial, etc.).
  final AdFormat format;

  /// The specific lifecycle or engagement event.
  final AdEventType type;

  /// The Ad Unit ID associated with the ad.
  final String? adUnitId;

  /// Error details if the ad failed to show.
  final AdError? adError;

  /// Error details if the ad failed to load.
  final LoadAdError? loadAdError;

  /// Revenue value in micros for [AdEventType.paid] events.
  final double? valueMicros;

  /// Revenue currency code (e.g. 'USD') for [AdEventType.paid] events.
  final String? currencyCode;

  /// Revenue precision type for [AdEventType.paid] events.
  final PrecisionType? precision;

  /// Reward item details for [AdEventType.rewardEarned] events.
  final RewardItem? rewardItem;

  /// Additional custom metadata.
  final Map<String, dynamic>? extras;

  /// Timestamp when the event occurred.
  final DateTime timestamp;

  /// Returns revenue value in standard currency units (e.g. dollars instead of micros).
  double? get revenueValue =>
      valueMicros != null ? valueMicros! / 1000000.0 : null;

  /// Whether this event represents a load or presentation error.
  bool get isError => adError != null || loadAdError != null;

  /// Whether this event is an impression-level revenue paid event.
  bool get isPaid => type == AdEventType.paid;

  /// Whether this event was generated from a custom/house ad.
  bool get isCustomAd => extras?['isCustomAd'] == true;

  @override
  String toString() {
    return 'AdEvent(format: ${format.name}, type: ${type.name}, adUnitId: $adUnitId, revenue: $revenueValue $currencyCode, time: $timestamp)';
  }
}

/// Signature for global ad event listener callbacks.
typedef OnAdEventCallback = void Function(AdEvent event);

/// Signature for global custom ad click handler callbacks.
typedef OnCustomAdClickCallback = void Function(dynamic ad);
