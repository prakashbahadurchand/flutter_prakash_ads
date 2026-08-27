# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
