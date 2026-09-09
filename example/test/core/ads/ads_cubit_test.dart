import 'package:adsdemo/core/ads/cubit/ads_cubit.dart';
import 'package:adsdemo/core/ads/cubit/ads_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_prakash_ads/flutter_prakash_ads.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake implementation of [AdsService] for isolated unit testing.
class FakeAdsService implements AdsService {
  bool isInterstitialAvailable = false;
  bool isRewardedAvailable = false;
  bool isRewardedInterstitialAvailable = false;
  bool isAppOpenAvailable = false;

  bool loadAllAdsCalled = false;
  bool loadInterstitialCalled = false;
  bool showInterstitialCalled = false;
  bool loadRewardedCalled = false;
  bool showRewardedCalled = false;
  bool disposed = false;

  @override
  bool get isInterstitialAdAvailable => isInterstitialAvailable;

  @override
  bool get isRewardedAdAvailable => isRewardedAvailable;

  @override
  bool get isRewardedInterstitialAdAvailable => isRewardedInterstitialAvailable;

  @override
  bool get isAppOpenAdAvailable => isAppOpenAvailable;

  @override
  void loadAllAds() {
    loadAllAdsCalled = true;
  }

  @override
  void loadInterstitialAd({
    String? adUnitId,
    AdRequest? request,
    VoidCallback? onLoaded,
    Function(LoadAdError error)? onFailedToLoad,
  }) {
    loadInterstitialCalled = true;
    onLoaded?.call();
  }

  @override
  void showInterstitialAd({
    VoidCallback? onAdShowedFullScreenContent,
    VoidCallback? onAdDismissedFullScreenContent,
    Function(AdError error)? onAdFailedToShowFullScreenContent,
    VoidCallback? onAdClicked,
    VoidCallback? onAdImpression,
    OnPaidEventCallback? onPaidEvent,
  }) {
    showInterstitialCalled = true;
    onAdShowedFullScreenContent?.call();
    onAdDismissedFullScreenContent?.call();
  }

  @override
  void loadRewardedAd({
    String? adUnitId,
    AdRequest? request,
    VoidCallback? onLoaded,
    Function(LoadAdError error)? onFailedToLoad,
  }) {
    loadRewardedCalled = true;
    onLoaded?.call();
  }

  @override
  void showRewardedAd({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    VoidCallback? onAdShowedFullScreenContent,
    VoidCallback? onAdDismissedFullScreenContent,
    Function(AdError error)? onAdFailedToShowFullScreenContent,
    VoidCallback? onAdClicked,
    VoidCallback? onAdImpression,
    OnPaidEventCallback? onPaidEvent,
    ServerSideVerificationOptions? serverSideVerificationOptions,
  }) {
    showRewardedCalled = true;
    onUserEarnedReward.call(null as dynamic, RewardItem(50, 'Coins'));
  }

  @override
  void loadRewardedInterstitialAd({
    String? adUnitId,
    AdRequest? request,
    VoidCallback? onLoaded,
    Function(LoadAdError error)? onFailedToLoad,
  }) {}

  @override
  void showRewardedInterstitialAd({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    VoidCallback? onAdShowedFullScreenContent,
    VoidCallback? onAdDismissedFullScreenContent,
    Function(AdError error)? onAdFailedToShowFullScreenContent,
    VoidCallback? onAdClicked,
    VoidCallback? onAdImpression,
    OnPaidEventCallback? onPaidEvent,
    ServerSideVerificationOptions? serverSideVerificationOptions,
  }) {}

  @override
  void loadAppOpenAd({
    String? adUnitId,
    AdRequest? request,
    VoidCallback? onLoaded,
    Function(LoadAdError error)? onFailedToLoad,
  }) {}

  @override
  void showAppOpenAdIfAvailable({
    VoidCallback? onAdShowedFullScreenContent,
    VoidCallback? onAdDismissedFullScreenContent,
    Function(AdError error)? onAdFailedToShowFullScreenContent,
    OnPaidEventCallback? onPaidEvent,
  }) {}

  @override
  void dispose() {
    disposed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeAdsService fakeAdsService;
  late AdsCubit adsCubit;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakeAdsService = FakeAdsService();
    adsCubit = AdsCubit(adsService: fakeAdsService);
  });

  tearDown(() {
    adsCubit.close();
  });

  group('AdsCubit Unit Tests', () {
    test('initial state has 0 coins and default status message', () {
      expect(adsCubit.state, const AdsState());
      expect(adsCubit.state.coins, 0);
    });

    test('userEarnedReward increments coin balance', () async {
      final expectation = expectLater(
        adsCubit.stream,
        emits(
          predicate<AdsState>(
            (state) =>
                state.coins == 50 &&
                state.isSuccessMessage == true &&
                state.snackBarMessage != null,
          ),
        ),
      );

      adsCubit.userEarnedReward(50);
      await expectation;
      expect(adsCubit.state.coins, 50);
    });

    test(
      'updateAdStatus updates state status and availability flags',
      () async {
        fakeAdsService.isInterstitialAvailable = true;
        final expectation = expectLater(
          adsCubit.stream,
          emits(
            predicate<AdsState>(
              (state) =>
                  state.statusMessage == 'Interstitial Ready' &&
                  state.isInterstitialLoaded == true,
            ),
          ),
        );

        adsCubit.updateAdStatus('Interstitial Ready');
        await expectation;
        expect(adsCubit.state.isInterstitialLoaded, true);
      },
    );

    test('showInterstitialAd calls AdsService when ad is available', () async {
      fakeAdsService.isInterstitialAvailable = true;

      final expectation = expectLater(
        adsCubit.stream,
        emitsInOrder([
          predicate<AdsState>(
            (state) => state.statusMessage == 'Interstitial Ad Displayed',
          ),
          predicate<AdsState>(
            (state) => state.statusMessage == 'Interstitial Ad Dismissed',
          ),
        ]),
      );

      adsCubit.showInterstitialAd();
      await expectation;

      expect(fakeAdsService.showInterstitialCalled, true);
    });
  });
}
