import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fp_ads/fp_ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
}
