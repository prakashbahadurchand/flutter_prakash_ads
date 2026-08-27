# Flutter Ads (`flutter_ads`)

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Google Mobile Ads](https://img.shields.io/badge/AdMob-Google%20Mobile%20Ads-FBBC05?logo=google)](https://admob.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Zero DI](https://img.shields.io/badge/Dependency%20Injection-Zero%20Lock--in-blueviolet)](https://pub.dev)
[![Policy Compliant](https://img.shields.io/badge/Google%20Play-100%25%20Policy%20Compliant-success)](https://support.google.com/admob)
[![Agent Skill](https://img.shields.io/badge/Agent%20Skill-Ready-blue)](.agents/skills/flutter-ads/SKILL.md)

An enterprise-grade, policy-compliant, standalone Google Mobile Ads package for Flutter applications. Built with zero dependency-injection lock-in, reactive "Remove Ads" toggles, offline fallback house ads, unified analytics telemetry, and ready-to-use Agent Skills for autonomous AI integration.

---

## ✨ Features

- 🛡️ **Zero DI Lock-in**: Fully standalone. Works out of the box with Riverpod, Bloc, Provider, GetX, or vanilla Flutter without requiring `injectable` or `get_it`.
- ⚙️ **One-Line Production/Test Switching**: Switch seamlessly between official Google test ads and production AdMob units using `AdManager.setRealAds(...)`.
- 💎 **Reactive "Remove Ads" (IAP)**: Instantly hide and dispose all mounted banner and native ads across the widget tree with `AdManager.setAdsEnabled(false)`.
- 🎨 **Custom / House Ads & Offline Fallbacks**: Render promotional or offline ads (`CustomAdModel`) with asset/network images, custom badges, and centralized click routing (`AdManager.onCustomAdClicked`).
- 📊 **Unified Analytics Telemetry**: Capture all lifecycle events (Loaded, Failed, Showed, Dismissed, Clicked, Impression, Paid / ILRD, Reward Earned) via `AdManager.onAdEvent` or `AdManager.adEventStream` for logging to Firebase Analytics, Adjust, AppsFlyer, etc.
- 🤖 **Agentic Coding Ready (`SKILL.md`)**: Includes official agent skill instructions in `.agents/skills/flutter-ads/SKILL.md` for AI pair programmers and autonomous coding assistants.
- 📐 **Anchored Adaptive Banners**: Built-in `SmartBannerAdView.getAnchoredAdaptiveAdSize(context)` to maximize fill rates and eCPMs.
- 🌐 **Smart Network Awareness**: Real-time network detection with seamless fallback widgets when offline or when AdMob fails to fill.
- 👶 **COPPA & Google Play Families Policy Ready**: Configure child-directed treatment, age of consent, and content rating tags with `AdManager.updateRequestConfiguration(...)`.
- 🔒 **GDPR / UMP Consent Ready**: Built-in `ConsentManager` for EEA/UK GDPR compliance and privacy options revocation forms.
- ⏱️ **AdMob & Play Policy Guardrails**:
  - **Anti-Stacking Collision**: Prevents App Open, Interstitial, and Rewarded ads from ever presenting simultaneously.
  - **4-Hour Max-Age Expiration**: Automatically evicts stale cached impressions.
  - **30s Interstitial Throttling**: Prevents rapid ad spam and user fatigue.
  - **App Open Cold-Start & Background Guards**: 4-second timeout deadline and 15-second background threshold.
  - **CLS Prevention**: Fixed dimensional bounding prevents Cumulative Layout Shifts and accidental clicks.

---

## 📱 Supported Ad Formats

| Format | Widget / Service | Description |
|---|---|---|
| **Banner** | `SmartBannerAdView` | Adaptive / fixed banners with offline fallback and CLS protection |
| **Native** | `SmartNativeAdView` | Small (90px) & Medium (350px) native templates with fallback |
| **Interstitial** | `AdsService.showInterstitialAd` | Full-screen interstitial with 30s throttling & collision prevention |
| **Rewarded Video** | `AdsService.showRewardedAd` | Rewarded ad with verified server/client reward callbacks |
| **Rewarded Interstitial** | `AdsService.showRewardedInterstitialAd` | Rewarded interstitial format with reward completion callbacks |
| **App Open** | `AppOpenAdManager` | Policy-compliant cold-start & resume app open ads |

---

## 🤖 Agentic Coding with AI Skills

This package includes a specialized **Agent Skill** (`SKILL.md`) designed to instruct AI coding assistants (e.g. Antigravity, Claude, Copilot) on how to integrate `flutter_ads` into any target application cleanly and without policy violations.

The skill is located at:
- [`.agents/skills/flutter-ads/SKILL.md`](.agents/skills/flutter-ads/SKILL.md) (Workspace root)
- [`skills/flutter-ads/SKILL.md`](skills/flutter-ads/SKILL.md) (Repository root)

---

## 🚀 Getting Started

### 1. Add Dependency

Add `flutter_ads` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_ads:
    path: ../flutter_ads # or git / pub
```

### 2. Platform Setup

#### Android (`android/app/src/main/AndroidManifest.xml`)

Add your Google AdMob App ID inside the `<application>` tag:

```xml
<manifest>
    <application>
        <!-- AdMob App ID (Replace with your real Android App ID in release) -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>
    </application>
</manifest>
```

#### iOS (`ios/Runner/Info.plist`)

Add `GADApplicationIdentifier` and recommended `SKAdNetworkItems`:

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

## 📖 Complete Usage Guide

### 1. Initialization & Configuration

In your `main()` or application entrypoint:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ads/flutter_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Configure Production Ad Unit IDs (defaults to Google official test IDs if omitted or if useTestAds is true)
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
    useTestAds: kDebugMode, // Automatically uses Google test ads in debug mode
  );

  // 2. Setup Custom/House Ads (used for offline fallbacks or promotional campaigns)
  AdManager.setupCustomAds([
    const CustomAdModel(
      id: 'promo_pro_upgrade',
      title: 'Upgrade to Pro Edition',
      description: 'Remove ads, unlock cloud sync, and access premium tools.',
      imageUrl: 'assets/images/pro_promo.png', // Supports asset image or network URL
      link: 'https://myapp.com/upgrade',
      callToAction: 'Upgrade Now',
      advertiser: 'My App Pro',
    ),
  ]);

  // Handle global custom ad click routing
  AdManager.onCustomAdClicked = (customAd) {
    debugPrint('User clicked custom ad: ${customAd.title} -> ${customAd.link}');
    // Navigate to in-app upgrade screen or launch URL
  };

  // 3. Setup Global Analytics Listener (Firebase, Adjust, AppsFlyer, etc.)
  AdManager.onAdEvent((event) {
    debugPrint('AdEvent: ${event.format.name} -> ${event.type.name} (adUnit: ${event.adUnitId})');
    // Example: Firebase Analytics logging
    // FirebaseAnalytics.instance.logEvent(
    //   name: 'ad_${event.type.name}',
    //   parameters: {
    //     'ad_format': event.format.name,
    //     'ad_unit_id': event.adUnitId ?? '',
    //     if (event.valueMicros != null) 'value': event.revenueValue!,
    //     if (event.currencyCode != null) 'currency': event.currencyCode!,
    //   },
    // );
  });

  // 4. Request GDPR / CPRA Consent (EU/EEA & UK)
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

### 2. In-App Purchase "Remove Ads" (Ad Suppression)

When a user purchases an ad-free tier or subscription:

```dart
// Turn off all ads globally across the entire app
// All mounted Banner & Native ads instantly disappear
AdManager.setAdsEnabled(false);

// Re-enable ads if subscription expires
AdManager.setAdsEnabled(true);
```

---

### 3. Smart Banner Ads (Adaptive & Fixed)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ads/flutter_ads.dart';

class BannerDemoScreen extends StatelessWidget {
  const BannerDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banner Ad Demo')),
      body: const Column(
        children: [
          Expanded(child: Center(child: Text('App Content'))),
          // Adaptive Smart Banner Ad
          SmartBannerAdView(
            adSize: AdSize.banner,
            showOfflineFallback: true, // Shows policy-compliant house ad when offline
          ),
        ],
      ),
    );
  }
}
```

---

### 4. Smart Native Ads

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ads/flutter_ads.dart';

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

---

### 5. Full-Screen Ads (Interstitial, Rewarded, Rewarded Interstitial)

Use the zero-config singleton `AdsServiceImpl.instance` or instantiate `AdsServiceImpl()`:

```dart
final adsService = AdsServiceImpl.instance;

// Preload all full-screen ads in background
adsService.loadAllAds();

// 1. Show Interstitial (with automatic 30s throttling & collision prevention)
adsService.showInterstitialAd(
  onAdDismissedFullScreenContent: () {
    debugPrint('Interstitial dismissed, continue app flow');
  },
);

// 2. Show Rewarded Video Ad (with optional Server-Side Verification SSV)
adsService.showRewardedAd(
  onUserEarnedReward: (ad, reward) {
    debugPrint('User earned reward: ${reward.amount} ${reward.type}');
  },
);

// 3. Show Rewarded Interstitial Ad
adsService.showRewardedInterstitialAd(
  onUserEarnedReward: (ad, reward) {
    debugPrint('User earned reward');
  },
);
```

---

### 6. Impression-Level Ad Revenue (ILRD / tROAS)

Track exact revenue values for Firebase Analytics, Adjust, AppsFlyer, or Singular:

```dart
AdManager.onAdEvent((event) {
  if (event.type == AdEventType.paid) {
    // Log Impression-Level Ad Revenue (ILRD)
    FirebaseAnalytics.instance.logAdImpression(
      adPlatform: 'AdMob',
      adFormat: event.format.name,
      adUnitName: event.adUnitId,
      value: event.revenueValue, // Revenue in standard currency (e.g. $1.50)
      currency: event.currencyCode, // e.g. 'USD'
    );
  }
});
```

---

### 7. GDPR Consent & Privacy Options Form

For EEA/UK compliance, provide a button in your Settings screen to let users update their consent preferences:

```dart
// Check if user is in a jurisdiction requiring privacy options
final isRequired = await AdManager.isPrivacyOptionsRequired();

if (isRequired) {
  ElevatedButton(
    onPressed: () async {
      await AdManager.showPrivacyOptionsForm();
    },
    child: const Text('Update Privacy & Consent Preferences'),
  );
}
```

---

### 8. COPPA & Google Play Families Policy

For apps targeting children or mixed audiences:

```dart
await AdManager.updateRequestConfiguration(
  tagForChildDirectedTreatment: 1, // 1 = True (COPPA compliance)
  tagForUnderAgeOfConsent: 1,      // 1 = True (EEA under age of consent)
  maxAdContentRating: 'G',         // Max content rating (G, PG, T, MA)
  testDeviceIds: ['EMULATOR_OR_DEVICE_ID'],
);
```

---

## 🛠️ Testing

Run the automated test suite:

```bash
flutter test
```

---

## 📱 Example Application

A complete, production-grade showcase application demonstrating Clean Architecture, BLoC/Cubit, Injectable DI, offline fallbacks, and every Google Mobile Ads format is located in the [`example/`](example/) directory:

```bash
cd example
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

For full details, see the [`example/README.md`](example/README.md).

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

