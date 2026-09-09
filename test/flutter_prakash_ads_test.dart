import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_prakash_ads/flutter_prakash_ads.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdConstants & AdManager Ad Unit IDs', () {
    setUp(() {
      AdsManager.reset();
    });

    tearDown(() {
      AdsManager.reset();
    });

    test('constants return official Google test ad unit IDs', () {
      AdConstants.useTestAds = true;
      expect(AdConstants.androidTestAppId, isNotEmpty);
      expect(AdConstants.iosTestAppId, isNotEmpty);
      expect(AdConstants.androidTestBanner, isNotEmpty);
      expect(AdConstants.iosTestBanner, isNotEmpty);
      expect(AdConstants.androidTestInterstitial, isNotEmpty);
      expect(AdConstants.iosTestInterstitial, isNotEmpty);
      expect(AdConstants.androidTestRewarded, isNotEmpty);
      expect(AdConstants.iosTestRewarded, isNotEmpty);
      expect(AdConstants.androidTestNative, isNotEmpty);
      expect(AdConstants.iosTestNative, isNotEmpty);
      expect(AdConstants.androidTestAppOpen, isNotEmpty);
      expect(AdConstants.iosTestAppOpen, isNotEmpty);
    });

    test('setRealAdUnitIds and setRealAppIds configure real IDs correctly', () {
      const customAndroidAppId = 'ca-app-pub-9999999999999999~1111111111';
      const customIosAppId = 'ca-app-pub-9999999999999999~2222222222';
      const customAndroidBanner = 'ca-app-pub-9999999999999999/1111111111';
      const customIosBanner = 'ca-app-pub-9999999999999999/2222222222';
      const customAndroidInterstitial =
          'ca-app-pub-9999999999999999/3333333333';
      const customAndroidRewarded = 'ca-app-pub-9999999999999999/4444444444';
      const customAndroidRewardedInterstitial =
          'ca-app-pub-9999999999999999/5555555555';
      const customAndroidNative = 'ca-app-pub-9999999999999999/6666666666';
      const customAndroidAppOpen = 'ca-app-pub-9999999999999999/7777777777';

      AdManager.setRealAppIds(
        androidAppId: customAndroidAppId,
        iosAppId: customIosAppId,
      );

      AdManager.setRealAdUnitIds(
        androidBanner: customAndroidBanner,
        iosBanner: customIosBanner,
        androidInterstitial: customAndroidInterstitial,
        androidRewarded: customAndroidRewarded,
        androidRewardedInterstitial: customAndroidRewardedInterstitial,
        androidNative: customAndroidNative,
        androidAppOpen: customAndroidAppOpen,
      );

      expect(AdConstants.androidRealAppId, customAndroidAppId);
      expect(AdConstants.iosRealAppId, customIosAppId);
      expect(AdConstants.androidRealBanner, customAndroidBanner);
      expect(AdConstants.iosRealBanner, customIosBanner);
      expect(AdConstants.androidRealInterstitial, customAndroidInterstitial);
      expect(AdConstants.androidRealRewarded, customAndroidRewarded);
      expect(AdConstants.androidRealRewardedInterstitial,
          customAndroidRewardedInterstitial);
      expect(AdConstants.androidRealNative, customAndroidNative);
      expect(AdConstants.androidRealAppOpen, customAndroidAppOpen);
    });

    test('AdManager.setRealAds sets both app IDs and ad units', () {
      AdManager.setRealAds(
        androidAppId: 'app_123',
        androidBanner: 'banner_123',
        useTestAds: false,
      );

      expect(AdConstants.androidRealAppId, 'app_123');
      expect(AdConstants.androidRealBanner, 'banner_123');
      expect(AdConstants.useTestAds, isFalse);
    });

    test('useTestAds = true forces test ad units even if real IDs are present',
        () {
      AdConstants.useTestAds = true;
      AdConstants.setRealAdUnitIds(androidBanner: 'real_banner');

      expect(AdConstants.useTestAds, isTrue);
    });

    test('AdManager.setAdsEnabled controls global ad visibility', () {
      expect(AdManager.isAdsEnabled, isTrue);
      expect(AdsManager.adsEnabledNotifier.value, isTrue);

      AdManager.setAdsEnabled(false);
      expect(AdManager.isAdsEnabled, isFalse);
      expect(AdsManager.adsEnabledNotifier.value, isFalse);

      AdManager.setAdsEnabled(true);
      expect(AdManager.isAdsEnabled, isTrue);
      expect(AdsManager.adsEnabledNotifier.value, isTrue);
    });
  });

  group('CustomAdModel & AdsManager.setupCustomAds', () {
    setUp(() {
      AdsManager.reset();
    });

    tearDown(() {
      AdsManager.reset();
    });

    test('CustomAdModel creates and serializes properly', () {
      const customAd = CustomAdModel(
        id: 'ad_1',
        title: 'Upgrade to Pro',
        description: 'Enjoy ad-free experience and premium tools.',
        imageUrl: 'assets/images/pro_promo.png',
        link: 'https://myapp.com/pro',
        callToAction: 'Upgrade Now',
        advertiser: 'App Pro Inc.',
        rating: 4.95,
      );

      expect(customAd.id, 'ad_1');
      expect(customAd.title, 'Upgrade to Pro');
      expect(
          customAd.description, 'Enjoy ad-free experience and premium tools.');
      expect(customAd.imageUrl, 'assets/images/pro_promo.png');
      expect(customAd.link, 'https://myapp.com/pro');
      expect(customAd.callToAction, 'Upgrade Now');
      expect(customAd.advertiser, 'App Pro Inc.');
      expect(customAd.rating, 4.95);

      final json = customAd.toJson();
      final parsed = CustomAdModel.fromJson(json);

      expect(parsed.id, 'ad_1');
      expect(parsed.title, 'Upgrade to Pro');
      expect(parsed.description, 'Enjoy ad-free experience and premium tools.');
      expect(parsed.imageUrl, 'assets/images/pro_promo.png');
      expect(parsed.link, 'https://myapp.com/pro');
      expect(parsed.callToAction, 'Upgrade Now');
      expect(parsed.advertiser, 'App Pro Inc.');
      expect(parsed.rating, 4.95);
    });

    test('AdsManager.setupCustomAds registers and retrieves custom ads', () {
      expect(AdsManager.customAds, isEmpty);
      expect(AdsManager.getCustomAd(), isNull);

      const ads = [
        CustomAdModel(
          id: 'ad_1',
          title: 'Special Promo 1',
          description: 'Description 1',
          imageUrl: 'assets/ad1.png',
          link: 'https://promo1.com',
        ),
        CustomAdModel(
          id: 'ad_2',
          title: 'Special Promo 2',
          description: 'Description 2',
          imageUrl: 'assets/ad2.png',
          link: 'https://promo2.com',
        ),
      ];

      AdsManager.setupCustomAds(ads);

      expect(AdsManager.customAds.length, 2);
      expect(AdsManager.getCustomAd(index: 0)?.title, 'Special Promo 1');
      expect(AdsManager.getCustomAd(index: 1)?.title, 'Special Promo 2');

      final randomAd = AdsManager.getCustomAd();
      expect(randomAd, isNotNull);
      expect(ads.map((a) => a.id).contains(randomAd!.id), isTrue);

      AdsManager.clearCustomAds();
      expect(AdsManager.customAds, isEmpty);
      expect(AdsManager.getCustomAd(), isNull);
    });
  });

  group('AdsManager onAdEvent & Analytics integration', () {
    setUp(() {
      AdsManager.reset();
    });

    tearDown(() {
      AdsManager.reset();
    });

    test('onAdEvent callback receives emitted events with helpers', () {
      AdEvent? receivedEvent;
      AdsManager.onAdEvent((event) {
        receivedEvent = event;
      });

      final testEvent = AdEvent(
        format: AdFormat.interstitial,
        type: AdEventType.loaded,
        adUnitId: 'test_ad_unit_123',
      );

      AdsManager.emitAdEvent(testEvent);

      expect(receivedEvent, isNotNull);
      expect(receivedEvent!.format, AdFormat.interstitial);
      expect(receivedEvent!.type, AdEventType.loaded);
      expect(receivedEvent!.adUnitId, 'test_ad_unit_123');
      expect(receivedEvent!.isError, isFalse);
      expect(receivedEvent!.isPaid, isFalse);
      expect(receivedEvent!.timestamp, isNotNull);
    });

    test('adEventStream emits events for stream subscribers', () async {
      final eventsFuture = AdsManager.adEventStream.first;

      final testPaidEvent = AdEvent(
        format: AdFormat.banner,
        type: AdEventType.paid,
        adUnitId: 'banner_unit',
        valueMicros: 1500000.0,
        currencyCode: 'USD',
      );

      AdsManager.emitAdEvent(testPaidEvent);

      final event = await eventsFuture;
      expect(event.format, AdFormat.banner);
      expect(event.type, AdEventType.paid);
      expect(event.revenueValue, 1.5);
      expect(event.currencyCode, 'USD');
      expect(event.isPaid, isTrue);
    });
  });

  group('Widget Tests for Policy-Compliant Custom Fallback Ads', () {
    setUp(() {
      AdsManager.reset();
    });

    tearDown(() {
      AdsManager.reset();
    });

    testWidgets(
        'CustomOfflineBannerAdWidget renders AD badge, triggers callbacks and onCustomAdClicked',
        (tester) async {
      bool localTapped = false;
      CustomAdModel? globalClickedAd;

      AdsManager.onCustomAdClicked = (ad) {
        globalClickedAd = ad;
      };

      const customAd = CustomAdModel(
        id: 'banner_test_ad',
        title: 'Test Headline',
        description: 'Test Subtitle',
        link: 'https://test.com',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomOfflineBannerAdWidget(
              customAd: customAd,
              onTap: () {
                localTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('AD'), findsOneWidget);
      expect(find.text('Test Headline'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      expect(localTapped, isTrue);
      expect(globalClickedAd, isNotNull);
      expect(globalClickedAd!.id, 'banner_test_ad');
    });

    testWidgets(
        'CustomOfflineNativeAdWidget renders medium layout and handles tap',
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomOfflineNativeAdWidget(
              templateType: TemplateType.medium,
              headline: 'Native Ad Headline',
              body: 'Native Ad Description Body',
              callToAction: 'Get App',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('AD'), findsOneWidget);
      expect(find.text('Native Ad Headline'), findsOneWidget);
      expect(find.text('Native Ad Description Body'), findsOneWidget);
      expect(find.text('Get App'), findsOneWidget);

      await tester.tap(find.text('Get App'));
      expect(tapped, isTrue);
    });
  });

  group('Service & Network Initialization (Zero DI)', () {
    test('AdsServiceImpl instantiates standalone with zero configuration', () {
      final adsService = AdsServiceImpl();
      expect(adsService, isNotNull);
      expect(adsService.isInterstitialAdAvailable, isFalse);
      expect(adsService.isRewardedAdAvailable, isFalse);
      expect(adsService.isRewardedInterstitialAdAvailable, isFalse);
    });

    test('NetworkInfoImpl instantiates standalone with zero configuration', () {
      final networkInfo = NetworkInfoImpl();
      expect(networkInfo, isNotNull);
    });

    test('AdsManager singleton and typedef alias work', () {
      expect(AdsManager.instance, isNotNull);
      expect(AdManager.instance, same(AdsManager.instance));
    });
  });

  group('Conditional Network Checking & Fallback Eligibility', () {
    setUp(() {
      AdsManager.reset();
    });

    tearDown(() {
      AdsManager.reset();
    });

    test('AdsManager.hasCustomAds reflects registered custom ads accurately',
        () {
      expect(AdsManager.hasCustomAds, isFalse);
      expect(AdsManager.enableNetworkCheck, isTrue);

      AdsManager.setupCustomAds(const [
        CustomAdModel(
          title: 'Custom Title',
          description: 'Custom Description',
        ),
      ]);
      expect(AdsManager.hasCustomAds, isTrue);

      AdsManager.clearCustomAds();
      expect(AdsManager.hasCustomAds, isFalse);

      AdsManager.setupCustomAds(const [
        CustomAdModel(
          title: 'Custom Title',
          description: 'Custom Description',
        ),
      ]);
      expect(AdsManager.hasCustomAds, isTrue);

      AdsManager.enableNetworkCheck = false;
      expect(AdsManager.enableNetworkCheck, isFalse);

      AdsManager.reset();
      expect(AdsManager.hasCustomAds, isFalse);
      expect(AdsManager.enableNetworkCheck, isTrue);
    });

    test('AdsManager.hasCustomAdForFallback evaluates all conditions correctly',
        () {
      // 1. Initially no custom ads
      expect(AdsManager.hasCustomAdForFallback(), isFalse);

      // 2. Explicit custom widget provided
      expect(
        AdsManager.hasCustomAdForFallback(
          customOfflineWidget: const Text('Custom Offline Widget'),
        ),
        isTrue,
      );

      // 3. Explicit customAd model provided
      expect(
        AdsManager.hasCustomAdForFallback(
          customAd: const CustomAdModel(
            title: 'Ad',
            description: 'Desc',
          ),
        ),
        isTrue,
      );

      // 4. showOfflineFallback is false even if custom ads registered
      AdsManager.setupCustomAds(const [
        CustomAdModel(title: 'Ad', description: 'Desc'),
      ]);
      expect(
        AdsManager.hasCustomAdForFallback(showOfflineFallback: false),
        isFalse,
      );

      // 5. showOfflineFallback is true and custom ads registered
      expect(
        AdsManager.hasCustomAdForFallback(showOfflineFallback: true),
        isTrue,
      );
    });

    testWidgets(
        'SmartBannerAdView does NOT show CustomOfflineBannerAdWidget when setupCustomAds was NOT called',
        (tester) async {
      AdsManager.clearCustomAds();
      expect(AdsManager.hasCustomAds, isFalse);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartBannerAdView(),
          ),
        ),
      );

      // Should NOT render custom offline banner fallback or fake ads
      expect(find.byType(CustomOfflineBannerAdWidget), findsNothing);
      expect(find.text('Featured App Spotlight'), findsNothing);
      expect(find.text('AD'), findsNothing);
    });

    testWidgets(
        'SmartNativeAdView does NOT show CustomOfflineNativeAdWidget when setupCustomAds was NOT called',
        (tester) async {
      AdsManager.clearCustomAds();
      expect(AdsManager.hasCustomAds, isFalse);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartNativeAdView(),
          ),
        ),
      );

      // Should NOT render custom offline native fallback or fake ads
      expect(find.byType(CustomOfflineNativeAdWidget), findsNothing);
      expect(find.text('Upgrade to Offline Pro'), findsNothing);
      expect(find.text('AD'), findsNothing);
    });

    testWidgets(
        'SmartBannerAdView renders CustomOfflineBannerAdWidget when custom ads ARE configured and disconnected',
        (tester) async {
      AdsManager.setupCustomAds(const [
        CustomAdModel(
          id: 'custom_banner_1',
          title: 'Special House Promo',
          description: 'Exclusive in-app discount',
          callToAction: 'Claim',
        ),
      ]);
      expect(AdsManager.hasCustomAds, isTrue);

      final fakeNetwork = TestNetworkInfo(initialConnected: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartBannerAdView(
              networkInfo: fakeNetwork,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CustomOfflineBannerAdWidget), findsOneWidget);
      expect(find.text('Special House Promo'), findsOneWidget);
      expect(find.text('AD'), findsOneWidget);
      expect(fakeNetwork.onStatusChangeListenCount, 1);

      fakeNetwork.dispose();
    });

    testWidgets(
        'SmartNativeAdView renders CustomOfflineNativeAdWidget when custom ads ARE configured and disconnected',
        (tester) async {
      AdsManager.setupCustomAds(const [
        CustomAdModel(
          id: 'custom_native_1',
          title: 'Native House Promo',
          description: 'Special in-app promotion',
          callToAction: 'Explore',
        ),
      ]);
      expect(AdsManager.hasCustomAds, isTrue);

      final fakeNetwork = TestNetworkInfo(initialConnected: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartNativeAdView(
              networkInfo: fakeNetwork,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CustomOfflineNativeAdWidget), findsOneWidget);
      expect(find.text('Native House Promo'), findsOneWidget);
      expect(find.text('AD'), findsOneWidget);
      expect(fakeNetwork.onStatusChangeListenCount, 1);

      fakeNetwork.dispose();
    });

    testWidgets(
        'SmartBannerAdView bypasses network check when enableNetworkCheck is false',
        (tester) async {
      AdsManager.setupCustomAds(const [
        CustomAdModel(title: 'Promo', description: 'Desc'),
      ]);
      AdsManager.enableNetworkCheck = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartBannerAdView(),
          ),
        ),
      );

      expect(find.byType(CustomOfflineBannerAdWidget), findsNothing);
    });

    test('AdConstants.isPlatformSupported returns a boolean', () {
      expect(AdConstants.isPlatformSupported, isA<bool>());
    });

    test('AdsService lifecycle and disposal cleanup test', () {
      final adsService = AdsServiceImpl();
      expect(adsService.isInterstitialAdAvailable, isFalse);
      expect(adsService.isRewardedAdAvailable, isFalse);
      expect(adsService.isRewardedInterstitialAdAvailable, isFalse);

      adsService.dispose();
      expect(adsService.isInterstitialAdAvailable, isFalse);
      expect(adsService.isRewardedAdAvailable, isFalse);
      expect(adsService.isRewardedInterstitialAdAvailable, isFalse);
    });

    test('Dedicated ad services disposal cleanup test', () {
      final interstitialService = InterstitialAdService();
      final rewardedService = RewardedAdService();
      final rewardedInterstitialService = RewardedInterstitialAdService();

      expect(interstitialService.isAdAvailable, isFalse);
      expect(rewardedService.isAdAvailable, isFalse);
      expect(rewardedInterstitialService.isAdAvailable, isFalse);

      interstitialService.dispose();
      rewardedService.dispose();
      rewardedInterstitialService.dispose();

      expect(interstitialService.isAdAvailable, isFalse);
      expect(rewardedService.isAdAvailable, isFalse);
      expect(rewardedInterstitialService.isAdAvailable, isFalse);
    });

    test(
        'Full-screen ad dismiss callback triggers when ads are disabled (non-blocking)',
        () {
      AdsManager.setAdsEnabled(false);

      final interstitialService = InterstitialAdService();
      bool dismissedCalled = false;

      interstitialService.showAd(
        onAdDismissedFullScreenContent: () {
          dismissedCalled = true;
        },
      );

      expect(dismissedCalled, isTrue);

      final rewardedService = RewardedAdService();
      bool rewardedDismissedCalled = false;

      rewardedService.showAd(
        onUserEarnedReward: (_, __) {},
        onAdDismissedFullScreenContent: () {
          rewardedDismissedCalled = true;
        },
      );

      expect(rewardedDismissedCalled, isTrue);
    });
  });

  group('Multi Ad Unit IDs (Up to 3 Banner & Native) & Platform Separation',
      () {
    setUp(() {
      AdsManager.reset();
    });

    tearDown(() {
      AdsManager.reset();
    });

    test('setRealAndroidAdUnitIds sets Android IDs without affecting iOS', () {
      AdManager.setRealAndroidAdUnitIds(
        banner: 'android_b1',
        banner2: 'android_b2',
        banner3: 'android_b3',
        native: 'android_n1',
        native2: 'android_n2',
        native3: 'android_n3',
        interstitial: 'android_i',
        rewarded: 'android_r',
        rewardedInterstitial: 'android_ri',
        appOpen: 'android_ao',
      );

      expect(AdConstants.androidRealBanner, 'android_b1');
      expect(AdConstants.androidRealBanner2, 'android_b2');
      expect(AdConstants.androidRealBanner3, 'android_b3');
      expect(AdConstants.androidRealNative, 'android_n1');
      expect(AdConstants.androidRealNative2, 'android_n2');
      expect(AdConstants.androidRealNative3, 'android_n3');
      expect(AdConstants.androidRealInterstitial, 'android_i');
      expect(AdConstants.androidRealRewarded, 'android_r');
      expect(AdConstants.androidRealRewardedInterstitial, 'android_ri');
      expect(AdConstants.androidRealAppOpen, 'android_ao');

      // iOS remains empty
      expect(AdConstants.iosRealBanner, isEmpty);
      expect(AdConstants.iosRealBanner2, isEmpty);
      expect(AdConstants.iosRealBanner3, isEmpty);
      expect(AdConstants.iosRealNative, isEmpty);
      expect(AdConstants.iosRealNative2, isEmpty);
      expect(AdConstants.iosRealNative3, isEmpty);
    });

    test('setRealIosAdUnitIds sets iOS IDs without affecting Android', () {
      AdManager.setRealIosAdUnitIds(
        banner: 'ios_b1',
        banner2: 'ios_b2',
        banner3: 'ios_b3',
        native: 'ios_n1',
        native2: 'ios_n2',
        native3: 'ios_n3',
        interstitial: 'ios_i',
        rewarded: 'ios_r',
        rewardedInterstitial: 'ios_ri',
        appOpen: 'ios_ao',
      );

      expect(AdConstants.iosRealBanner, 'ios_b1');
      expect(AdConstants.iosRealBanner2, 'ios_b2');
      expect(AdConstants.iosRealBanner3, 'ios_b3');
      expect(AdConstants.iosRealNative, 'ios_n1');
      expect(AdConstants.iosRealNative2, 'ios_n2');
      expect(AdConstants.iosRealNative3, 'ios_n3');
      expect(AdConstants.iosRealInterstitial, 'ios_i');
      expect(AdConstants.iosRealRewarded, 'ios_r');
      expect(AdConstants.iosRealRewardedInterstitial, 'ios_ri');
      expect(AdConstants.iosRealAppOpen, 'ios_ao');

      // Android remains empty
      expect(AdConstants.androidRealBanner, isEmpty);
      expect(AdConstants.androidRealBanner2, isEmpty);
      expect(AdConstants.androidRealBanner3, isEmpty);
      expect(AdConstants.androidRealNative, isEmpty);
      expect(AdConstants.androidRealNative2, isEmpty);
      expect(AdConstants.androidRealNative3, isEmpty);
    });

    test('setRealAndroidAds and setRealIosAds configure App ID and all units',
        () {
      AdManager.setRealAndroidAds(
        appId: 'android_app_id',
        banner: 'b1',
        banner2: 'b2',
        banner3: 'b3',
        native: 'n1',
        native2: 'n2',
        native3: 'n3',
      );

      expect(AdConstants.androidRealAppId, 'android_app_id');
      expect(AdConstants.androidRealBanner, 'b1');
      expect(AdConstants.androidRealBanner2, 'b2');
      expect(AdConstants.androidRealBanner3, 'b3');
      expect(AdConstants.androidRealNative, 'n1');
      expect(AdConstants.androidRealNative2, 'n2');
      expect(AdConstants.androidRealNative3, 'n3');

      AdManager.setRealIosAds(
        appId: 'ios_app_id',
        banner: 'ios_b1',
        banner2: 'ios_b2',
        banner3: 'ios_b3',
        native: 'ios_n1',
        native2: 'ios_n2',
        native3: 'ios_n3',
      );

      expect(AdConstants.iosRealAppId, 'ios_app_id');
      expect(AdConstants.iosRealBanner, 'ios_b1');
      expect(AdConstants.iosRealBanner2, 'ios_b2');
      expect(AdConstants.iosRealBanner3, 'ios_b3');
      expect(AdConstants.iosRealNative, 'ios_n1');
      expect(AdConstants.iosRealNative2, 'ios_n2');
      expect(AdConstants.iosRealNative3, 'ios_n3');
    });

    test(
        'Banner and Native Cascade Fallback Logic (Unit 3 -> Unit 2 -> Unit 1)',
        () {
      AdConstants.useTestAds = false;
      AdConstants.isAndroidOverride = true;

      // Scenario A: Only Unit 1 configured -> Unit 2 and Unit 3 fall back to Unit 1
      AdManager.setRealAndroidAdUnitIds(
        banner: 'b1_real',
        native: 'n1_real',
      );

      expect(AdConstants.bannerAdUnitId, 'b1_real');
      expect(AdConstants.bannerAdUnitId2, 'b1_real');
      expect(AdConstants.bannerAdUnitId3, 'b1_real');
      expect(AdConstants.getBannerAdUnitId(unitIndex: 1), 'b1_real');
      expect(AdConstants.getBannerAdUnitId(unitIndex: 2), 'b1_real');
      expect(AdConstants.getBannerAdUnitId(unitIndex: 3), 'b1_real');

      expect(AdConstants.nativeAdUnitId, 'n1_real');
      expect(AdConstants.nativeAdUnitId2, 'n1_real');
      expect(AdConstants.nativeAdUnitId3, 'n1_real');
      expect(AdConstants.getNativeAdUnitId(unitIndex: 1), 'n1_real');
      expect(AdConstants.getNativeAdUnitId(unitIndex: 2), 'n1_real');
      expect(AdConstants.getNativeAdUnitId(unitIndex: 3), 'n1_real');

      // Scenario B: Unit 1 and Unit 2 configured -> Unit 3 falls back to Unit 2
      AdManager.setRealAndroidAdUnitIds(
        banner2: 'b2_real',
        native2: 'n2_real',
      );

      expect(AdConstants.bannerAdUnitId, 'b1_real');
      expect(AdConstants.bannerAdUnitId2, 'b2_real');
      expect(AdConstants.bannerAdUnitId3, 'b2_real'); // Fallback to Unit 2!
      expect(AdConstants.getBannerAdUnitId(unitIndex: 1), 'b1_real');
      expect(AdConstants.getBannerAdUnitId(unitIndex: 2), 'b2_real');
      expect(AdConstants.getBannerAdUnitId(unitIndex: 3), 'b2_real');

      expect(AdConstants.nativeAdUnitId, 'n1_real');
      expect(AdConstants.nativeAdUnitId2, 'n2_real');
      expect(AdConstants.nativeAdUnitId3, 'n2_real'); // Fallback to Unit 2!
      expect(AdConstants.getNativeAdUnitId(unitIndex: 1), 'n1_real');
      expect(AdConstants.getNativeAdUnitId(unitIndex: 2), 'n2_real');
      expect(AdConstants.getNativeAdUnitId(unitIndex: 3), 'n2_real');

      // Scenario C: All three configured -> each returns its own distinct unit
      AdManager.setRealAndroidAdUnitIds(
        banner3: 'b3_real',
        native3: 'n3_real',
      );

      expect(AdConstants.bannerAdUnitId, 'b1_real');
      expect(AdConstants.bannerAdUnitId2, 'b2_real');
      expect(AdConstants.bannerAdUnitId3, 'b3_real');
      expect(AdConstants.getBannerAdUnitId(unitIndex: 1), 'b1_real');
      expect(AdConstants.getBannerAdUnitId(unitIndex: 2), 'b2_real');
      expect(AdConstants.getBannerAdUnitId(unitIndex: 3), 'b3_real');

      expect(AdConstants.nativeAdUnitId, 'n1_real');
      expect(AdConstants.nativeAdUnitId2, 'n2_real');
      expect(AdConstants.nativeAdUnitId3, 'n3_real');
      expect(AdConstants.getNativeAdUnitId(unitIndex: 1), 'n1_real');
      expect(AdConstants.getNativeAdUnitId(unitIndex: 2), 'n2_real');
      expect(AdConstants.getNativeAdUnitId(unitIndex: 3), 'n3_real');

      // Scenario D: iOS Cascade Verification
      AdConstants.isAndroidOverride = false;
      AdConstants.isIosOverride = true;
      AdManager.setRealIosAdUnitIds(
        banner: 'ios_b1',
        native: 'ios_n1',
      );
      expect(AdConstants.bannerAdUnitId, 'ios_b1');
      expect(AdConstants.bannerAdUnitId2, 'ios_b1');
      expect(AdConstants.bannerAdUnitId3, 'ios_b1');
      expect(AdConstants.nativeAdUnitId, 'ios_n1');
      expect(AdConstants.nativeAdUnitId2, 'ios_n1');
      expect(AdConstants.nativeAdUnitId3, 'ios_n1');

      AdManager.setRealIosAdUnitIds(
        banner2: 'ios_b2',
        native2: 'ios_n2',
      );
      expect(AdConstants.bannerAdUnitId2, 'ios_b2');
      expect(AdConstants.bannerAdUnitId3, 'ios_b2'); // Fallback to unit 2
      expect(AdConstants.nativeAdUnitId2, 'ios_n2');
      expect(AdConstants.nativeAdUnitId3, 'ios_n2'); // Fallback to unit 2
    });

    test('SmartBannerAdView factory constructors set correct adUnitIndex', () {
      const banner1 = SmartBannerAdView();
      expect(banner1.adUnitIndex, 1);

      final banner2 = SmartBannerAdView.withAdUnitId2();
      expect(banner2.adUnitIndex, 2);

      final banner3 = SmartBannerAdView.withAdUnitId3();
      expect(banner3.adUnitIndex, 3);
    });

    test('SmartNativeAdView factory constructors set correct adUnitIndex', () {
      const native1 = SmartNativeAdView();
      expect(native1.adUnitIndex, 1);

      final native2 = SmartNativeAdView.withAdUnitId2();
      expect(native2.adUnitIndex, 2);

      final native3 = SmartNativeAdView.withAdUnitId3();
      expect(native3.adUnitIndex, 3);
    });
  });
}

class TestNetworkInfo implements NetworkInfo {
  TestNetworkInfo({this.initialConnected = true});

  final bool initialConnected;
  int isConnectedCallCount = 0;
  int onStatusChangeListenCount = 0;
  final StreamController<InternetStatus> _controller =
      StreamController<InternetStatus>.broadcast();

  @override
  Future<bool> get isConnected {
    isConnectedCallCount++;
    return Future.value(initialConnected);
  }

  @override
  Stream<InternetStatus> get onStatusChange {
    onStatusChangeListenCount++;
    return _controller.stream;
  }

  void emitStatus(InternetStatus status) {
    _controller.add(status);
  }

  void dispose() {
    _controller.close();
  }
}
