# Flutter Ads (`flutter_ads`)

[![pub package](https://img.shields.io/pub/v/flutter_ads.svg)](https://pub.dev/packages/flutter_ads)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Google Mobile Ads](https://img.shields.io/badge/AdMob-Google%20Mobile%20Ads-FBBC05?logo=google)](https://admob.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Zero DI](https://img.shields.io/badge/Dependency%20Injection-Zero%20Lock--in-blueviolet)](https://pub.dev/packages/flutter_ads)
[![Policy Compliant](https://img.shields.io/badge/Google%20Play-100%25%20Policy%20Compliant-success)](https://support.google.com/admob)
[![Publisher](https://img.shields.io/badge/Publisher-prakashbahadurchand.com.np-blue)](https://prakashbahadurchand.com.np)

An enterprise-grade, policy-compliant, standalone Google Mobile Ads package for Flutter applications. Built with zero dependency-injection lock-in, reactive "Remove Ads" toggles, offline fallback house ads, unified analytics telemetry, and ready-to-use Agent Skills for autonomous AI integration.

---

## ✨ Features

- 🛡️ **Zero DI Lock-in**: Fully standalone. Works out of the box with Riverpod, BLoC/Cubit, Provider, GetX, or vanilla Flutter without requiring `injectable` or `get_it`.
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

## 🚀 Getting Started

### 1. Add Dependency

Add `flutter_ads` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_ads: ^0.0.1
```

### 2. Platform Setup

#### Android (`android/app/src/main/AndroidManifest.xml`)

Add your Google AdMob App ID inside the `<application>` tag:

```xml
<manifest>
    <!-- Recommended Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="com.google.android.gms.permission.AD_ID"/>

    <application>
        <!-- AdMob App ID (Replace with your real Android App ID in production) -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>

        <!-- Optional: AdMob initialization and loading optimizations -->
        <meta-data
            android:name="com.google.android.gms.ads.flag.OPTIMIZE_INITIALIZATION"
            android:value="true"/>
        <meta-data
            android:name="com.google.android.gms.ads.flag.OPTIMIZE_AD_LOADING"
            android:value="true"/>
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

## 💡 Quick Start & Usage Examples

### 1. Initialize SDK & Consent in `main()`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ads/flutter_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // (Optional) Configure Production Ad Units:
  // AdManager.setRealAds(
  //   androidAppId: 'ca-app-pub-XXX~XXX',
  //   iosAppId: 'ca-app-pub-XXX~XXX',
  //   androidBanner: 'ca-app-pub-XXX/XXX',
  //   iosBanner: 'ca-app-pub-XXX/XXX',
  //   androidInterstitial: 'ca-app-pub-XXX/XXX',
  //   iosInterstitial: 'ca-app-pub-XXX/XXX',
  //   androidRewarded: 'ca-app-pub-XXX/XXX',
  //   iosRewarded: 'ca-app-pub-XXX/XXX',
  //   androidNative: 'ca-app-pub-XXX/XXX',
  //   iosNative: 'ca-app-pub-XXX/XXX',
  //   androidAppOpen: 'ca-app-pub-XXX/XXX',
  //   iosAppOpen: 'ca-app-pub-XXX/XXX',
  // );

  // 1. Request GDPR/UMP Consent
  final consentResult = await AdManager.requestConsent();

  // 2. Initialize AdMob and App Open Ads if allowed by consent
  if (consentResult.canRequestAds) {
    await AdManager.instance.initialize();
    await AdManager.instance.initializeAppOpenAd();
  }

  runApp(const MyApp());
}
```

---

### 2. Display Adaptive / Standard Banner Ads

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ads/flutter_ads.dart';

class MyBannerPage extends StatelessWidget {
  const MyBannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banner Ad Example')),
      body: const Center(child: Text('Content Area')),
      bottomNavigationBar: const SafeArea(
        child: SmartBannerAdView(
          adSize: AdSize.banner, // or use default anchored adaptive
          showOfflineFallback: true,
        ),
      ),
    );
  }
}
```

---

### 3. Display Native Ads (Small & Medium Templates)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ads/flutter_ads.dart';

// Small Native Ad (90px height)
const SmartNativeAdView(
  templateType: TemplateType.small,
  cornerRadius: 12.0,
);

// Medium Native Ad (350px height)
const SmartNativeAdView(
  templateType: TemplateType.medium,
  cornerRadius: 12.0,
);
```

---

### 4. Full-Screen Interstitial & Rewarded Ads

```dart
final adsService = AdsServiceImpl();

// 1. Preload Interstitial
adsService.loadInterstitialAd();

// 2. Show Interstitial (with 30s policy throttling & collision lock)
adsService.showInterstitialAd(
  onAdDismissedFullScreenContent: () {
    // Navigate to next screen
  },
);

// 3. Show Rewarded Video Ad
adsService.showRewardedAd(
  onUserEarnedReward: (ad, reward) {
    print('User earned ${reward.amount} ${reward.type}');
  },
);
```

---

### 5. Impression-Level Ad Revenue (ILRD / tROAS) Telemetry

Capture exact impression revenue values for analytics providers (Firebase, Adjust, AppsFlyer, Singular):

```dart
AdManager.onAdEvent((event) {
  if (event.isPaid) {
    print('Paid Event: ${event.format.name} earned ${event.revenueValue} ${event.currencyCode}');
    // Log to Firebase Analytics:
    // FirebaseAnalytics.instance.logAdImpression(
    //   adPlatform: 'AdMob',
    //   adFormat: event.format.name,
    //   adUnitName: event.adUnitId,
    //   value: event.revenueValue,
    //   currency: event.currencyCode,
    // );
  }
});
```

---

### 6. Reactive In-App Purchase ("Remove Ads") Toggle

When a user purchases an ad-free subscription or lifetime unlock:

```dart
// Globally hide and dispose all mounted banners and native ads instantly
AdManager.setAdsEnabled(false);
```

---

## 📱 Example Application

A complete showcase application demonstrating Clean Architecture, BLoC/Cubit, Injectable DI, offline fallback promotions, and every ad format is located in the [`example/`](example/) directory:

```bash
cd example
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

For full details, see [`example/README.md`](example/README.md).

---

## 👨‍💻 Author & Publisher

Developed and published by **[Prakash Bahadur Chand](https://prakashbahadurchand.com.np)**:
- 🌐 Website: [prakashbahadurchand.com.np](https://prakashbahadurchand.com.np)
- ✉️ Email: [prakashbahadurchand@gmail.com](mailto:prakashbahadurchand@gmail.com)
- 🐙 GitHub: [@prakashbahadurchand](https://github.com/prakashbahadurchand)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
