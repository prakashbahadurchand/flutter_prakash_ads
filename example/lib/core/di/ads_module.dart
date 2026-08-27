import 'package:fp_ads/fp_ads.dart';
import 'package:injectable/injectable.dart';

@module
abstract class AdsModule {
  @lazySingleton
  AdsService provideAdsService() => AdsServiceImpl();

  @lazySingleton
  AppOpenAdManager provideAppOpenAdManager() => AppOpenAdManager.instance;
}
