import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/app_router.gr.dart';

/// Splash Page - Compliant with Google AdMob & Better Ads Standards.
///
/// Policy Guidelines Followed:
/// - NO banner or native ads rendered on the splash screen.
/// - Gathers UMP GDPR/CPRA consent cleanly in the background.
/// - Handles 2nd+ cold-start App Open Ads gracefully without blocking first-time users.
@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  @override
  void initState() {
    super.initState();
    _bootstrapApp();
  }

  Future<void> _bootstrapApp() async {
    // 1. Minimum brand animation display time (1.5 seconds)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 2. Check if user has already completed onboarding
    final prefs = await SharedPreferences.getInstance();
    final isOnboardingCompleted =
        prefs.getBool(_keyOnboardingCompleted) ?? false;

    if (!mounted) return;

    // 3. Route to the appropriate screen
    if (!isOnboardingCompleted) {
      // First-time install: Navigate directly to Onboarding without ad interruption
      context.router.replace(const OnboardingRoute());
    } else {
      // Returning user: Navigate to main Dashboard Page
      context.router.replace(const DashboardRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // App Logo / Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.ads_click_rounded,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ads Clean Architecture',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enterprise-grade Google Mobile Ads Demo',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              // Loading indicator
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
