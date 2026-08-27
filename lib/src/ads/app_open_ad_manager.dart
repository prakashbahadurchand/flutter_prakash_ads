import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ad_constants.dart';
import 'ad_event.dart';
import 'ads_manager.dart';

/// Manages App Open Ad loading, display on cold start / background resume, and policy compliance.
///
/// Features:
/// - AdMob Policy Guard: 4-hour max-age cache invalidation.
/// - AdMob Policy Guard: Skips cold start ad on first app installation session.
/// - AdMob Policy Guard: 4-second cold start timeout deadline.
/// - AdMob Policy Guard: 15-second minimum background threshold to avoid rapid switching fatigue.
/// - AdMob Policy Guard: Anti-collision full-screen presentation lock.
/// - Temporary suppression support via [setSuppressed] (e.g. for onboarding, login, checkout).
/// - Automatic Impression-Level Ad Revenue (ILRD) tracking.
class AppOpenAdManager with WidgetsBindingObserver {
  AppOpenAdManager._();

  static final AppOpenAdManager instance = AppOpenAdManager._();

  AppOpenAd? _appOpenAd;
  bool _isLoading = false;
  bool _isShowingAd = false;
  bool _isSuppressed = false;
  DateTime? _appOpenLoadTime;
  DateTime? _backgroundTime;
  DateTime? _coldStartDeadline;
  bool _isInitialized = false;

  static const String _keyLaunchCount = 'app_open_launch_count';

  /// Maximum duration to hold a cached ad before discarding as stale (4 hours).
  static const Duration maxAdAge = Duration(hours: 4);

  /// Maximum time allowed for cold-start ad to load and present before user enters main app.
  static const Duration coldStartTimeout = Duration(seconds: 4);

  /// Minimum time app must stay in background before showing an App Open ad on return.
  static const Duration backgroundThreshold = Duration(seconds: 15);

  /// Whether an ad is loaded and not expired.
  bool get isAdAvailable {
    if (_appOpenAd == null || _appOpenLoadTime == null) return false;
    final isStale = DateTime.now().difference(_appOpenLoadTime!) > maxAdAge;
    if (isStale) {
      developer.log(
        'Cached App Open Ad has expired (> 4 hours). Discarding.',
        name: 'AppOpenAdManager',
      );
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _appOpenLoadTime = null;
      return false;
    }
    return true;
  }

  /// Initializes the App Open Ad lifecycle manager and registers app state observer.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    WidgetsBinding.instance.addObserver(this);
    _coldStartDeadline = DateTime.now().add(coldStartTimeout);

    try {
      final prefs = await SharedPreferences.getInstance();
      final launchCount = (prefs.getInt(_keyLaunchCount) ?? 0) + 1;
      await prefs.setInt(_keyLaunchCount, launchCount);

      developer.log('App Launch Count: $launchCount', name: 'AppOpenAdManager');

      if (launchCount >= 2) {
        // 2nd cold start or later: preload and show only if ready before deadline
        loadAd(
          onLoaded: () {
            if (_coldStartDeadline != null &&
                DateTime.now().isBefore(_coldStartDeadline!)) {
              developer.log(
                'Cold start ad ready within deadline. Presenting App Open Ad.',
                name: 'AppOpenAdManager',
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showAdIfAvailable();
              });
            } else {
              developer.log(
                'Cold start ad loaded after deadline. Keeping cached for next resume.',
                name: 'AppOpenAdManager',
              );
            }
          },
        );
      } else {
        // 1st launch: preload in background for future resumes without interrupting first impressions
        loadAd();
      }
    } catch (e) {
      developer.log('Error initializing AppOpenAdManager: $e',
          name: 'AppOpenAdManager');
      loadAd();
    }
  }

  /// Preloads an App Open Ad with full error and duplicate guards.
  void loadAd({
    String? adUnitId,
    AdRequest? request,
    VoidCallback? onLoaded,
    Function(LoadAdError error)? onFailedToLoad,
  }) {
    if (_isLoading || isAdAvailable) {
      if (isAdAvailable) onLoaded?.call();
      return;
    }

    _isLoading = true;
    final effectiveAdUnitId = adUnitId ?? AdConstants.appOpenAdUnitId;

    developer.log(
      'Loading App Open Ad (Unit: $effectiveAdUnitId)...',
      name: 'AppOpenAdManager',
    );

    AppOpenAd.load(
      adUnitId: effectiveAdUnitId,
      request: request ?? const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          developer.log('App Open Ad loaded successfully.', name: 'AppOpenAdManager');
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
          _isLoading = false;
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.appOpen,
              type: AdEventType.loaded,
              adUnitId: effectiveAdUnitId,
            ),
          );
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          developer.log(
            'App Open Ad failed to load: ${error.message} (code: ${error.code})',
            name: 'AppOpenAdManager',
          );
          _isLoading = false;
          _appOpenAd = null;
          _appOpenLoadTime = null;
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.appOpen,
              type: AdEventType.failedToLoad,
              adUnitId: effectiveAdUnitId,
              loadAdError: error,
            ),
          );
          onFailedToLoad?.call(error);
        },
      ),
    );
  }

  /// Sets ad suppression flag (e.g. during splash screens, checkout, or login).
  void setSuppressed(bool suppressed) {
    _isSuppressed = suppressed;
    developer.log(
      'App Open Ad suppression set to: $suppressed',
      name: 'AppOpenAdManager',
    );
  }

  /// Shows the App Open ad if available and no other full-screen ad is currently active.
  void showAdIfAvailable({
    VoidCallback? onAdShowedFullScreenContent,
    VoidCallback? onAdDismissedFullScreenContent,
    Function(AdError error)? onAdFailedToShowFullScreenContent,
    OnPaidEventCallback? onPaidEvent,
  }) {
    if (!AdsManager.isAdsEnabled) {
      onAdDismissedFullScreenContent?.call();
      return;
    }

    if (_isSuppressed) {
      developer.log(
        'App Open Ad is currently suppressed.',
        name: 'AppOpenAdManager',
      );
      return;
    }

    // AdMob Policy Guard: Never show if another full-screen ad is currently presented
    if (AdsManager.instance.isShowingFullScreenAd) {
      developer.log(
        'Another full screen ad is active. App Open Ad display skipped.',
        name: 'AppOpenAdManager',
      );
      return;
    }

    if (!isAdAvailable) {
      developer.log(
        'App Open Ad not available. Preloading...',
        name: 'AppOpenAdManager',
      );
      loadAd();
      return;
    }

    if (_isShowingAd) {
      developer.log(
        'App Open Ad is already on screen.',
        name: 'AppOpenAdManager',
      );
      return;
    }

    final effectiveAdUnitId = AdConstants.appOpenAdUnitId;

    _appOpenAd!.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
      AdsManager.emitAdEvent(
        AdEvent(
          format: AdFormat.appOpen,
          type: AdEventType.paid,
          adUnitId: effectiveAdUnitId,
          valueMicros: valueMicros.toDouble(),
          precision: precision,
          currencyCode: currencyCode,
        ),
      );
      onPaidEvent?.call(ad, valueMicros, precision, currencyCode);
    };

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        developer.log('App Open Ad showed full screen.', name: 'AppOpenAdManager');
        _isShowingAd = true;
        AdsManager.instance.isShowingFullScreenAd = true;
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.appOpen,
            type: AdEventType.showedFullScreen,
            adUnitId: effectiveAdUnitId,
          ),
        );
        onAdShowedFullScreenContent?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        developer.log('App Open Ad dismissed.', name: 'AppOpenAdManager');
        _isShowingAd = false;
        AdsManager.instance.isShowingFullScreenAd = false;
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.appOpen,
            type: AdEventType.dismissedFullScreen,
            adUnitId: effectiveAdUnitId,
          ),
        );
        ad.dispose();
        _appOpenAd = null;
        _appOpenLoadTime = null;
        onAdDismissedFullScreenContent?.call();
        loadAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        developer.log(
          'App Open Ad failed to show: ${error.message}',
          name: 'AppOpenAdManager',
        );
        _isShowingAd = false;
        AdsManager.instance.isShowingFullScreenAd = false;
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.appOpen,
            type: AdEventType.failedToShowFullScreen,
            adUnitId: effectiveAdUnitId,
            adError: error,
          ),
        );
        ad.dispose();
        _appOpenAd = null;
        _appOpenLoadTime = null;
        onAdFailedToShowFullScreenContent?.call(error);
        loadAd();
      },
      onAdClicked: (ad) {
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.appOpen,
            type: AdEventType.clicked,
            adUnitId: effectiveAdUnitId,
          ),
        );
      },
      onAdImpression: (ad) {
        AdsManager.emitAdEvent(
          AdEvent(
            format: AdFormat.appOpen,
            type: AdEventType.impression,
            adUnitId: effectiveAdUnitId,
          ),
        );
      },
    );

    try {
      _appOpenAd!.show();
    } catch (e) {
      developer.log('Exception showing App Open Ad: $e', name: 'AppOpenAdManager');
      _isShowingAd = false;
      AdsManager.instance.isShowingFullScreenAd = false;
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _appOpenLoadTime = null;
      loadAd();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTime == null) return;
      final elapsed = DateTime.now().difference(_backgroundTime!);
      _backgroundTime = null;

      // AdMob Policy Guard: Only show if app remained in background >= backgroundThreshold (15s)
      if (elapsed >= backgroundThreshold) {
        developer.log(
          'App resumed after ${elapsed.inSeconds}s in background. Attempting App Open Ad.',
          name: 'AppOpenAdManager',
        );
        showAdIfAvailable();
      } else {
        developer.log(
          'App resumed after only ${elapsed.inSeconds}s. App Open Ad skipped to prevent user fatigue.',
          name: 'AppOpenAdManager',
        );
      }
    }
  }

  /// Disposes active ad and unregisters observer.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _appOpenLoadTime = null;
    _isInitialized = false;
  }
}
