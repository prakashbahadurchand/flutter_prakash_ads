import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/ads/cubit/ads_cubit.dart';
import 'core/ads/my_ads_service.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_cubit.dart';
import 'core/utils/console_logger.dart';
import 'features/dashboard/presentation/cubit/favorites_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Print Clean App Startup Banner
  ConsoleLogger.startupBanner(
    appName: 'AdsDemo',
    version: '1.0.0',
    environment: 'Development',
  );

  // 1. Initialize Dependency Injection (GetIt & Injectable)
  ConsoleLogger.info('Bootstrapping Dependency Injection graph...', tag: 'DI');
  await configureDependencies();
  ConsoleLogger.success('Dependency Injection ready.', tag: 'DI');

  // 2. Initialize Ads & Consent flow
  await MyAdsService.initFromMain();

  runApp(const AdsDemoApp());
}

class AdsDemoApp extends StatelessWidget {
  const AdsDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => getIt<ThemeCubit>()),
        BlocProvider<AdsCubit>(create: (_) => getIt<AdsCubit>()),
        BlocProvider<FavoritesCubit>(create: (_) => getIt<FavoritesCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Google Mobile Ads Clean Architecture Demo',
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter.config(),
            themeMode: themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6750A4),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFD0BCFF),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
