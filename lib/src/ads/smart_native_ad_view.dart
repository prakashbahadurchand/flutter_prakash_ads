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
import 'custom_offline_native_ad_widget.dart';

/// A smart, policy-compliant reusable widget for displaying Native Ads.
///
/// Features:
/// - Real-time network detection via [NetworkInfo].
/// - Seamless fallback to [CustomOfflineNativeAdWidget] with [CustomAdModel] support when disconnected.
/// - Automatic event tracking via [AdsManager.onAdEvent].
/// - Fixed bounding template heights (Small: 90px, Medium: 350px).
/// - Optional [onPaidEvent] for Impression-Level Ad Revenue (ILRD) and LTV tracking.
/// - Reactive global ad suppression support when [AdsManager.isAdsEnabled] is `false`.
/// - Automatic disposal and memory cleanup.
class SmartNativeAdView extends StatefulWidget {
  const SmartNativeAdView({
    super.key,
    this.adUnitId,
    this.templateType = TemplateType.medium,
    this.nativeTemplateStyle,
    this.adRequest,
    this.customAd,
    this.factoryId,
    this.cornerRadius = 12.0,
    this.showOfflineFallback = true,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
    this.onPaidEvent,
    this.placeholder,
    this.customOfflineWidget,
    this.networkInfo,
  });

  /// Custom Ad Unit ID. If null, default configured or test ID from [AdConstants] is used.
  final String? adUnitId;

  /// Native ad template size (TemplateType.small or TemplateType.medium).
  final TemplateType templateType;

  /// Optional custom native template style to customize colors, fonts, and background.
  final NativeTemplateStyle? nativeTemplateStyle;

  /// Optional custom [AdRequest] parameters (keywords, targeting, etc.).
  final AdRequest? adRequest;

  /// Custom ad model to use for offline fallback or direct campaigns.
  final CustomAdModel? customAd;

  /// Custom native ad factory ID (for custom platform view layouts).
  final String? factoryId;

  /// Border corner radius for the native template container.
  final double cornerRadius;

  /// Whether to render a custom offline native ad fallback when disconnected.
  final bool showOfflineFallback;

  /// Callback when ad loads successfully.
  final VoidCallback? onAdLoaded;

  /// Callback when ad fails to load.
  final Function(LoadAdError error)? onAdFailedToLoad;

  /// Callback when ad is clicked.
  final VoidCallback? onAdClicked;

  /// Impression-level ad revenue callback for analytics (e.g. Firebase, Adjust, AppsFlyer).
  final OnPaidEventCallback? onPaidEvent;

  /// Custom widget to display during loading.
  final Widget? placeholder;

  /// Custom offline fallback widget to override default fallback.
  final Widget? customOfflineWidget;

  /// Optional network info checker for connectivity updates. Defaults to [NetworkInfoImpl].
  final NetworkInfo? networkInfo;

  @override
  State<SmartNativeAdView> createState() => _SmartNativeAdViewState();
}

class _SmartNativeAdViewState extends State<SmartNativeAdView> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _hasError = false;
  bool _isConnected = true;
  StreamSubscription<InternetStatus>? _networkSubscription;
  late final NetworkInfo _networkInfo;

  @override
  void initState() {
    super.initState();
    _networkInfo = widget.networkInfo ?? NetworkInfoImpl();
    AdsManager.adsEnabledNotifier.addListener(_onAdsEnabledChanged);
    if (AdsManager.isAdsEnabled) {
      _checkInitialConnectionAndLoad();
    }
  }

  void _onAdsEnabledChanged() {
    if (!AdsManager.isAdsEnabled) {
      _nativeAd?.dispose();
      _nativeAd = null;
      _isAdLoaded = false;
      if (mounted) setState(() {});
    } else if (!_isAdLoaded && _isConnected) {
      _loadNativeAd();
    }
  }

  @override
  void didUpdateWidget(covariant SmartNativeAdView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!AdsManager.isAdsEnabled) {
      _nativeAd?.dispose();
      _nativeAd = null;
      _isAdLoaded = false;
      return;
    }
    if (widget.adUnitId != oldWidget.adUnitId ||
        widget.templateType != oldWidget.templateType ||
        widget.factoryId != oldWidget.factoryId ||
        widget.nativeTemplateStyle != oldWidget.nativeTemplateStyle ||
        widget.adRequest != oldWidget.adRequest) {
      _nativeAd?.dispose();
      _nativeAd = null;
      _isAdLoaded = false;
      _hasError = false;
      if (_isConnected) {
        _loadNativeAd();
      }
    }
  }

  void _checkInitialConnectionAndLoad() async {
    _isConnected = await _networkInfo.isConnected;

    _networkSubscription = _networkInfo.onStatusChange.listen((status) {
      final connected = status == InternetStatus.connected;
      if (connected != _isConnected) {
        if (mounted) {
          setState(() {
            _isConnected = connected;
          });
          if (connected && !_isAdLoaded && AdsManager.isAdsEnabled) {
            _loadNativeAd();
          }
        }
      }
    });

    if (_isConnected && AdsManager.isAdsEnabled) {
      _loadNativeAd();
    } else if (mounted) {
      setState(() {
        _hasError = true;
      });
    }
  }

  Brightness? _lastBrightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentBrightness = Theme.of(context).brightness;
    if (_lastBrightness != null && _lastBrightness != currentBrightness) {
      _lastBrightness = currentBrightness;
      if (widget.nativeTemplateStyle == null &&
          AdsManager.isAdsEnabled &&
          _isConnected) {
        _loadNativeAd();
      }
    } else {
      _lastBrightness = currentBrightness;
    }
  }

  void _loadNativeAd() {
    if (!AdsManager.isAdsEnabled) return;

    final effectiveAdUnitId = widget.adUnitId ?? AdConstants.nativeAdUnitId;
    _nativeAd?.dispose();

    final isDark =
        mounted ? Theme.of(context).brightness == Brightness.dark : false;

    final defaultStyle = isDark
        ? NativeTemplateStyle(
            templateType: widget.templateType,
            mainBackgroundColor: const Color(0xFF1E1E1E),
            cornerRadius: widget.cornerRadius,
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: Colors.white,
              backgroundColor: const Color(0xFF6750A4),
              style: NativeTemplateFontStyle.bold,
              size: 16.0,
            ),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.white,
              style: NativeTemplateFontStyle.bold,
              size: 16.0,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: const Color(0xFFB0B0B0),
              style: NativeTemplateFontStyle.normal,
              size: 14.0,
            ),
            tertiaryTextStyle: NativeTemplateTextStyle(
              textColor: const Color(0xFF888888),
              style: NativeTemplateFontStyle.normal,
              size: 12.0,
            ),
          )
        : NativeTemplateStyle(
            templateType: widget.templateType,
            mainBackgroundColor: Colors.white,
            cornerRadius: widget.cornerRadius,
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: Colors.white,
              backgroundColor: const Color(0xFF6750A4),
              style: NativeTemplateFontStyle.bold,
              size: 16.0,
            ),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black87,
              style: NativeTemplateFontStyle.bold,
              size: 16.0,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black54,
              style: NativeTemplateFontStyle.normal,
              size: 14.0,
            ),
            tertiaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
              size: 12.0,
            ),
          );

    _nativeAd = NativeAd(
      adUnitId: effectiveAdUnitId,
      request: widget.adRequest ?? const AdRequest(),
      factoryId: widget.factoryId,
      nativeTemplateStyle: widget.factoryId == null
          ? (widget.nativeTemplateStyle ?? defaultStyle)
          : null,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          developer.log('SmartNativeAdView loaded.', name: 'SmartNativeAdView');
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.native,
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
            'SmartNativeAdView failed to load: ${error.message}',
            name: 'SmartNativeAdView',
          );
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.native,
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
              format: AdFormat.native,
              type: AdEventType.clicked,
              adUnitId: effectiveAdUnitId,
            ),
          );
          widget.onAdClicked?.call();
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          developer.log(
            'Native Paid Event: $valueMicros micros ($currencyCode)',
            name: 'SmartNativeAdView',
          );
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.native,
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
            'SmartNativeAdView impression recorded',
            name: 'SmartNativeAdView',
          );
          AdsManager.emitAdEvent(
            AdEvent(
              format: AdFormat.native,
              type: AdEventType.impression,
              adUnitId: effectiveAdUnitId,
            ),
          );
        },
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    AdsManager.adsEnabledNotifier.removeListener(_onAdsEnabledChanged);
    _networkSubscription?.cancel();
    _nativeAd?.dispose();
    _nativeAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdsManager.isAdsEnabled) {
      return widget.placeholder ?? const SizedBox.shrink();
    }

    final height = widget.templateType == TemplateType.small ? 90.0 : 350.0;

    if (_isAdLoaded && _nativeAd != null && _isConnected) {
      return Container(
        height: height,
        alignment: Alignment.center,
        child: AdWidget(ad: _nativeAd!),
      );
    }

    if (!_isConnected || _hasError) {
      if (widget.showOfflineFallback) {
        return widget.customOfflineWidget ??
            CustomOfflineNativeAdWidget(
              templateType: widget.templateType,
              cornerRadius: widget.cornerRadius,
              customAd: widget.customAd,
            );
      }
      return widget.placeholder ?? const SizedBox.shrink();
    }

    return widget.placeholder ??
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(widget.cornerRadius),
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
  }
}

/// Backward compatibility alias for [SmartNativeAdView].
typedef NativeAdWidget = SmartNativeAdView;
