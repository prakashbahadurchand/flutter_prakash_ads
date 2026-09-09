# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.0.5

### Added
- **Multi Ad Unit IDs (Up to 3 Banner & 3 Native IDs)**:
  - Added support for configuring up to 3 distinct Banner ad unit IDs and up to 3 distinct Native ad unit IDs across Android and iOS.
  - Added cascading fallback: If Unit 3 is not configured, it cascades to Unit 2; if Unit 2 is not configured, it cascades to Unit 1 (or Google test ad in test mode).
  - Added `AdConstants.bannerAdUnitId2`, `AdConstants.bannerAdUnitId3`, `AdConstants.nativeAdUnitId2`, `AdConstants.nativeAdUnitId3`.
  - Added parameterized resolvers `AdConstants.getBannerAdUnitId(unitIndex: ...)` and `AdConstants.getNativeAdUnitId(unitIndex: ...)`.
- **Dedicated Widget Constructors**:
  - `SmartBannerAdView.withAdUnitId2(...)` & `SmartBannerAdView.withAdUnitId3(...)` (aliases: `SmartBannerAdView.unit2(...)`, `SmartBannerAdView.unit3(...)`).
  - `SmartNativeAdView.withAdUnitId2(...)` & `SmartNativeAdView.withAdUnitId3(...)` (aliases: `SmartNativeAdView.unit2(...)`, `SmartNativeAdView.unit3(...)`).
  - Added `adUnitIndex` constructor parameter to both `SmartBannerAdView` and `SmartNativeAdView`.
- **Clean Platform Separation & Parameter Ordering**:
  - `AdManager.setRealAndroidAdUnitIds(...)` and `AdManager.setRealIosAdUnitIds(...)` to configure platform ad units independently without cross-platform contamination.
  - `AdManager.setRealAndroidAds(...)` and `AdManager.setRealIosAds(...)` all-in-one platform initializers.
  - Consistent sequential parameter ordering: Banner -> Native -> Interstitial -> RewardedInterstitial -> Rewarded -> AppOpen.
  - Full backward compatibility preserved for existing `AdManager.setRealAdUnitIds(...)` and `AdManager.setRealAds(...)`.

## 0.0.4

### Added
- Canonical import guide and documentation explicitly showcasing `import 'package:flutter_prakash_ads/fp_ads.dart';`.
- Comprehensive AdMob Policy, Better Ads Standards, and Invalid Traffic (IVT) compliance guidelines across README and skills.
- Explicit Rewarded Interstitial opt-out and countdown dialog flow recommendations.
- Refined typography, emoji styling, and detailed ILRD telemetry examples.

## 0.0.3

### Added
- **Zero-Latency Conditional Network Architecture**:
  - `SmartBannerAdView` and `SmartNativeAdView` completely bypass network checks when custom house ads are not configured via `AdsManager.setupCustomAds(...)`, eliminating DNS lookups, latency, and socket pings.
  - Live AdMob ads are dispatched immediately with zero startup delay.
  - Added `AdsManager.hasCustomAds` getter and `AdsManager.enableNetworkCheck` global toggle.
  - Added `AdsManager.hasCustomAdForFallback` helper method.
- **Enhanced AdMob Policy Compliance & CLS Guards**:
  - Clean collapse to placeholder / `SizedBox.shrink()` on load failure when custom ads are not configured, preventing display of unwanted placeholder ads.
  - Eliminated distracting spinning loading indicators in ad slots, using reserved bounding containers to strictly prevent Cumulative Layout Shift (CLS).
  - Multiplatform & Flutter Web safety with `!kIsWeb` guards on `Platform.isAndroid` and `Platform.isIOS`.
  - Offline-resilient consent handling in `ConsentManager` checking cached consent if network is unavailable.
  - Rewarded Interstitial AdMob policy compliance with recommended intro/opt-out countdown flows.
- **Lifecycle, Platform Safety & Memory Optimization**:
  - Added `AdConstants.isPlatformSupported` and safe early-return guards across `ConsentManager`, `AdsManager`, `AppOpenAdManager`, `AdsServiceImpl`, and individual ad services to eliminate native plugin exceptions on unsupported platforms (Web, Desktop, CI test environments).
  - Replaced un-cancellable `Future.delayed` retries with dedicated, cancellable `Timer` instances in `AdsServiceImpl`, `InterstitialAdService`, `RewardedAdService`, and `RewardedInterstitialAdService` that cancel immediately upon `dispose()`.
  - Guaranteed non-blocking fallback to `onAdDismissedFullScreenContent` across all full-screen formats (App Open, Interstitial, Rewarded, Rewarded Interstitial) whenever an ad fails to show, is suppressed, or disabled, ensuring screen navigation routes never freeze.
- **Root Library Export**: Added `lib/fp_ads.dart` as the primary import (`import 'package:flutter_prakash_ads/fp_ads.dart';`).

## 0.0.2

### Added
- Visual showcase previews with high-resolution screenshot cards and video walk-through in README.
- Enhanced package discovery metadata and pub.dev topics configuration.
- Verified relative asset rendering for GitHub and Pub.dev package galleries.

## 0.0.1

### Added
- **Zero DI Architecture**: Standalone ad management working out of the box with Riverpod, BLoC/Cubit, Provider, GetX, or vanilla Flutter.
- **AdMob Formats**:
  - `SmartBannerAdView`: Anchored adaptive & fixed banners with Cumulative Layout Shift (CLS) protection.
  - `SmartNativeAdView`: Small (90px) and Medium (350px) native ad templates.
  - `AdsService.showInterstitialAd`: 30-second throttled full-screen interstitial ads with anti-fatigue controls.
  - `AdsService.showRewardedAd`: Rewarded video ads with server/client verification callbacks.
  - `AdsService.showRewardedInterstitialAd`: Rewarded interstitial format support.
  - `AppOpenAdManager`: App open ads with cold-start timeout deadline (4s) and background resume threshold (15s).
- **Custom / House Ads**: `CustomAdModel` support for rendering promotional or offline fallback ads with custom badges and centralized click routing (`AdManager.onCustomAdClicked`).
- **Reactive Premium Mode**: `AdManager.setAdsEnabled(false)` toggles global ad visibility across all mounted widgets.
- **Unified Telemetry**: `AdManager.onAdEvent` and `AdManager.adEventStream` for logging lifecycle & Impression-Level Ad Revenue (ILRD) events to Firebase Analytics, Adjust, AppsFlyer, etc.
- **Compliance & Privacy**:
  - Google User Messaging Platform (UMP) GDPR/CPRA consent integration with built-in revocation forms.
  - COPPA and Google Play Families Policy configuration (`AdManager.updateRequestConfiguration`).
  - 4-hour max-age cache invalidation and anti-stacking collision guards.
- **Agent Skill**: Official AI integration skill instructions (`SKILL.md`) for autonomous coding assistants.
- **Example App**: Comprehensive 5-tab production showcase app with Clean Architecture, BLoC/Cubit, and Injectable DI.
