import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../network/network_info.dart';
import 'ad_constants.dart';
import 'ad_event.dart';
import 'ads_manager.dart';
import 'custom_ad_model.dart';
import 'custom_offline_banner_ad_widget.dart';

/// A smart, policy-compliant reusable widget for displaying Banner Ads.
///
/// Features:
/// - Real-time network detection via [NetworkInfo].
/// - Seamless fallback to [CustomOfflineBannerAdWidget] with [CustomAdModel] support when disconnected.
/// - Automatic event tracking via [AdsManager.onAdEvent].
/// - Fixed bounds preventing Cumulative Layout Shift (CLS) and accidental clicks.
/// - Optional [onPaidEvent] for Impression-Level Ad Revenue (ILRD) and LTV tracking.
/// - Reactive global ad suppression support when [AdsManager.isAdsEnabled] is `false`.
/// - Automatic disposal and memory cleanup.
class SmartBannerAdView extends StatefulWidget {
  const SmartBannerAdView({
    super.key,
    this.adUnitId,
    this.adUnitIndex = 1,
    this.adSize = AdSize.banner,
    this.adRequest,
    this.customAd,
    this.showOfflineFallback = true,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
    this.onPaidEvent,
    this.placeholder,
    this.customOfflineWidget,
    this.networkInfo,
  });

  /// Factory constructor to display the secondary Banner ad unit (Unit 2).
  /// Falls back to Unit 1 if Unit 2 is not configured.
  factory SmartBannerAdView.withAdUnitId2({
    Key? key,
    String? adUnitId,
    AdSize adSize = AdSize.banner,
    AdRequest? adRequest,
    CustomAdModel? customAd,
    bool showOfflineFallback = true,
    VoidCallback? onAdLoaded,
    Function(LoadAdError error)? onAdFailedToLoad,
    VoidCallback? onAdClicked,
    OnPaidEventCallback? onPaidEvent,
    Widget? placeholder,
    Widget? customOfflineWidget,
    NetworkInfo? networkInfo,
  }) {
    return SmartBannerAdView(
      key: key,
      adUnitId: adUnitId,
      adUnitIndex: 2,
      adSize: adSize,
      adRequest: adRequest,
      customAd: customAd,
      showOfflineFallback: showOfflineFallback,
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad,
      onAdClicked: onAdClicked,
      onPaidEvent: onPaidEvent,
      placeholder: placeholder,
      customOfflineWidget: customOfflineWidget,
      networkInfo: networkInfo,
    );
  }

  /// Factory constructor to display the tertiary Banner ad unit (Unit 3).
  /// Falls back to Unit 2 (and Unit 1) if Unit 3 is not configured.
  factory SmartBannerAdView.withAdUnitId3({
    Key? key,
    String? adUnitId,
    AdSize adSize = AdSize.banner,
    AdRequest? adRequest,
    CustomAdModel? customAd,
    bool showOfflineFallback = true,
    VoidCallback? onAdLoaded,
    Function(LoadAdError error)? onAdFailedToLoad,
    VoidCallback? onAdClicked,
    OnPaidEventCallback? onPaidEvent,
    Widget? placeholder,
    Widget? customOfflineWidget,
    NetworkInfo? networkInfo,
  }) {
    return SmartBannerAdView(
      key: key,
      adUnitId: adUnitId,
      adUnitIndex: 3,
      adSize: adSize,
      adRequest: adRequest,
      customAd: customAd,
      showOfflineFallback: showOfflineFallback,
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad,
      onAdClicked: onAdClicked,
      onPaidEvent: onPaidEvent,
      placeholder: placeholder,
      customOfflineWidget: customOfflineWidget,
      networkInfo: networkInfo,
    );
  }

  /// Custom Ad Unit ID. If null, default configured or test ID from [AdConstants] is used.
  final String? adUnitId;

  /// The ad unit slot index (1, 2, or 3) to use if [adUnitId] is null. Defaults to 1.
  final int adUnitIndex;

  /// Ad size (default: AdSize.banner - 320x50).
  final AdSize adSize;

  /// Optional custom [AdRequest] parameters (keywords, targeting, etc.).
  final AdRequest? adRequest;

  /// Custom ad model to use for offline fallback or direct campaigns.
  final CustomAdModel? customAd;

  /// Whether to render a custom offline banner ad when disconnected or on load error.
  final bool showOfflineFallback;

  /// Callback when ad loads successfully.
  final VoidCallback? onAdLoaded;

  /// Callback when ad fails to load.
  final Function(LoadAdError error)? onAdFailedToLoad;

  /// Callback when ad is clicked.
  final VoidCallback? onAdClicked;

  /// Impression-level ad revenue callback for analytics (e.g. Firebase, Adjust, AppsFlyer).
  final OnPaidEventCallback? onPaidEvent;

  /// Widget to show while loading.
  final Widget? placeholder;

  /// Custom offline fallback widget to override default fallback.
  final Widget? customOfflineWidget;

  /// Optional network info checker for connectivity updates. Defaults to [NetworkInfoImpl].
  final NetworkInfo? networkInfo;

  /// Helper to calculate an Anchored Adaptive Banner size based on the current device orientation and screen width.
  static Future<AnchoredAdaptiveBannerAdSize?> getAnchoredAdaptiveAdSize(
    BuildContext context, {
    Orientation? orientation,
    double? width,
  }) async {
    final effectiveOrientation =
        orientation ?? MediaQuery.orientationOf(context);
    final effectiveWidth =
        width?.toInt() ?? MediaQuery.sizeOf(context).width.truncate();
    return AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
      effectiveOrientation,
      effectiveWidth,
    );
  }

  @override
  State<SmartBannerAdView> createState() => _SmartBannerAdViewState();
}

class _SmartBannerAdViewState extends State<SmartBannerAdView> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _hasError = false;
  bool _isConnected = true;
  StreamSubscription<InternetStatus>? _networkSubscription;
  NetworkInfo? _networkInfo;

  /// Whether a custom fallback ad is available either via widget or AdsManager.
  bool get _hasCustomAdFallback => AdsManager.hasCustomAdForFallback(
        customAd: widget.customAd,
        customOfflineWidget: widget.customOfflineWidget,
        showOfflineFallback: widget.showOfflineFallback,
      );

  /// Only check the network if a custom fallback is available or NetworkInfo was explicitly provided.
  /// If the app developer has not configured custom ads, network checking is completely bypassed.
  bool get _shouldCheckNetwork =>
      widget.networkInfo != null ||
      (_hasCustomAdFallback && AdsManager.enableNetworkCheck);

  @override
  void initState() {
    super.initState();
    AdsManager.adsEnabledNotifier.addListener(_onAdsEnabledChanged);

    if (_shouldCheckNetwork) {
      _setupNetworkMonitoring();
    }

    if (AdsManager.isAdsEnabled) {
      _loadBannerAd();
    }
  }

  void _setupNetworkMonitoring() {
    _networkInfo = widget.networkInfo ?? NetworkInfoImpl();
    _networkSubscription?.cancel();
    _networkSubscription = _networkInfo!.onStatusChange.listen((status) {
      final connected = status == InternetStatus.connected;
      if (connected != _isConnected) {
        if (mounted) {
          setState(() {
            _isConnected = connected;
          });
          if (connected && !_isAdLoaded && AdsManager.isAdsEnabled) {
            _loadBannerAd();
          }
        }
      }
    });

    // Asynchronously verify initial connection without blocking ad load dispatch
    _networkInfo!.isConnected.then((connected) {
      if (mounted && connected != _isConnected) {
        setState(() {
          _isConnected = connected;
        });
      }
    });
  }

  void _teardownNetworkMonitoring() {
    _networkSubscription?.cancel();
    _networkSubscription = null;
    _networkInfo = null;
  }

  void _onAdsEnabledChanged() {
    if (!AdsManager.isAdsEnabled) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _isAdLoaded = false;
      if (mounted) setState(() {});
    } else if (!_isAdLoaded && _isConnected) {
      _loadBannerAd();
    }
  }

  @override
  void didUpdateWidget(covariant SmartBannerAdView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!AdsManager.isAdsEnabled) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _isAdLoaded = false;
      return;
    }

    final oldShouldCheck = oldWidget.networkInfo != null ||
        (AdsManager.hasCustomAdForFallback(
              customAd: oldWidget.customAd,
              customOfflineWidget: oldWidget.customOfflineWidget,
              showOfflineFallback: oldWidget.showOfflineFallback,
            ) &&
            AdsManager.enableNetworkCheck);

    if (_shouldCheckNetwork != oldShouldCheck) {
      if (_shouldCheckNetwork) {
        _setupNetworkMonitoring();
      } else {
        _teardownNetworkMonitoring();
      }
    }

    if (widget.adUnitId != oldWidget.adUnitId ||
        widget.adUnitIndex != oldWidget.adUnitIndex ||
        widget.adSize != oldWidget.adSize ||
        widget.adRequest != oldWidget.adRequest) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _isAdLoaded = false;
      _hasError = false;
      if (_isConnected) {
        _loadBannerAd();
      }
    }
  }

  void _loadBannerAd() {
    if (!AdsManager.isAdsEnabled) return;
    if (!AdConstants.isPlatformSupported) return;

    final effectiveAdUnitId =
        (widget.adUnitId != null && widget.adUnitId!.isNotEmpty)
            ? widget.adUnitId!
            : AdConstants.getBannerAdUnitId(unitIndex: widget.adUnitIndex);
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: effectiveAdUnitId,
      size: widget.adSize,
      request: widget.adRequest ?? const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          developer.log(
            'SmartBannerAdView loaded (${widget.adSize.width}x${widget.adSize.height})',
            name: 'SmartBannerAdView',
          );
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.banner,
              type: AdEventType.loaded,
              adUnitId: effectiveAdUnitId,
            ),
          );
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _hasError = false;
            });
            widget.onAdLoaded?.call();
          }
        },
        onAdFailedToLoad: (ad, error) {
          developer.log(
            'SmartBannerAdView failed to load: ${error.message}',
            name: 'SmartBannerAdView',
          );
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.banner,
              type: AdEventType.failedToLoad,
              adUnitId: effectiveAdUnitId,
              loadAdError: error,
            ),
          );
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _hasError = true;
            });
            widget.onAdFailedToLoad?.call(error);
          }
        },
        onAdClicked: (ad) {
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.banner,
              type: AdEventType.clicked,
              adUnitId: effectiveAdUnitId,
            ),
          );
          widget.onAdClicked?.call();
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          developer.log(
            'Banner Paid Event: $valueMicros micros ($currencyCode)',
            name: 'SmartBannerAdView',
          );
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.banner,
              type: AdEventType.paid,
              adUnitId: effectiveAdUnitId,
              valueMicros: valueMicros.toDouble(),
              precision: precision,
              currencyCode: currencyCode,
            ),
          );
          widget.onPaidEvent?.call(ad, valueMicros, precision, currencyCode);
        },
        onAdImpression: (ad) {
          developer.log(
            'SmartBannerAdView impression recorded',
            name: 'SmartBannerAdView',
          );
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.banner,
              type: AdEventType.impression,
              adUnitId: effectiveAdUnitId,
            ),
          );
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    AdsManager.adsEnabledNotifier.removeListener(_onAdsEnabledChanged);
    _teardownNetworkMonitoring();
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdsManager.isAdsEnabled) {
      return widget.placeholder ?? const SizedBox.shrink();
    }

    final mediaQuerySize = MediaQuery.maybeSizeOf(context);
    final double width = widget.adSize.width > 0
        ? widget.adSize.width.toDouble()
        : (mediaQuerySize?.width ?? 320.0);
    final double height =
        widget.adSize.height > 0 ? widget.adSize.height.toDouble() : 50.0;

    if (_isAdLoaded && _bannerAd != null && _isConnected) {
      return SizedBox(
        width: width,
        height: height,
        child: AdWidget(ad: _bannerAd!),
      );
    }

    if (!_isConnected || _hasError) {
      if (_hasCustomAdFallback) {
        return widget.customOfflineWidget ??
            CustomOfflineBannerAdWidget(
              adSize: widget.adSize,
              customAd: widget.customAd,
            );
      }
      return widget.placeholder ?? const SizedBox.shrink();
    }

    return widget.placeholder ??
        SizedBox(
          width: width,
          height: height,
        );
  }
}

/// Backward compatibility alias for [SmartBannerAdView].
typedef BannerAdWidget = SmartBannerAdView;
