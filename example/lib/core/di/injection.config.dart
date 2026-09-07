// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_prakash_ads/fp_ads.dart' as _i499;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as _i161;

import '../../features/dashboard/presentation/cubit/favorites_cubit.dart'
    as _i545;
import '../ads/cubit/ads_cubit.dart' as _i168;
import '../network/network_module.dart' as _i200;
import '../router/app_router.dart' as _i81;
import '../theme/theme_cubit.dart' as _i611;
import 'ads_module.dart' as _i357;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final adsModule = _$AdsModule();
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i499.AdsService>(() => adsModule.provideAdsService());
    gh.lazySingleton<_i499.AppOpenAdManager>(
      () => adsModule.provideAppOpenAdManager(),
    );
    gh.lazySingleton<_i161.InternetConnection>(
      () => networkModule.provideInternetConnection(),
    );
    gh.lazySingleton<_i499.NetworkInfo>(
      () => networkModule.provideNetworkInfo(),
    );
    gh.lazySingleton<_i361.Dio>(() => networkModule.provideDio());
    gh.lazySingleton<_i611.ThemeCubit>(() => _i611.ThemeCubit());
    gh.lazySingleton<_i81.AppRouter>(() => _i81.AppRouter());
    gh.lazySingleton<_i545.FavoritesCubit>(() => _i545.FavoritesCubit());
    gh.lazySingleton<_i168.AdsCubit>(
      () => _i168.AdsCubit(adsService: gh<_i499.AdsService>()),
    );
    return this;
  }
}

class _$AdsModule extends _i357.AdsModule {}

class _$NetworkModule extends _i200.NetworkModule {}
