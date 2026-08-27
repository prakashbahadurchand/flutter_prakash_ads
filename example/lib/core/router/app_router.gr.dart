// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:adsdemo/features/dashboard/domain/models/article_item.dart'
    as _i8;
import 'package:adsdemo/features/dashboard/presentation/pages/ads_demo_page.dart'
    as _i1;
import 'package:adsdemo/features/dashboard/presentation/pages/content_detail_page.dart'
    as _i2;
import 'package:adsdemo/features/dashboard/presentation/pages/dashboard_page.dart'
    as _i3;
import 'package:adsdemo/features/onboarding/presentation/pages/onboarding_page.dart'
    as _i4;
import 'package:adsdemo/features/splash/presentation/pages/splash_page.dart'
    as _i5;
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:flutter/material.dart' as _i7;

/// generated route for
/// [_i1.AdsDemoPage]
class AdsDemoRoute extends _i6.PageRouteInfo<void> {
  const AdsDemoRoute({List<_i6.PageRouteInfo>? children})
    : super(AdsDemoRoute.name, initialChildren: children);

  static const String name = 'AdsDemoRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i1.AdsDemoPage();
    },
  );
}

/// generated route for
/// [_i2.ContentDetailPage]
class ContentDetailRoute extends _i6.PageRouteInfo<ContentDetailRouteArgs> {
  ContentDetailRoute({
    _i7.Key? key,
    required _i8.ArticleItem article,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         ContentDetailRoute.name,
         args: ContentDetailRouteArgs(key: key, article: article),
         initialChildren: children,
       );

  static const String name = 'ContentDetailRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ContentDetailRouteArgs>();
      return _i2.ContentDetailPage(key: args.key, article: args.article);
    },
  );
}

class ContentDetailRouteArgs {
  const ContentDetailRouteArgs({this.key, required this.article});

  final _i7.Key? key;

  final _i8.ArticleItem article;

  @override
  String toString() {
    return 'ContentDetailRouteArgs{key: $key, article: $article}';
  }
}

/// generated route for
/// [_i3.DashboardPage]
class DashboardRoute extends _i6.PageRouteInfo<void> {
  const DashboardRoute({List<_i6.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i3.DashboardPage();
    },
  );
}

/// generated route for
/// [_i4.OnboardingPage]
class OnboardingRoute extends _i6.PageRouteInfo<void> {
  const OnboardingRoute({List<_i6.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i4.OnboardingPage();
    },
  );
}

/// generated route for
/// [_i5.SplashPage]
class SplashRoute extends _i6.PageRouteInfo<void> {
  const SplashRoute({List<_i6.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i5.SplashPage();
    },
  );
}
