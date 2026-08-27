import 'package:flutter_ads/flutter_ads.dart';
import 'package:injectable/injectable.dart';

@module
abstract class AdsModule {
  @lazySingleton
  AdsService provideAdsService() => AdsServiceImpl();

  @lazySingleton
  AppOpenAdManager provideAppOpenAdManager() => AppOpenAdManager.instance;
}
