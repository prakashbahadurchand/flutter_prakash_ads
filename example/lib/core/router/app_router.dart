import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'app_router.gr.dart';

@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: OnboardingRoute.page),
    AutoRoute(page: DashboardRoute.page),
    AutoRoute(page: ContentDetailRoute.page),
    AutoRoute(page: AdsDemoRoute.page),
  ];
}
