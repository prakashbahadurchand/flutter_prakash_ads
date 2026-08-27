# Changelog

All notable changes to this project will be documented in this file.

## 0.0.1 - Initial Release

- **Zero Dependency Injection Lock-in**: Fully standalone package without `injectable`, `get_it`, or `dio`.
- **AdMob Formats Supported**:
  - `SmartBannerAdView`: Anchored adaptive & fixed banners with CLS layout-shift protection.
  - `SmartNativeAdView`: Small (90px) and Medium (350px) native ad templates.
  - `AdsService.showInterstitialAd`: 30-second throttled interstitial ads with anti-fatigue controls.
  - `AdsService.showRewardedAd`: Rewarded video ads with verified reward callbacks.
  - `AdsService.showRewardedInterstitialAd`: Rewarded interstitial format support.
  - `AppOpenAdManager`: App open ads with cold-start timeout deadline (4s) and background resume threshold (15s).
- **Custom / House Ads**: `CustomAdModel` support for rendering promotional or offline ads with asset/network images, "AD" badges, and centralized click routing (`AdManager.onCustomAdClicked`).
- **Reactive Premium / Ad-Free Mode**: `AdManager.setAdsEnabled(false)` toggles global ad visibility across all mounted widgets.
- **Unified Telemetry**: `AdManager.onAdEvent` and `AdManager.adEventStream` for logging to Firebase Analytics, Adjust, AppsFlyer, etc.
- **Compliance & Privacy**:
  - Google User Messaging Platform (UMP) GDPR/CPRA consent integration.
  - COPPA and Google Play Families Policy configuration (`AdManager.updateRequestConfiguration`).
  - 4-hour max-age cache invalidation and anti-stacking collision guards.
