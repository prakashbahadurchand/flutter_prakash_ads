import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_constants.dart';
import 'ad_event.dart';
import 'ads_manager.dart';

/// Service dedicated to managing the lifecycle of Rewarded Interstitial Ads.
///
/// Features:
/// - AdMob Policy Guard: 4-hour max-age cache invalidation.
/// - AdMob Policy Guard: Anti-collision full-screen presentation lock.
/// - Verified user reward callbacks.
/// - Server-Side Verification (SSV) options support.
/// - Exponential backoff retry logic with automatic cancellation on disposal.
/// - Automatic Impression-Level Ad Revenue (ILRD) tracking.
class RewardedInterstitialAdService {
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isLoading = false;
  int _retryAttempts = 0;
  DateTime? _loadTime;
  String? _adUnitId;
  Timer? _retryTimer;
  bool _isDisposed = false;

  /// Max age before cached ad is considered stale according to AdMob policy (4 hours).
  static const Duration maxAdAge = Duration(hours: 4);

  /// Max retry attempts on load failure.
  static const int maxRetryAttempts = 3;

  /// Whether a rewarded interstitial ad is loaded and ready to be shown.
  bool get isAdAvailable {
    if (_isDisposed ||
        _rewardedInterstitialAd == null ||
        _loadTime == null) {
      return false;
    }
    final isStale = DateTime.now().difference(_loadTime!) > maxAdAge;
    if (isStale) {
      developer.log(
        'Cached Rewarded Interstitial Ad has expired (> 4 hours). Discarding.',
        name: 'RewardedInterstitialAdService',
      );
      _rewardedInterstitialAd?.dispose();
      _rewardedInterstitialAd = null;
      _loadTime = null;
      return false;
    }
    return true;
  }

  /// Loads a Rewarded Interstitial Ad.
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

    if (_isLoading || isAdAvailable) return;

    _isLoading = true;
    final effectiveAdUnitId =
        adUnitId ?? AdConstants.rewardedInterstitialAdUnitId;
    _adUnitId = effectiveAdUnitId;

    developer.log(
      'Loading Rewarded Interstitial Ad (Unit: $effectiveAdUnitId)...',
      name: 'RewardedInterstitialAdService',
    );

    RewardedInterstitialAd.load(
      adUnitId: effectiveAdUnitId,
      request: request ?? const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          developer.log(
            'Rewarded Interstitial Ad loaded.',
            name: 'RewardedInterstitialAdService',
          );
          _rewardedInterstitialAd = ad;
          _loadTime = DateTime.now();
          _isLoading = false;
          _retryAttempts = 0;
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.rewardedInterstitial,
              type: AdEventType.loaded,
              adUnitId: effectiveAdUnitId,
            ),
          );
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          developer.log(
            'Rewarded Interstitial Ad failed to load: ${error.message} (code: ${error.code})',
            name: 'RewardedInterstitialAdService',
          );
          _rewardedInterstitialAd = null;
          _loadTime = null;
          _isLoading = false;
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.rewardedInterstitial,
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
              'Retrying Rewarded Interstitial load in $delaySeconds s (attempt $_retryAttempts)...',
              name: 'RewardedInterstitialAdService',
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

  /// Displays the loaded Rewarded Interstitial ad and triggers reward callback.
  void showAd({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    ServerSideVerificationOptions? serverSideVerificationOptions,
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
        'Warning: Another full screen ad is currently active. Rewarded Interstitial skipped.',
        name: 'RewardedInterstitialAdService',
      );
      final error = AdError(
        0,
        'Another full screen ad is currently active.',
        'google_mobile_ads',
      );
      if (onAdFailedToShowFullScreenContent != null) {
        onAdFailedToShowFullScreenContent(error);
      } else {
        onAdDismissedFullScreenContent?.call();
      }
      return;
    }

    if (!isAdAvailable) {
      developer.log(
        'Warning: Attempted to show Rewarded Interstitial Ad before it was loaded. Preloading...',
        name: 'RewardedInterstitialAdService',
      );
      loadAd();
      final error = AdError(
        0,
        'Rewarded Interstitial Ad is not ready yet.',
        'google_mobile_ads',
      );
      if (onAdFailedToShowFullScreenContent != null) {
        onAdFailedToShowFullScreenContent(error);
      } else {
        onAdDismissedFullScreenContent?.call();
      }
      return;
    }

    final effectiveAdUnitId =
        _adUnitId ?? AdConstants.rewardedInterstitialAdUnitId;

    if (serverSideVerificationOptions != null) {
      _rewardedInterstitialAd!.setServerSideOptions(
        serverSideVerificationOptions,
      );
    }

    _rewardedInterstitialAd!.onPaidEvent =
        (ad, valueMicros, precision, currencyCode) {
      AdsManager.emitAdEvent(
        AdEvent(
          format: AdFormat.rewardedInterstitial,
          type: AdEventType.paid,
          adUnitId: effectiveAdUnitId,
          valueMicros: valueMicros.toDouble(),
          precision: precision,
          currencyCode: currencyCode,
        ),
      );
      onPaidEvent?.call(ad, valueMicros, precision, currencyCode);
    };

    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        developer.log(
          'Rewarded Interstitial showed full screen.',
          name: 'RewardedInterstitialAdService',
        );
        AdsManager.instance.isShowingFullScreenAd = true;
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.rewardedInterstitial,
            type: AdEventType.showedFullScreen,
            adUnitId: effectiveAdUnitId,
          ),
        );
        onAdShowedFullScreenContent?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        developer.log(
          'Rewarded Interstitial dismissed.',
          name: 'RewardedInterstitialAdService',
        );
        AdsManager.instance.isShowingFullScreenAd = false;
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.rewardedInterstitial,
            type: AdEventType.dismissedFullScreen,
            adUnitId: effectiveAdUnitId,
          ),
        );
        ad.dispose();
        _rewardedInterstitialAd = null;
        _loadTime = null;
        onAdDismissedFullScreenContent?.call();
        loadAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        developer.log(
          'Rewarded Interstitial failed to show: ${error.message}',
          name: 'RewardedInterstitialAdService',
        );
        AdsManager.instance.isShowingFullScreenAd = false;
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.rewardedInterstitial,
            type: AdEventType.failedToShowFullScreen,
            adUnitId: effectiveAdUnitId,
            adError: error,
          ),
        );
        ad.dispose();
        _rewardedInterstitialAd = null;
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
            format: AdFormat.rewardedInterstitial,
            type: AdEventType.clicked,
            adUnitId: effectiveAdUnitId,
          ),
        );
        onAdClicked?.call();
      },
      onAdImpression: (ad) {
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.rewardedInterstitial,
            type: AdEventType.impression,
            adUnitId: effectiveAdUnitId,
          ),
        );
        onAdImpression?.call();
      },
    );

    try {
      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) {
          developer.log(
            'User earned reward: ${reward.amount} ${reward.type}',
            name: 'RewardedInterstitialAdService',
          );
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.rewardedInterstitial,
              type: AdEventType.rewardEarned,
              adUnitId: effectiveAdUnitId,
              rewardItem: reward,
            ),
          );
          onUserEarnedReward(ad, reward);
        },
      );
    } catch (e) {
      developer.log(
        'Exception occurred while showing Rewarded Interstitial Ad: $e',
        name: 'RewardedInterstitialAdService',
      );
      AdsManager.instance.isShowingFullScreenAd = false;
      _rewardedInterstitialAd?.dispose();
      _rewardedInterstitialAd = null;
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
    _rewardedInterstitialAd?.dispose();
    _rewardedInterstitialAd = null;
    _loadTime = null;
    _isLoading = false;
  }
}
