import 'package:flutter_prakash_ads/flutter_prakash_ads.dart';
import 'package:injectable/injectable.dart';

@module
abstract class AdsModule {
  @lazySingleton
  AdsService provideAdsService() => AdsServiceImpl();

  @lazySingleton
  AppOpenAdManager provideAppOpenAdManager() => AppOpenAdManager.instance;
}
