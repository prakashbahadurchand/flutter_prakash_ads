import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_constants.dart';
import 'ad_event.dart';
import 'ads_manager.dart';
import 'app_open_ad_manager.dart';

/// Unified contract for all full-screen Google Mobile Ads in features.
abstract class AdsService {
  bool get isInterstitialAdAvailable;
  bool get isRewardedAdAvailable;
  bool get isRewardedInterstitialAdAvailable;
  bool get isAppOpenAdAvailable;

  void loadAllAds();

  void loadInterstitialAd({
    String? adUnitId,
    AdRequest? request,
    VoidCallback? onLoaded,
    Function(LoadAdError error)? onFailedToLoad,
  });

  void showInterstitialAd({
    VoidCallback? onAdShowedFullScreenContent,
    VoidCallback? onAdDismissedFullScreenContent,
    Function(AdError error)? onAdFailedToShowFullScreenContent,
    VoidCallback? onAdClicked,
    VoidCallback? onAdImpression,
    OnPaidEventCallback? onPaidEvent,
  });

  void loadRewardedAd({
    String? adUnitId,
    AdRequest? request,
    VoidCallback? onLoaded,
    Function(LoadAdError error)? onFailedToLoad,
  });

  void showRewardedAd({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    ServerSideVerificationOptions? serverSideVerificationOptions,
    VoidCallback? onAdShowedFullScreenContent,
    VoidCallback? onAdDismissedFullScreenContent,
    Function(AdError error)? onAdFailedToShowFullScreenContent,
    VoidCallback? onAdClicked,
    VoidCallback? onAdImpression,
    OnPaidEventCallback? onPaidEvent,
  });

  void loadRewardedInterstitialAd({
    String? adUnitId,
    AdRequest? request,
    VoidCallback? onLoaded,
    Function(LoadAdError error)? onFailedToLoad,
  });

  void showRewardedInterstitialAd({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    ServerSideVerificationOptions? serverSideVerificationOptions,
    VoidCallback? onAdShowedFullScreenContent,
    VoidCallback? onAdDismissedFullScreenContent,
    Function(AdError error)? onAdFailedToShowFullScreenContent,
    VoidCallback? onAdClicked,
    VoidCallback? onAdImpression,
    OnPaidEventCallback? onPaidEvent,
  });

  void loadAppOpenAd({
    String? adUnitId,
    AdRequest? request,
    VoidCallback? onLoaded,
    Function(LoadAdError error)? onFailedToLoad,
  });

  void showAppOpenAdIfAvailable({
    VoidCallback? onAdShowedFullScreenContent,
    VoidCallback? onAdDismissedFullScreenContent,
    Function(AdError error)? onAdFailedToShowFullScreenContent,
    OnPaidEventCallback? onPaidEvent,
  });

  void dispose();
}

/// Unified, production-grade implementation of [AdsService].
///
/// Fully aligned with Google AdMob & Google Play Policies:
/// - 4-hour max-age cache invalidation
/// - Centralized full-screen ad collision prevention (`AdsManager.instance.isShowingFullScreenAd`)
/// - Exponential backoff retry logic
/// - Minimum interval throttling between interstitials (default 30s)
/// - Automatic event tracking via [AdsManager.onAdEvent]
/// - Automatic disposal and preloading on dismissal
class AdsServiceImpl implements AdsService {
  AdsServiceImpl({
    AppOpenAdManager? appOpenAdManager,
    this.maxRetryAttempts = 3,
    this.maxAdAge = const Duration(hours: 4),
    this.minInterstitialInterval = const Duration(seconds: 30),
  }) : appOpenAdManager = appOpenAdManager ?? AppOpenAdManager.instance;

  static final AdsServiceImpl instance = AdsServiceImpl();

  final AppOpenAdManager appOpenAdManager;
  final int maxRetryAttempts;
  final Duration maxAdAge;
  final Duration minInterstitialInterval;

  // Interstitial Ad State
  InterstitialAd? _interstitialAd;
  DateTime? _interstitialLoadTime;
  DateTime? _lastInterstitialShowTime;
  bool _isInterstitialLoading = false;
  int _interstitialRetryAttempts = 0;

  // Rewarded Video Ad State
  RewardedAd? _rewardedAd;
  DateTime? _rewardedLoadTime;
  bool _isRewardedLoading = false;
  int _rewardedRetryAttempts = 0;

  // Rewarded Interstitial Ad State
  RewardedInterstitialAd? _rewardedInterstitialAd;
  DateTime? _rewardedInterstitialLoadTime;
  bool _isRewardedInterstitialLoading = false;
  int _rewardedInterstitialRetryAttempts = 0;

  @override
  bool get isInterstitialAdAvailable =>
      _interstitialAd != null &&
      _interstitialLoadTime != null &&
      DateTime.now().difference(_interstitialLoadTime!) < maxAdAge;

  @override
  bool get isRewardedAdAvailable =>
      _rewardedAd != null &&
      _rewardedLoadTime != null &&
      DateTime.now().difference(_rewardedLoadTime!) < maxAdAge;

  @override
  bool get isRewardedInterstitialAdAvailable =>
      _rewardedInterstitialAd != null &&
      _rewardedInterstitialLoadTime != null &&
      DateTime.now().difference(_rewardedInterstitialLoadTime!) < maxAdAge;

  @override
  bool get isAppOpenAdAvailable => appOpenAdManager.isAdAvailable;

  @override
  void loadAllAds() {
    loadInterstitialAd();
    loadRewardedAd();
    loadRewardedInterstitialAd();
    loadAppOpenAd();
  }

  // ---------------------------------------------------------------------------
  // Interstitial Ads
  // ---------------------------------------------------------------------------

  @override
  void loadInterstitialAd({
    String? adUnitId,
    AdRequest? request,
    VoidCallback? onLoaded,
    Function(LoadAdError error)? onFailedToLoad,
  }) {
    if (_isInterstitialLoading || isInterstitialAdAvailable) {
      if (isInterstitialAdAvailable) onLoaded?.call();
      return;
    }

    _isInterstitialLoading = true;
    final effectiveAdUnitId = adUnitId ?? AdConstants.interstitialAdUnitId;

    developer.log(
      'Loading Interstitial Ad (Unit: $effectiveAdUnitId)...',
      name: 'AdsService',
    );

    InterstitialAd.load(
      adUnitId: effectiveAdUnitId,
      request: request ?? const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          developer.log('Interstitial Ad loaded.', name: 'AdsService');
          _interstitialAd = ad;
          _interstitialLoadTime = DateTime.now();
          _isInterstitialLoading = false;
          _interstitialRetryAttempts = 0;
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
            name: 'AdsService',
          );
          _interstitialAd = null;
          _interstitialLoadTime = null;
          _isInterstitialLoading = false;
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.interstitial,
              type: AdEventType.failedToLoad,
              adUnitId: effectiveAdUnitId,
              loadAdError: error,
            ),
          );
          onFailedToLoad?.call(error);

          if (_interstitialRetryAttempts < maxRetryAttempts) {
            _interstitialRetryAttempts++;
            final delaySeconds = 1 << _interstitialRetryAttempts;
            developer.log(
              'Retrying Interstitial load in $delaySeconds s (attempt $_interstitialRetryAttempts)...',
              name: 'AdsService',
            );
            Future.delayed(
              Duration(seconds: delaySeconds),
              () => loadInterstitialAd(adUnitId: adUnitId, request: request),
            );
          }
        },
      ),
    );
  }

  @override
  void showInterstitialAd({
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
        'Warning: Another full screen ad is active. Interstitial display skipped.',
        name: 'AdsService',
      );
      onAdDismissedFullScreenContent?.call();
      return;
    }

    // Policy Guard: Minimum interval throttling to prevent user ad fatigue
    if (_lastInterstitialShowTime != null &&
        DateTime.now().difference(_lastInterstitialShowTime!) <
            minInterstitialInterval) {
      developer.log(
        'Interstitial throttled by interval (${minInterstitialInterval.inSeconds}s). Skipping ad display.',
        name: 'AdsService',
      );
      onAdDismissedFullScreenContent?.call();
      return;
    }

    if (!isInterstitialAdAvailable) {
      developer.log(
        'Interstitial Ad not available. Loading...',
        name: 'AdsService',
      );
      loadInterstitialAd();
      onAdDismissedFullScreenContent?.call();
      return;
    }

    final effectiveAdUnitId = AdConstants.interstitialAdUnitId;

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
        _lastInterstitialShowTime = DateTime.now();
        AdsManager.instance.isShowingFullScreenAd = true;
        developer.log(
          'Interstitial Ad presented full screen.',
          name: 'AdsService',
        );
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
        AdsManager.instance.isShowingFullScreenAd = false;
        developer.log('Interstitial Ad dismissed.', name: 'AdsService');
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.interstitial,
            type: AdEventType.dismissedFullScreen,
            adUnitId: effectiveAdUnitId,
          ),
        );
        ad.dispose();
        _interstitialAd = null;
        _interstitialLoadTime = null;
        onAdDismissedFullScreenContent?.call();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AdsManager.instance.isShowingFullScreenAd = false;
        developer.log(
          'Interstitial Ad failed to show: ${error.message}',
          name: 'AdsService',
        );
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
        _interstitialLoadTime = null;
        onAdFailedToShowFullScreenContent?.call(error);
        loadInterstitialAd();
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
      AdsManager.instance.isShowingFullScreenAd = false;
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _interstitialLoadTime = null;
      final error = AdError(0, e.toString(), '');
      AdsManager.emitAdEvent(
        AdEvent(
          format: AdFormat.interstitial,
          type: AdEventType.failedToShowFullScreen,
          adUnitId: effectiveAdUnitId,
          adError: error,
        ),
      );
      onAdFailedToShowFullScreenContent?.call(error);
      loadInterstitialAd();
    }
  }

  // ---------------------------------------------------------------------------
  // Rewarded Video Ads
  // ---------------------------------------------------------------------------

  @override
  void loadRewardedAd({
    String? adUnitId,
    AdRequest? request,
    VoidCallback? onLoaded,
    Function(LoadAdError error)? onFailedToLoad,
  }) {
    if (_isRewardedLoading || isRewardedAdAvailable) {
      if (isRewardedAdAvailable) onLoaded?.call();
      return;
    }

    _isRewardedLoading = true;
    final effectiveAdUnitId = adUnitId ?? AdConstants.rewardedAdUnitId;

    developer.log(
      'Loading Rewarded Video Ad (Unit: $effectiveAdUnitId)...',
      name: 'AdsService',
    );

    RewardedAd.load(
      adUnitId: effectiveAdUnitId,
      request: request ?? const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          developer.log('Rewarded Video Ad loaded.', name: 'AdsService');
          _rewardedAd = ad;
          _rewardedLoadTime = DateTime.now();
          _isRewardedLoading = false;
          _rewardedRetryAttempts = 0;
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.rewarded,
              type: AdEventType.loaded,
              adUnitId: effectiveAdUnitId,
            ),
          );
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          developer.log(
            'Rewarded Video Ad failed to load: ${error.message} (code: ${error.code})',
            name: 'AdsService',
          );
          _rewardedAd = null;
          _rewardedLoadTime = null;
          _isRewardedLoading = false;
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.rewarded,
              type: AdEventType.failedToLoad,
              adUnitId: effectiveAdUnitId,
              loadAdError: error,
            ),
          );
          onFailedToLoad?.call(error);

          if (_rewardedRetryAttempts < maxRetryAttempts) {
            _rewardedRetryAttempts++;
            final delaySeconds = 1 << _rewardedRetryAttempts;
            developer.log(
              'Retrying Rewarded Video load in $delaySeconds s (attempt $_rewardedRetryAttempts)...',
              name: 'AdsService',
            );
            Future.delayed(
              Duration(seconds: delaySeconds),
              () => loadRewardedAd(adUnitId: adUnitId, request: request),
            );
          }
        },
      ),
    );
  }

  @override
  void showRewardedAd({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    ServerSideVerificationOptions? serverSideVerificationOptions,
    VoidCallback? onAdShowedFullScreenContent,
    VoidCallback? onAdDismissedFullScreenContent,
    Function(AdError error)? onAdFailedToShowFullScreenContent,
    VoidCallback? onAdClicked,
    VoidCallback? onAdImpression,
    OnPaidEventCallback? onPaidEvent,
  }) {
    if (AdsManager.instance.isShowingFullScreenAd) {
      developer.log(
        'Warning: Another full screen ad is active. Rewarded Ad display skipped.',
        name: 'AdsService',
      );
      return;
    }

    if (!isRewardedAdAvailable) {
      developer.log(
        'Rewarded Video Ad not available. Loading...',
        name: 'AdsService',
      );
      loadRewardedAd();
      return;
    }

    final effectiveAdUnitId = AdConstants.rewardedAdUnitId;

    if (serverSideVerificationOptions != null) {
      _rewardedAd!.setServerSideOptions(serverSideVerificationOptions);
    }

    _rewardedAd!.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
      AdsManager.emitAdEvent(
        AdEvent(
          format: AdFormat.rewarded,
          type: AdEventType.paid,
          adUnitId: effectiveAdUnitId,
          valueMicros: valueMicros.toDouble(),
          precision: precision,
          currencyCode: currencyCode,
        ),
      );
      onPaidEvent?.call(ad, valueMicros, precision, currencyCode);
    };

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AdsManager.instance.isShowingFullScreenAd = true;
        developer.log(
          'Rewarded Video Ad showed full screen.',
          name: 'AdsService',
        );
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.rewarded,
            type: AdEventType.showedFullScreen,
            adUnitId: effectiveAdUnitId,
          ),
        );
        onAdShowedFullScreenContent?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        AdsManager.instance.isShowingFullScreenAd = false;
        developer.log('Rewarded Video Ad dismissed.', name: 'AdsService');
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.rewarded,
            type: AdEventType.dismissedFullScreen,
            adUnitId: effectiveAdUnitId,
          ),
        );
        ad.dispose();
        _rewardedAd = null;
        _rewardedLoadTime = null;
        onAdDismissedFullScreenContent?.call();
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AdsManager.instance.isShowingFullScreenAd = false;
        developer.log(
          'Rewarded Video Ad failed to show: ${error.message}',
          name: 'AdsService',
        );
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.rewarded,
            type: AdEventType.failedToShowFullScreen,
            adUnitId: effectiveAdUnitId,
            adError: error,
          ),
        );
        ad.dispose();
        _rewardedAd = null;
        _rewardedLoadTime = null;
        onAdFailedToShowFullScreenContent?.call(error);
        loadRewardedAd();
      },
      onAdClicked: (ad) {
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.rewarded,
            type: AdEventType.clicked,
            adUnitId: effectiveAdUnitId,
          ),
        );
        onAdClicked?.call();
      },
      onAdImpression: (ad) {
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.rewarded,
            type: AdEventType.impression,
            adUnitId: effectiveAdUnitId,
          ),
        );
        onAdImpression?.call();
      },
    );

    try {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          developer.log(
            'User earned reward: ${reward.amount} ${reward.type}',
            name: 'AdsService',
          );
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.rewarded,
              type: AdEventType.rewardEarned,
              adUnitId: effectiveAdUnitId,
              rewardItem: reward,
            ),
          );
          onUserEarnedReward(ad, reward);
        },
      );
    } catch (e) {
      AdsManager.instance.isShowingFullScreenAd = false;
      _rewardedAd?.dispose();
      _rewardedAd = null;
      _rewardedLoadTime = null;
      final error = AdError(0, e.toString(), '');
      AdsManager.emitAdEvent(
        AdEvent(
          format: AdFormat.rewarded,
          type: AdEventType.failedToShowFullScreen,
          adUnitId: effectiveAdUnitId,
          adError: error,
        ),
      );
      onAdFailedToShowFullScreenContent?.call(error);
      loadRewardedAd();
    }
  }

  // ---------------------------------------------------------------------------
  // Rewarded Interstitial Ads
  // ---------------------------------------------------------------------------

  @override
  void loadRewardedInterstitialAd({
    String? adUnitId,
    AdRequest? request,
    VoidCallback? onLoaded,
    Function(LoadAdError error)? onFailedToLoad,
  }) {
    if (_isRewardedInterstitialLoading || isRewardedInterstitialAdAvailable) {
      if (isRewardedInterstitialAdAvailable) onLoaded?.call();
      return;
    }

    _isRewardedInterstitialLoading = true;
    final effectiveAdUnitId =
        adUnitId ?? AdConstants.rewardedInterstitialAdUnitId;

    developer.log(
      'Loading Rewarded Interstitial Ad (Unit: $effectiveAdUnitId)...',
      name: 'AdsService',
    );

    RewardedInterstitialAd.load(
      adUnitId: effectiveAdUnitId,
      request: request ?? const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          developer.log(
            'Rewarded Interstitial Ad loaded.',
            name: 'AdsService',
          );
          _rewardedInterstitialAd = ad;
          _rewardedInterstitialLoadTime = DateTime.now();
          _isRewardedInterstitialLoading = false;
          _rewardedInterstitialRetryAttempts = 0;
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
            name: 'AdsService',
          );
          _rewardedInterstitialAd = null;
          _rewardedInterstitialLoadTime = null;
          _isRewardedInterstitialLoading = false;
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.rewardedInterstitial,
              type: AdEventType.failedToLoad,
              adUnitId: effectiveAdUnitId,
              loadAdError: error,
            ),
          );
          onFailedToLoad?.call(error);

          if (_rewardedInterstitialRetryAttempts < maxRetryAttempts) {
            _rewardedInterstitialRetryAttempts++;
            final delaySeconds = 1 << _rewardedInterstitialRetryAttempts;
            developer.log(
              'Retrying Rewarded Interstitial load in $delaySeconds s (attempt $_rewardedInterstitialRetryAttempts)...',
              name: 'AdsService',
            );
            Future.delayed(
              Duration(seconds: delaySeconds),
              () => loadRewardedInterstitialAd(
                adUnitId: adUnitId,
                request: request,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void showRewardedInterstitialAd({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    ServerSideVerificationOptions? serverSideVerificationOptions,
    VoidCallback? onAdShowedFullScreenContent,
    VoidCallback? onAdDismissedFullScreenContent,
    Function(AdError error)? onAdFailedToShowFullScreenContent,
    VoidCallback? onAdClicked,
    VoidCallback? onAdImpression,
    OnPaidEventCallback? onPaidEvent,
  }) {
    if (AdsManager.instance.isShowingFullScreenAd) {
      developer.log(
        'Warning: Another full screen ad is active. Rewarded Interstitial skipped.',
        name: 'AdsService',
      );
      return;
    }

    if (!isRewardedInterstitialAdAvailable) {
      developer.log(
        'Rewarded Interstitial Ad not available. Loading...',
        name: 'AdsService',
      );
      loadRewardedInterstitialAd();
      return;
    }

    final effectiveAdUnitId = AdConstants.rewardedInterstitialAdUnitId;

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
        AdsManager.instance.isShowingFullScreenAd = true;
        developer.log(
          'Rewarded Interstitial Ad showed full screen.',
          name: 'AdsService',
        );
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
        AdsManager.instance.isShowingFullScreenAd = false;
        developer.log(
          'Rewarded Interstitial Ad dismissed.',
          name: 'AdsService',
        );
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.rewardedInterstitial,
            type: AdEventType.dismissedFullScreen,
            adUnitId: effectiveAdUnitId,
          ),
        );
        ad.dispose();
        _rewardedInterstitialAd = null;
        _rewardedInterstitialLoadTime = null;
        onAdDismissedFullScreenContent?.call();
        loadRewardedInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AdsManager.instance.isShowingFullScreenAd = false;
        developer.log(
          'Rewarded Interstitial Ad failed to show: ${error.message}',
          name: 'AdsService',
        );
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
        _rewardedInterstitialLoadTime = null;
        onAdFailedToShowFullScreenContent?.call(error);
        loadRewardedInterstitialAd();
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
            name: 'AdsService',
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
      AdsManager.instance.isShowingFullScreenAd = false;
      _rewardedInterstitialAd?.dispose();
      _rewardedInterstitialAd = null;
      _rewardedInterstitialLoadTime = null;
      final error = AdError(0, e.toString(), '');
      AdsManager.emitAdEvent(
        AdEvent(
          format: AdFormat.rewardedInterstitial,
          type: AdEventType.failedToShowFullScreen,
          adUnitId: effectiveAdUnitId,
          adError: error,
        ),
      );
      onAdFailedToShowFullScreenContent?.call(error);
      loadRewardedInterstitialAd();
    }
  }

  // ---------------------------------------------------------------------------
  // App Open Ads
  // ---------------------------------------------------------------------------

  @override
  void loadAppOpenAd({
    String? adUnitId,
    AdRequest? request,
    VoidCallback? onLoaded,
    Function(LoadAdError error)? onFailedToLoad,
  }) {
    appOpenAdManager.loadAd(
      adUnitId: adUnitId,
      request: request,
      onLoaded: onLoaded,
      onFailedToLoad: onFailedToLoad,
    );
  }

  @override
  void showAppOpenAdIfAvailable({
    VoidCallback? onAdShowedFullScreenContent,
    VoidCallback? onAdDismissedFullScreenContent,
    Function(AdError error)? onAdFailedToShowFullScreenContent,
    OnPaidEventCallback? onPaidEvent,
  }) {
    appOpenAdManager.showAdIfAvailable(
      onAdShowedFullScreenContent: onAdShowedFullScreenContent,
      onAdDismissedFullScreenContent: onAdDismissedFullScreenContent,
      onAdFailedToShowFullScreenContent: onAdFailedToShowFullScreenContent,
      onPaidEvent: onPaidEvent,
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _interstitialLoadTime = null;

    _rewardedAd?.dispose();
    _rewardedAd = null;
    _rewardedLoadTime = null;

    _rewardedInterstitialAd?.dispose();
    _rewardedInterstitialAd = null;
    _rewardedInterstitialLoadTime = null;
  }
}
