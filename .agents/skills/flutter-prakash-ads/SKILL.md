---
name: flutter-prakash-ads
description: Expert guide and cheatsheet for integrating Google Mobile Ads (Banner, Native, Interstitial, Rewarded, App Open) and custom house ads in Flutter apps using the zero-DI flutter_prakash_ads package.
---

# 🚀 Flutter Prakash Ads Implementation Skill (`flutter_prakash_ads`)

This skill provides step-by-step instructions, code recipes, and policy rules for integrating Google Mobile Ads into any Flutter application using the `flutter_prakash_ads` package.

---

## 📋 Integration Workflow

### 📦 Step 1: Add Dependency to `pubspec.yaml`

```yaml
dependencies:
  flutter_prakash_ads: ^0.0.5
```

### ⚙️ Step 2: Configure Native Platforms

#### 🤖 Android (`android/app/src/main/AndroidManifest.xml`)
Inside the `<application>` tag, add the AdMob Application ID:

```xml
<manifest>
    <!-- Recommended Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="com.google.android.gms.permission.AD_ID"/>

    <application>
        <!-- AdMob App ID (Google Test ID shown; replace with production ID before publishing) -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>
    </application>
</manifest>
```

#### 🍏 iOS (`ios/Runner/Info.plist`)
Inside `<dict>`, add `GADApplicationIdentifier` and `SKAdNetworkItems`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
</array>
```

---

### 🏁 Step 3: Initialize in `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_prakash_ads/flutter_prakash_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // (Optional) Configure Real Ad Unit IDs for Production:
  // Option A: Platform Separation (Recommended)
  // Parameter order: banner -> native -> interstitial -> rewardedInterstitial -> rewarded -> appOpen
  // AdManager.setRealAndroidAds(
  //   appId: 'ca-app-pub-xxx~android-app-id',
  //   banner: 'ca-app-pub-xxx/android-banner-id',
  //   banner2: 'ca-app-pub-xxx/android-banner-2',
  //   banner3: 'ca-app-pub-xxx/android-banner-3',
  //   native: 'ca-app-pub-xxx/android-native-id',
  //   native2: 'ca-app-pub-xxx/android-native-2',
  //   native3: 'ca-app-pub-xxx/android-native-3',
  //   interstitial: 'ca-app-pub-xxx/android-interstitial-id',
  //   rewardedInterstitial: 'ca-app-pub-xxx/android-rewarded-interstitial-id',
  //   rewarded: 'ca-app-pub-xxx/android-rewarded-id',
  //   appOpen: 'ca-app-pub-xxx/android-app-open-id',
  //   useTestAds: false,
  // );
  // AdManager.setRealIosAds(
  //   appId: 'ca-app-pub-xxx~ios-app-id',
  //   banner: 'ca-app-pub-xxx/ios-banner-id',
  //   banner2: 'ca-app-pub-xxx/ios-banner-2',
  //   banner3: 'ca-app-pub-xxx/ios-banner-3',
  //   native: 'ca-app-pub-xxx/ios-native-id',
  //   native2: 'ca-app-pub-xxx/ios-native-2',
  //   native3: 'ca-app-pub-xxx/ios-native-3',
  //   interstitial: 'ca-app-pub-xxx/ios-interstitial-id',
  //   rewardedInterstitial: 'ca-app-pub-xxx/ios-rewarded-interstitial-id',
  //   rewarded: 'ca-app-pub-xxx/ios-rewarded-id',
  //   appOpen: 'ca-app-pub-xxx/ios-app-open-id',
  // );

  // 1. 🛡️ Gather GDPR / UMP Consent (EEA & UK compliance)
  final consent = await AdManager.requestConsent();

  // 2. ⚡ Initialize AdMob & App Open lifecycle if allowed
  if (consent.canRequestAds) {
    await AdManager.instance.initialize();
    await AdManager.instance.initializeAppOpenAd();
  }

  runApp(const MyApp());
}
```

---

## 📱 Ad Formats & Recipes

### 1. 🖼️ Adaptive & Fixed Banner Ads (`SmartBannerAdView`)

Supports up to 3 banner ad unit IDs with automated cascade fallback (Unit 3 ➔ Unit 2 ➔ Unit 1):

```dart
// Auto-adaptive banner (Unit 1):
const SmartBannerAdView()

// Secondary banner unit ID (Unit 2 with fallback to Unit 1):
SmartBannerAdView.withAdUnitId2()

// Tertiary banner unit ID (Unit 3 with fallback to Unit 2, then Unit 1):
SmartBannerAdView.withAdUnitId3()

// Fixed size standard banner (outside of scroll views):
const SmartBannerAdView(
  adSize: AdSize.banner,
  showOfflineFallback: true,
)
```

### 2. 🎨 Native Ads (`SmartNativeAdView`)

Supports up to 3 native ad unit IDs with automated cascade fallback (Unit 3 ➔ Unit 2 ➔ Unit 1):

```dart
// Medium template (350px height) - Unit 1:
const SmartNativeAdView(
  templateType: TemplateType.medium,
  cornerRadius: 16.0,
)

// Secondary native unit (Unit 2 with automatic fallback):
SmartNativeAdView.withAdUnitId2(
  templateType: TemplateType.medium,
  cornerRadius: 16.0,
)

// Tertiary native unit (Unit 3 with automatic fallback):
SmartNativeAdView.withAdUnitId3(
  templateType: TemplateType.medium,
  cornerRadius: 16.0,
)

// Small template (90px height) - Ideal for list items
const SmartNativeAdView(
  templateType: TemplateType.small,
  cornerRadius: 12.0,
)
```

### 3. 🎬 Interstitial Ads (`AdsService`)

```dart
final adsService = AdsServiceImpl();

// Preload interstitial
adsService.loadInterstitialAd();

// Show with 30s throttling & collision prevention:
adsService.showInterstitialAd(
  onAdDismissedFullScreenContent: () {
    // Navigate to next screen without blocking
  },
  onAdFailedToShowFullScreenContent: (error) {
    // Graceful navigation fallback
  },
);
```

### 4. 🎁 Rewarded Video Ads (`AdsService`)

```dart
adsService.showRewardedAd(
  onUserEarnedReward: (ad, reward) {
    final coins = reward.amount.toInt() == 0 ? 50 : reward.amount.toInt();
    // Credit reward to user
  },
  onAdDismissedFullScreenContent: () {
    // Resume gameplay / flow
  },
);
```

### 5. 💎 Rewarded Interstitial Ads (`AdsService`)

> ⚠️ **AdMob Policy Guard**: Google AdMob strictly requires an introductory screen or countdown with an explicit option for the user to skip before presenting a Rewarded Interstitial ad.

```dart
// Present an intro dialog giving the user a chance to skip:
showIntroDialog(
  onProceed: () {
    adsService.showRewardedInterstitialAd(
      onUserEarnedReward: (ad, reward) {
        // Credit bonus reward (+100 Coins)
      },
      onAdDismissedFullScreenContent: () {
        // Resume gameplay / flow
      },
    );
  },
);
```

### 6. 📈 Impression-Level Ad Revenue (ILRD) Telemetry

```dart
AdManager.onAdEvent((event) {
  if (event.isPaid) {
    // Log to Firebase Analytics / Adjust / AppsFlyer
    // event.revenueValue, event.currencyCode, event.precision
  }
});
```

### 7. 🚫 Reactive Ad-Free Mode ("Remove Ads")

```dart
// Globally hide and dispose all mounted ads
AdManager.setAdsEnabled(false);
```

### 8. 🎨 Custom House Ads Setup

```dart
AdsManager.setupCustomAds(const [
  CustomAdModel(
    id: 'pro_promo',
    title: 'Upgrade to Pro',
    description: 'Unlock 100+ premium features offline.',
    callToAction: 'Upgrade Now',
  ),
]);
```

---

## 🛡️ AdMob Policy & Quality Guardrails

1. ⚡ **Zero-Latency Architecture**: If `AdsManager.setupCustomAds(...)` is not configured, network queries are completely bypassed (zero DNS/socket ping overhead). AdMob ads request immediately.
2. 🚫 **No Cold-Start Interstitial**: Never trigger an Interstitial or Rewarded ad during app launch, splash, or onboarding.
3. 🚪 **App Open Ad Rules**:
   - ⏩ Skips cold-start ad on the user's very first launch session.
   - ⏱️ Enforces a 4-second cold-start timeout deadline to avoid interrupting the user after UI interaction starts.
   - ⏸️ Enforces a 15-second minimum background threshold on resume to avoid rapid switching fatigue.
   - 🛑 Call `AdsManager.setAppOpenSuppressed(true)` during onboarding, login, checkout, or camera capture.
4. 🛑 **Anti-Collision Presentation Lock**: `AdsManager.instance.isShowingFullScreenAd` prevents simultaneous presentation of full-screen ads.
5. ⏱️ **30-Second Interstitial Throttling**: Automatically prevents user fatigue between interstitial displays.
6. ⚠️ **Rewarded Interstitial Opt-Out**: Per AdMob policy, provide an intro screen with an explicit skip/opt-out option before triggering a Rewarded Interstitial ad.
7. 🔄 **Non-Blocking Fallback**: All full-screen ad show/fail callbacks fall back to `onAdDismissedFullScreenContent` so navigation routes never freeze.
8. ⏳ **4-Hour Max-Age Expiration**: Cached full-screen ads older than 4 hours are evicted automatically.
9. 📐 **CLS Prevention**: Reserve fixed bounding heights for banner/native widgets. Smart widgets collapse cleanly without showing misleading loading spinners.
10. 🏷️ **Prominent "AD" Attribution**: All house fallback ads include prominent, high-contrast "AD" badges.
11. 🧹 **Disposal Lifecycle**: Background retry timers are automatically cancelled upon service disposal, preventing memory leaks and background network queries.
