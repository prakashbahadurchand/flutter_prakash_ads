# 🚀 Google Mobile Ads Clean Architecture Demo (Flutter)

[![Flutter](https://img.shields.io/badge/Flutter-3.44.9-02569B?logo=flutter)](https://flutter.dev)
[![AdMob](https://img.shields.io/badge/AdMob-Google_Mobile_Ads-EA4335?logo=google)](https://admob.google.com)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20Cubit%20%2B%20Injectable-4CAF50)](https://bloclibrary.dev)
[![Modular](https://img.shields.io/badge/Package-flutter__prakash__ads-blueviolet)](https://github.com/prakashbahadurchand/flutter_prakash_ads)
[![Policy](https://img.shields.io/badge/Compliance-100%25%20Google%20Play%20%26%20AdMob-brightgreen)](https://support.google.com/admob)

An enterprise-ready, production-grade Flutter application demonstrating complete clean architecture, modular ad components, real-time connectivity detection, and strict compliance with **Google AdMob**, **Google Play Store Developer Policies**, and **Better Ads Standards**.

Powered by the modular **`flutter_prakash_ads`** package to eliminate 99% of boilerplate core code!

---

## 🌟 Highlights & Features

- 🎯 **All Google Mobile Ad Formats**: App Open, Smart Banner, Smart Native Template, Interstitial, Rewarded Video, and Rewarded Interstitial.
- ⚡ **Single Unified `AdsService`**: Injected facade service handling full-screen ad lifecycles, exponential backoff, 30s frequency throttling, and 4-hour cache invalidation.
- 🖼️ **Smart Widgets (`SmartBannerAdView` & `SmartNativeAdView`)**: Self-contained, auto-managed widgets with real-time connectivity listening and policy-compliant custom offline fallbacks.
- 📱 **5-Tab Production Dashboard**:
  - 🏠 **Home**: Article feed with inline native ads + sticky bottom banner.
  - ❤️ **Favorites**: Saved bookmarked articles with `FavoritesCubit` local persistence.
  - ➕ **Create**: Interactive bottom sheet for creating Articles, Stories, and Videos.
  - 🔔 **Notifications**: Real-time notification center with unread badges and mark-all-read action.
  - 👤 **Profile**: Live synchronized Coin balance, real-time Material 3 **Light / Dark / System** theme selector, language dialog, and GDPR Privacy Consent settings.
- 🪙 **App-Wide Rewarded Coin Persistence**: Rewarded video coins saved to `SharedPreferences` via `AdsCubit` and synchronized reactively across all screens.
- 🎨 **Rich Colorful Logging (`ConsoleLogger`)**: Formatted ANSI terminal output with ad lifecycles, ROAS revenue tracking (6-decimal precision + micros), and startup banners.
- 🌐 **Real-time Offline Fallback**: Automatically displays compliant fallback ads with prominent **`AD`** attribution badges when disconnected.
- 🛡️ **100% Policy-Safe (Zero IVT / Invalid Click Violations)**:
  - **GDPR / CPRA / TCF v2.2**: User Messaging Platform (UMP) consent initialization and Privacy Options revocation form.
  - **Better Ads Standards**: App Open cold start deadline guard (4s) + background resume threshold (15s).
  - **Zero Full-Screen Ad Collisions**: Centralized coordinator (`AdsManager.isShowingFullScreenAd`) prevents simultaneous ad popups.
  - **4-Hour Staleness Rule**: Automatic cache invalidation and refreshment for stale ads.
  - **CLS Prevention**: Rigid layout bounds preventing Cumulative Layout Shift and accidental clicks.
- 📦 **Release-Ready Android**: Configured permissions (`INTERNET`, `ACCESS_NETWORK_STATE`, `AD_ID`), AdMob optimization flags, hardware acceleration, and ProGuard/R8 rules.

---

## 📱 Multi-Screen Flow & Policy Implementation

```
┌─────────────────┐        ┌──────────────────┐        ┌─────────────────────────────────────────────────────────┐
│   Splash Page   │ ────►  │ Onboarding Page  │ ────►  │                     5-Tab Dashboard                     │
│ (Brand & Init)  │        │ (Zero Ad Distr.) │        │  ┌───────┬───────────┬─────────┬───────────────┬─────────┐  │
└─────────────────┘        └──────────────────┘        │  │ Home  │ Favorites │ Create  │ Notifications │ Profile │  │
         │                          │                  │  └───────┴───────────┴─────────┴───────────────┴─────────┘  │
  • No Banner/Native         • Suppress App Open       └─────────────────────────────────────────────────────────┘
  • UMP Consent Init           (setSuppressed: true)                               │
  • 1st Launch: Skip ad      • No Interstitials                        ┌───────────┴───────────┐
  • 2nd+ Launch: 4s          • Unsuppress on exit                      ▼                       ▼
    deadline App Open                                        ContentDetailPage       AdsDemoPage
                                                             (Rewarded + Rect Ad)    (Interactive Playground)
```

---

## 📱 Supported Ad Formats & Architecture

| Format                       | Service / Component             | Description                                                                                                           |
| :--------------------------- | :------------------------------ | :-------------------------------------------------------------------------------------------------------------------- |
| 🚪 **App Open Ad**           | `AdsService` / `AppOpenAdManager` | Auto-shows on 2nd+ cold start and on app resume (15s threshold) with 4-hour max-age eviction and feature suppression. |
| 🖼️ **Smart Banner**          | `SmartBannerAdView`             | Self-contained banner view (320x50, 300x250) with auto-switch to `CustomOfflineBannerAdWidget`.                       |
| 🎨 **Smart Native Ad**       | `SmartNativeAdView`             | Policy-compliant native ad with small/medium templates and auto-switch to `CustomOfflineNativeAdWidget`.              |
| 🎬 **Interstitial Ad**       | `AdsService`                    | Full-screen transition ads with 30s frequency throttling, exponential retries, auto-preload, and collision lock.      |
| 🎁 **Rewarded Video**        | `AdsService`                    | High-engagement rewarded video ads with secure reward validation callbacks.                                           |
| 💎 **Rewarded Interstitial** | `AdsService`                    | Non-interruptive reward experience with immediate reward grant flow.                                                  |

---

## 💡 Example Usage & Code Guidelines

### 1. 🏁 App Entrypoint & `MyAdsService` Initialization ([lib/main.dart](lib/main.dart))

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adsdemo/core/di/injection.dart';
import 'package:adsdemo/core/ads/my_ads_service.dart';
import 'package:adsdemo/core/theme/theme_cubit.dart';
import 'package:adsdemo/core/ads/cubit/ads_cubit.dart';
import 'package:adsdemo/features/dashboard/presentation/cubit/favorites_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Dependency Injection (GetIt & Injectable)
  await configureDependencies();

  // 2. Setup Ads, Offline Promos, Consent, & Analytics
  await MyAdsService.initFromMain();

  runApp(const AdsDemoApp());
}
```

#### Inside `MyAdsService.initFromMain()` ([lib/core/ads/my_ads_service.dart](lib/core/ads/my_ads_service.dart)):

```dart
class MyAdsService {
  static Future<void> initFromMain() async {
    // 1. Setup offline promotion fallback ads
    AdsManager.setupCustomAds(const [
      CustomAdModel(
        id: 'custom_pro_promo',
        title: 'Upgrade to Pro Edition',
        description: 'Unlock 100+ premium features and an ad-free experience.',
        callToAction: 'Upgrade Now',
      ),
    ]);

    // 2. Global Ad Event & ROAS Analytics Listener with 6-decimal precision
    AdsManager.onAdEvent((event) {
      if (event.isPaid) {
        ConsoleLogger.adRevenue(
          format: event.format.name,
          revenue: event.revenueValue ?? 0.0,
          micros: event.valueMicros ?? 0.0,
          currency: event.currencyCode ?? 'USD',
          precision: event.precision?.name ?? 'unknown',
          adUnitId: event.adUnitId,
        );
      }
    });

    // 3. Request User Messaging Platform (UMP) Consent
    final consentResult = await AdsManager.requestConsent();

    // 4. Initialize SDK & App Open lifecycle if consent permits
    if (consentResult.canRequestAds) {
      await AdsManager.instance.initialize();
      await AdsManager.instance.initializeAppOpenAd();
    }
  }
}
```

---

### 2. ⚡ Single Unified `AdsService` in Features / Cubit

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_prakash_ads/flutter_prakash_ads.dart';
import 'package:injectable/injectable.dart';
import 'ads_state.dart';

@lazySingleton
class AdsCubit extends Cubit<AdsState> {
  AdsCubit({required this.adsService}) : super(const AdsState());

  final AdsService adsService;

  /// 🔄 Preload all ad formats at once
  void loadAllAds() {
    adsService.loadInterstitialAd();
    adsService.loadRewardedAd();
    adsService.loadRewardedInterstitialAd();
    adsService.loadAppOpenAd();
  }

  /// 🎬 1. Show Interstitial Ad (with built-in 30s interval throttling)
  void showInterstitialAd() {
    if (adsService.isInterstitialAdAvailable) {
      adsService.showInterstitialAd(
        onAdDismissedFullScreenContent: () => print('Interstitial Closed'),
      );
    } else {
      adsService.loadInterstitialAd();
    }
  }

  /// 🎁 2. Show Rewarded Video Ad
  void showRewardedAd() {
    if (adsService.isRewardedAdAvailable) {
      adsService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          final amount = reward.amount.toInt() == 0 ? 50 : reward.amount.toInt();
          userEarnedReward(amount);
        },
      );
    } else {
      adsService.loadRewardedAd();
    }
  }

  /// 💎 3. Show Rewarded Interstitial Ad
  void showRewardedInterstitialAd() {
    if (adsService.isRewardedInterstitialAdAvailable) {
      adsService.showRewardedInterstitialAd(
        onUserEarnedReward: (ad, reward) {
          final amount = reward.amount.toInt() == 0 ? 100 : reward.amount.toInt();
          userEarnedReward(amount);
        },
      );
    } else {
      adsService.loadRewardedInterstitialAd();
    }
  }

  /// 🚪 4. Show App Open Ad
  void showAppOpenAd() {
    if (adsService.isAppOpenAdAvailable) {
      adsService.showAppOpenAdIfAvailable();
    } else {
      adsService.loadAppOpenAd();
    }
  }

  void userEarnedReward(int amount) {
    emit(state.copyWith(
      coins: state.coins + amount,
      snackBarMessage: '🎉 Earned $amount coins!',
    ));
  }

  @override
  Future<void> close() {
    adsService.dispose();
    return super.close();
  }
}
```

---

### 3. 🖼️ `SmartBannerAdView` (Banner Ad with Real-Time Offline Fallback)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_prakash_ads/flutter_prakash_ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Standard 320x50 Banner
const SmartBannerAdView(
  adSize: AdSize.banner,
)

// Medium Rectangle 300x250 Banner
const SmartBannerAdView(
  adSize: AdSize.mediumRectangle,
)
```

---

### 4. 🎨 `SmartNativeAdView` (Native Ad with Real-Time Offline Fallback)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_prakash_ads/flutter_prakash_ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Medium Native Template View (350px height)
const SmartNativeAdView(
  templateType: TemplateType.medium,
  cornerRadius: 16.0,
)

// Small Native Template View (90px height)
const SmartNativeAdView(
  templateType: TemplateType.small,
  cornerRadius: 12.0,
)
```

---

### 5. 🛡️ Lifecycle Suppression & GDPR Revocation Form

```dart
// 1. Suppress App Open ads during sensitive flows (e.g. onboarding or checkout):
AdsManager.setAppOpenSuppressed(true);  // Pause app open ads
// ... user finishes flow ...
AdsManager.setAppOpenSuppressed(false); // Re-enable app open ads

// 2. Open GDPR Privacy Options Revocation Form anywhere:
await AdsManager.showPrivacyOptionsForm();
```

---

## 📁 Clean Folder Structure

```text
lib/
├── core/
│   ├── ads/                              # 🛡️ Ads State & App Service
│   │   ├── cubit/                        # ⚡ Lightweight AdsCubit & State
│   │   │   ├── ads_cubit.dart
│   │   │   └── ads_state.dart
│   │   └── my_ads_service.dart           # ⚙️ Master Ads Initialization & Config
│   ├── di/                               # 💉 Dependency Injection
│   │   ├── ads_module.dart               # Injectable module for flutter_prakash_ads
│   │   ├── injection.dart                # GetIt & Injectable bootstrapping
│   │   └── injection.config.dart         # Generated DI graph
│   ├── network/                          # 🌐 Networking & Connectivity
│   │   └── network_module.dart           # Injectable Dio & InternetConnection providers
│   ├── router/                           # 🧭 Declarative Routing
│   │   ├── app_router.dart               # AutoRoute root configuration
│   │   └── app_router.gr.dart            # Generated route manifests
│   ├── theme/                            # 🌓 Theme Management
│   │   └── theme_cubit.dart              # Material 3 Light/Dark/System Switcher
│   └── utils/                            # 🛠️ Utilities
│       └── console_logger.dart           # 🎨 Formatted ANSI Console Logger
├── features/
│   ├── splash/                           # 🚀 Splash Screen (Brand + Consent Init)
│   │   └── presentation/pages/splash_page.dart
│   ├── onboarding/                       # 🚪 Onboarding (Zero Ad Distraction)
│   │   └── presentation/pages/onboarding_page.dart
│   └── dashboard/                        # 📊 5-Tab Dashboard Hub
│       ├── domain/models/article_item.dart
│       └── presentation/
│           ├── cubit/favorites_cubit.dart# ❤️ Favorites Bookmark State
│           ├── pages/
│           │   ├── dashboard_page.dart   # 5-Tab Bottom Nav Shell + Create FAB
│           │   ├── content_detail_page.dart # Details (Opt-in Rewarded + 300x250)
│           │   └── ads_demo_page.dart    # Interactive Ad Formats Playground
│           └── tabs/
│               ├── home_tab.dart         # Feed (Sticky banner + Native ads)
│               ├── favorites_tab.dart    # Saved Bookmarked Articles
│               ├── notifications_tab.dart# In-App Notification Center
│               └── profile_tab.dart      # Live Coins, Theme, Locale, Privacy
└── main.dart                             # 🏁 App Entrypoint (DI -> MyAdsService -> Router)
```

---

## 🛠️ Developer Workflow & Makefile Shortcuts

Use the built-in [Makefile](Makefile) for rapid, automated commands:

```bash
# 🔄 Refetch/update flutter_prakash_ads local package & regenerate code
make refetch-flutter_prakash_ads

# ⚡ Clean, get dependencies, and regenerate build_runner code
make fcgb

# 📦 Get Flutter dependencies
make get

# 🏃 Run app in Debug mode
make run

# ⚡ Run app in Release mode
make run-release

# 🔄 Run build_runner code generation (Injectable & AutoRoute)
make codegen

# 👀 Run build_runner in continuous watch mode
make watch

# 🔍 Analyze Dart code (passes with 0 warnings)
make analyze

# 🎨 Format Dart codebase
make format

# 🧪 Run Flutter unit & widget tests
make test

# 🧹 Clean Flutter build cache and artifacts
make clean

# 📱 Build split APKs for Android release
make build-apk

# 🚀 Build Android AppBundle (AAB) for Google Play Store upload
make build-appbundle
```

---

## ⚙️ Platform Setup & Production Deployment

### 🤖 Android Setup

1. **Manifest Permissions & App ID** ([android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)):

   ```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android">
       <!-- Permissions -->
       <uses-permission android:name="android.permission.INTERNET"/>
       <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
       <uses-permission android:name="com.google.android.gms.permission.AD_ID"/>

       <application ... android:hardwareAccelerated="true">
           <!-- AdMob App ID (Replace with production App ID before release) -->
           <meta-data
               android:name="com.google.android.gms.ads.APPLICATION_ID"
               android:value="ca-app-pub-3940256099942544~3347511713"/>

           <!-- AdMob Performance Flags -->
           <meta-data
               android:name="com.google.android.gms.ads.flag.OPTIMIZE_INITIALIZATION"
               android:value="true"/>
           <meta-data
               android:name="com.google.android.gms.ads.flag.OPTIMIZE_AD_LOADING"
               android:value="true"/>
       </application>
   </manifest>
   ```

2. **AppCompat Styles Compatibility** ([android/app/src/main/res/values/styles.xml](android/app/src/main/res/values/styles.xml)):
   - `NormalTheme` inherits from `Theme.AppCompat.Light.NoActionBar` to support Google Mobile Ads Native Templates cleanly.

3. **ProGuard / R8 Rules** ([android/app/proguard-rules.pro](android/app/proguard-rules.pro)):
   - Configured with rules preserving AdMob classes, mediation adapters, and `AdActivity` lifecycle handlers.

---

### 🍏 iOS Setup (When Adding iOS)

In `ios/Runner/Info.plist`:

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

## 📄 License & Policies

This project complies strictly with the [Google AdMob Policies](https://support.google.com/admob/answer/6128543), [Invalid Traffic (IVT) Guidelines](https://support.google.com/admob/answer/3342054), and the [Google Play Developer Program Policies](https://play.google.com/about/developer-content-policy/).
