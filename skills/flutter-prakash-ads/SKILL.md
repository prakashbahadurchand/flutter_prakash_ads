---
name: flutter-prakash-ads
description: Expert guide and cheatsheet for integrating Google Mobile Ads (Banner, Native, Interstitial, Rewarded, App Open) and custom house ads in Flutter apps using the zero-DI flutter_prakash_ads package.
---

# Flutter Prakash Ads Implementation Skill (`flutter_prakash_ads`)

This skill provides step-by-step instructions, code recipes, and policy rules for implementing Google Mobile Ads into any Flutter application using the `flutter_prakash_ads` package.

---

## 📋 Integration Workflow

### Step 1: Add Dependency to `pubspec.yaml`

```yaml
dependencies:
  flutter_prakash_ads: ^0.0.1
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
import 'package:flutter_prakash_ads/flutter_prakash_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // (Optional) Configure Real Ad Unit IDs for Production:
  // AdManager.setRealAds(
  //   androidAppId: 'ca-app-pub-xxx~android-app-id',
  //   iosAppId: 'ca-app-pub-xxx~ios-app-id',
  //   androidBanner: 'ca-app-pub-xxx/android-banner-id',
  //   androidInterstitial: 'ca-app-pub-xxx/android-interstitial-id',
  //   androidRewarded: 'ca-app-pub-xxx/android-rewarded-id',
  //   androidRewardedInterstitial: 'ca-app-pub-xxx/android-rewarded-interstitial-id',
  //   androidNative: 'ca-app-pub-xxx/android-native-id',
  //   androidAppOpen: 'ca-app-pub-xxx/android-app-open-id',
  //   iosBanner: 'ca-app-pub-xxx/ios-banner-id',
  //   iosInterstitial: 'ca-app-pub-xxx/ios-interstitial-id',
  //   iosRewarded: 'ca-app-pub-xxx/ios-rewarded-id',
  //   iosRewardedInterstitial: 'ca-app-pub-xxx/ios-rewarded-interstitial-id',
  //   iosNative: 'ca-app-pub-xxx/ios-native-id',
  //   iosAppOpen: 'ca-app-pub-xxx/ios-app-open-id',
  // );

  // 1. Gather GDPR / UMP Consent (EEA & UK compliance)
  final consent = await AdManager.requestConsent();

  // 2. Initialize AdMob & App Open lifecycle if allowed
  if (consent.canRequestAds) {
    await AdManager.instance.initialize();
    await AdManager.instance.initializeAppOpenAd();
  }

  runApp(const MyApp());
}
```

---

## 📱 Ad Formats & Recipes

### 1. Adaptive & Fixed Banner Ads (`SmartBannerAdView`)

```dart
// Auto-adaptive banner with CLS and offline fallback protection:
const SmartBannerAdView()

// Fixed size standard banner:
const SmartBannerAdView(
  adSize: AdSize.banner,
  showOfflineFallback: true,
)
```

### 2. Native Ads (`SmartNativeAdView`)

```dart
// Medium template (350px height)
const SmartNativeAdView(
  templateType: TemplateType.medium,
  cornerRadius: 16.0,
)

// Small template (90px height)
const SmartNativeAdView(
  templateType: TemplateType.small,
  cornerRadius: 12.0,
)
```

### 3. Interstitial Ads (`AdsService`)

```dart
final adsService = AdsServiceImpl();

// Preload interstitial
adsService.loadInterstitialAd();

// Show with 30s throttling & collision prevention:
adsService.showInterstitialAd(
  onAdDismissedFullScreenContent: () {
    // Navigate to next screen
  },
);
```

### 4. Rewarded Video Ads (`AdsService`)

```dart
adsService.showRewardedAd(
  onUserEarnedReward: (ad, reward) {
    final coins = reward.amount.toInt();
    // Credit reward to user
  },
);
```

### 5. Impression-Level Ad Revenue (ILRD) Telemetry

```dart
AdManager.onAdEvent((event) {
  if (event.isPaid) {
    // Log to Firebase Analytics / Adjust / AppsFlyer
  }
});
```

### 6. Reactive Ad-Free Mode ("Remove Ads")

```dart
// Globally hide and dispose all mounted ads
AdManager.setAdsEnabled(false);
```

---

## 🛡️ Policy & Quality Guardrails

1. **No Cold-Start Interstitial**: Never trigger an Interstitial or Rewarded ad during app launch, splash, or onboarding.
2. **App Open Suppression**: Call `AdsManager.setAppOpenSuppressed(true)` during onboarding, checkout, or camera capture.
3. **CLS Prevention**: Always enclose banner/native widgets in fixed bounding heights or use built-in `SmartBannerAdView` and `SmartNativeAdView`.
4. **Offline Attribution**: Custom fallback ads must always render a visible `"AD"` badge.
