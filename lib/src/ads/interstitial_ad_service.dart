import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_constants.dart';
import 'ad_event.dart';
import 'ads_manager.dart';

/// Service dedicated to managing the lifecycle of Interstitial Ads.
///
/// Features:
/// - AdMob Policy Guard: 4-hour max-age cache invalidation.
/// - AdMob Policy Guard: Anti-collision full-screen presentation lock.
/// - AdMob Policy Guard: Minimum interval throttling (30s) to prevent user fatigue.
/// - Exponential backoff retry logic with automatic cancellation on disposal.
/// - Automatic Impression-Level Ad Revenue (ILRD) tracking.
class InterstitialAdService {
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  int _retryAttempts = 0;
  DateTime? _loadTime;
  DateTime? _lastShowTime;
  String? _adUnitId;
  Timer? _retryTimer;
  bool _isDisposed = false;

  /// Max age before cached ad is considered stale according to AdMob policy (4 hours).
  static const Duration maxAdAge = Duration(hours: 4);

  /// Minimum interval between showing interstitial ads to prevent ad fatigue (30 seconds).
  static const Duration minInterstitialInterval = Duration(seconds: 30);

  /// Max retry attempts on load failure.
  static const int maxRetryAttempts = 3;

  /// Whether an interstitial ad is loaded and ready to be shown.
  bool get isAdAvailable {
    if (_isDisposed || _interstitialAd == null || _loadTime == null) return false;
    final isStale = DateTime.now().difference(_loadTime!) > maxAdAge;
    if (isStale) {
      developer.log(
        'Cached Interstitial Ad has expired (> 4 hours). Discarding.',
        name: 'InterstitialAdService',
      );
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _loadTime = null;
      return false;
    }
    return true;
  }

  /// Loads an Interstitial Ad.
  void loadAd({
    String? adUnitId,
    AdRequest? request,
    VoidCallback? onLoaded,
    Function(LoadAdError error)? onFailedToLoad,
  }) {
    if (!AdConstants.isPlatformSupported ||
        !AdsManager.isAdsEnabled ||
        _isDisposed) {
      return;
    }

    if (_isLoading || isAdAvailable) {
      if (isAdAvailable) onLoaded?.call();
      return;
    }

    _isLoading = true;
    final effectiveAdUnitId =
        adUnitId ?? _adUnitId ?? AdConstants.interstitialAdUnitId;

    InterstitialAd.load(
      adUnitId: effectiveAdUnitId,
      request: request ?? const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          developer.log(
            'Interstitial Ad loaded.',
            name: 'InterstitialAdService',
          );
          _interstitialAd = ad;
          _loadTime = DateTime.now();
          _isLoading = false;
          _retryAttempts = 0;
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.interstitial,
              type: AdEventType.loaded,
              adUnitId: effectiveAdUnitId,
            ),
          );
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          developer.log(
            'Interstitial Ad failed to load: ${error.message} (code: ${error.code})',
            name: 'InterstitialAdService',
          );
          _interstitialAd = null;
          _loadTime = null;
          _isLoading = false;
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.interstitial,
              type: AdEventType.failedToLoad,
              adUnitId: effectiveAdUnitId,
              loadAdError: error,
            ),
          );
          onFailedToLoad?.call(error);

          if (_retryAttempts < maxRetryAttempts && !_isDisposed) {
            _retryAttempts++;
            final delaySeconds = 1 << _retryAttempts;
            developer.log(
              'Retrying Interstitial load in $delaySeconds s (attempt $_retryAttempts)...',
              name: 'InterstitialAdService',
            );
            _retryTimer?.cancel();
            _retryTimer = Timer(
              Duration(seconds: delaySeconds),
              () {
                if (!_isDisposed) {
                  loadAd(adUnitId: adUnitId, request: request);
                }
              },
            );
          }
        },
      ),
    );
  }

  /// Displays the loaded Interstitial ad with interval throttling and collision guards.
  void showAd({
    VoidCallback? onAdShowedFullScreenContent,
    VoidCallback? onAdDismissedFullScreenContent,
    Function(AdError error)? onAdFailedToShowFullScreenContent,
    VoidCallback? onAdClicked,
    VoidCallback? onAdImpression,
    OnPaidEventCallback? onPaidEvent,
  }) {
    if (!AdsManager.isAdsEnabled) {
      onAdDismissedFullScreenContent?.call();
      return;
    }

    if (AdsManager.instance.isShowingFullScreenAd) {
      developer.log(
        'Warning: Another full screen ad is currently active. Interstitial skipped.',
        name: 'InterstitialAdService',
      );
      onAdDismissedFullScreenContent?.call();
      return;
    }

    // Policy Guard: Minimum interval throttling to prevent user ad fatigue
    if (_lastShowTime != null &&
        DateTime.now().difference(_lastShowTime!) < minInterstitialInterval) {
      developer.log(
        'Interstitial throttled by interval (${minInterstitialInterval.inSeconds}s). Skipping ad display.',
        name: 'InterstitialAdService',
      );
      onAdDismissedFullScreenContent?.call();
      return;
    }

    if (!isAdAvailable) {
      developer.log(
        'Warning: Interstitial Ad not available. Preloading...',
        name: 'InterstitialAdService',
      );
      loadAd();
      onAdDismissedFullScreenContent?.call();
      return;
    }

    final effectiveAdUnitId = _adUnitId ?? AdConstants.interstitialAdUnitId;

    _interstitialAd!.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
      AdsManager.emitAdEvent(
        AdEvent(
          format: AdFormat.interstitial,
          type: AdEventType.paid,
          adUnitId: effectiveAdUnitId,
          valueMicros: valueMicros.toDouble(),
          precision: precision,
          currencyCode: currencyCode,
        ),
      );
      onPaidEvent?.call(ad, valueMicros, precision, currencyCode);
    };

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        developer.log('Interstitial showed full screen.',
            name: 'InterstitialAdService');
        AdsManager.instance.isShowingFullScreenAd = true;
        _lastShowTime = DateTime.now();
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.interstitial,
            type: AdEventType.showedFullScreen,
            adUnitId: effectiveAdUnitId,
          ),
        );
        onAdShowedFullScreenContent?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        developer.log('Interstitial dismissed.', name: 'InterstitialAdService');
        AdsManager.instance.isShowingFullScreenAd = false;
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.interstitial,
            type: AdEventType.dismissedFullScreen,
            adUnitId: effectiveAdUnitId,
          ),
        );
        ad.dispose();
        _interstitialAd = null;
        _loadTime = null;
        onAdDismissedFullScreenContent?.call();
        loadAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        developer.log(
          'Interstitial failed to show: ${error.message}',
          name: 'InterstitialAdService',
        );
        AdsManager.instance.isShowingFullScreenAd = false;
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.interstitial,
            type: AdEventType.failedToShowFullScreen,
            adUnitId: effectiveAdUnitId,
            adError: error,
          ),
        );
        ad.dispose();
        _interstitialAd = null;
        _loadTime = null;
        if (onAdFailedToShowFullScreenContent != null) {
          onAdFailedToShowFullScreenContent(error);
        } else {
          onAdDismissedFullScreenContent?.call();
        }
        loadAd();
      },
      onAdClicked: (ad) {
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.interstitial,
            type: AdEventType.clicked,
            adUnitId: effectiveAdUnitId,
          ),
        );
        onAdClicked?.call();
      },
      onAdImpression: (ad) {
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.interstitial,
            type: AdEventType.impression,
            adUnitId: effectiveAdUnitId,
          ),
        );
        onAdImpression?.call();
      },
    );

    try {
      _interstitialAd!.show();
    } catch (e) {
      developer.log(
        'Exception occurred while showing Interstitial Ad: $e',
        name: 'InterstitialAdService',
      );
      AdsManager.instance.isShowingFullScreenAd = false;
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _loadTime = null;
      final error = AdError(0, e.toString(), 'google_mobile_ads');
      if (onAdFailedToShowFullScreenContent != null) {
        onAdFailedToShowFullScreenContent(error);
      } else {
        onAdDismissedFullScreenContent?.call();
      }
      loadAd();
    }
  }

  /// Disposes active ad and cancels state.
  void dispose() {
    _isDisposed = true;
    _retryTimer?.cancel();
    _retryTimer = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _loadTime = null;
    _isLoading = false;
  }
}
