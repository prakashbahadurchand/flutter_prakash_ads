---
name: flutter-ads
description: Expert guide and cheatsheet for integrating Google Mobile Ads (Banner, Native, Interstitial, Rewarded, App Open) and custom house ads in Flutter apps using the zero-DI flutter_ads package.
---

# Flutter Ads Implementation Skill (`flutter_ads`)

This skill provides step-by-step instructions, code recipes, and policy rules for implementing Google Mobile Ads into any Flutter application using the `flutter_ads` package.

---

## 📋 Integration Workflow

### Step 1: Add Dependency to `pubspec.yaml`

```yaml
dependencies:
  flutter_ads:
    path: ../flutter_ads # or git / pub version
```

### Step 2: Configure Native Platforms

#### Android (`android/app/src/main/AndroidManifest.xml`)
Inside the `<application>` tag, add the AdMob Application ID:

```xml
<manifest>
    <application>
        <!-- AdMob App ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>
    </application>
</manifest>
```

#### iOS (`ios/Runner/Info.plist`)
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

### Step 3: Initialize in `main.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ads/flutter_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Configure Ad Units & Test Mode
  AdManager.setRealAds(
    androidAppId: 'ca-app-pub-xxx~android-app-id',
    iosAppId: 'ca-app-pub-xxx~ios-app-id',
    androidBanner: 'ca-app-pub-xxx/android-banner-id',
    androidInterstitial: 'ca-app-pub-xxx/android-interstitial-id',
    androidRewarded: 'ca-app-pub-xxx/android-rewarded-id',
    androidRewardedInterstitial: 'ca-app-pub-xxx/android-rewarded-interstitial-id',
    androidNative: 'ca-app-pub-xxx/android-native-id',
    androidAppOpen: 'ca-app-pub-xxx/android-app-open-id',
    iosBanner: 'ca-app-pub-xxx/ios-banner-id',
    iosInterstitial: 'ca-app-pub-xxx/ios-interstitial-id',
    iosRewarded: 'ca-app-pub-xxx/ios-rewarded-id',
    iosRewardedInterstitial: 'ca-app-pub-xxx/ios-rewarded-interstitial-id',
    iosNative: 'ca-app-pub-xxx/ios-native-id',
    iosAppOpen: 'ca-app-pub-xxx/ios-app-open-id',
    useTestAds: kDebugMode, // Use Google test IDs in debug mode
  );

  // 2. Setup House / Custom Ads (for offline fallback & direct campaigns)
  AdManager.setupCustomAds([
    const CustomAdModel(
      id: 'promo_pro',
      title: 'Upgrade to Pro',
      description: 'Remove ads and unlock premium tools.',
      imageUrl: 'assets/images/pro_promo.png',
      link: 'https://myapp.com/pro',
      callToAction: 'Upgrade Now',
    ),
  ]);

  // Global click router for custom ads
  AdManager.onCustomAdClicked = (customAd) {
    debugPrint('Clicked custom ad: ${customAd.title} -> ${customAd.link}');
  };

  // 3. Setup Global Analytics Listener (Firebase Analytics, AppsFlyer, Adjust)
  AdManager.onAdEvent((event) {
    debugPrint('AdEvent: ${event.format.name} -> ${event.type.name}');
    if (event.type == AdEventType.paid) {
      // Log Impression-Level Ad Revenue (ILRD)
      // FirebaseAnalytics.instance.logAdImpression(
      //   adPlatform: 'AdMob',
      //   adFormat: event.format.name,
      //   adUnitName: event.adUnitId,
      //   value: event.revenueValue,
      //   currency: event.currencyCode,
      // );
    }
  });

  // 4. Request GDPR / UMP Consent (EEA / UK)
  final consentResult = await AdManager.requestConsent();

  // 5. Initialize SDK if consent permits
  if (consentResult.canRequestAds) {
    await AdManager.instance.initialize();
    await AdManager.instance.initializeAppOpenAd();
  }

  runApp(const MyApp());
}
```

---

## 🎯 Format Recipes

### 1. Smart Banner Ad (Adaptive with Fallback)

```dart
// Standard Banner with custom offline house ad fallback
const SmartBannerAdView(
  adSize: AdSize.banner,
  showOfflineFallback: true,
)

// Dynamic Anchored Adaptive Banner
FutureBuilder<AnchoredAdaptiveBannerAdSize?>(
  future: SmartBannerAdView.getAnchoredAdaptiveAdSize(context),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const SizedBox.shrink();
    return SmartBannerAdView(
      adSize: snapshot.data!,
      showOfflineFallback: true,
    );
  },
)
```

### 2. Smart Native Ad (Small / Medium Templates)

```dart
// Medium Native Ad (350px height)
const SmartNativeAdView(
  templateType: TemplateType.medium,
  cornerRadius: 12.0,
  showOfflineFallback: true,
)

// Small Native Ad (90px height)
const SmartNativeAdView(
  templateType: TemplateType.small,
  cornerRadius: 8.0,
)
```

### 3. Interstitial Ad (with 30s Throttling & Collision Guards)

```dart
final adsService = AdsServiceImpl.instance;

// Preload interstitial
adsService.loadInterstitialAd();

// Show at natural break points (level complete, task done)
adsService.showInterstitialAd(
  onAdDismissedFullScreenContent: () {
    // Continue user navigation
  },
);
```

### 4. Rewarded Video Ad (with Verification)

```dart
final adsService = AdsServiceImpl.instance;

// Preload rewarded ad
adsService.loadRewardedAd();

// Show on user opt-in button click
adsService.showRewardedAd(
  onUserEarnedReward: (ad, reward) {
    // Reward the user
    userCoins += reward.amount.toInt();
  },
);
```

### 5. App Open Ads (Cold-Start & Background Resumes)

```dart
// Automatically managed when `AdManager.instance.initializeAppOpenAd()` is called in `main()`.

// Temporarily suppress during checkout, login, or camera views:
AdManager.setAppOpenSuppressed(true);

// Re-enable when exiting sensitive flow:
AdManager.setAppOpenSuppressed(false);
```

---

## 💎 In-App Purchase "Remove Ads" (VIP / Premium)

When user purchases an ad-free tier or subscription:

```dart
// Disables ads across entire app instantly
// All mounted Banner and Native widgets collapse and dispose automatically
AdManager.setAdsEnabled(false);

// Re-enable if subscription expires
AdManager.setAdsEnabled(true);
```

---

## 👶 COPPA & Google Play Families Policy

```dart
await AdManager.updateRequestConfiguration(
  tagForChildDirectedTreatment: 1, // 1 = True
  tagForUnderAgeOfConsent: 1,      // 1 = True
  maxAdContentRating: 'G',         // Max rating (G, PG, T, MA)
  testDeviceIds: ['DEVICE_TEST_ID'],
);
```

---

## 🛡️ Critical Policy Rules

1. **No Accidental Clicks**: Never place banner ads adjacent to scrollable lists without fixed margins.
2. **Mandatory Attribution**: Native ads must always show the **"AD"** label with high contrast.
3. **No Disruptive Interstitials**: Never trigger interstitials on app launch (use App Open format instead) or in the middle of active gameplay.
4. **Explicit Rewarded Opt-In**: Never trigger rewarded video ads without explicit user interaction.
5. **No Full-Screen Collisions**: The package automatically blocks simultaneous full-screen ad presentations via `AdsManager.instance.isShowingFullScreenAd`.
