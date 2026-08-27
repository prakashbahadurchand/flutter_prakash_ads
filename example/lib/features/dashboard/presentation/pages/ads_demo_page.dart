import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ads/flutter_ads.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/ads/cubit/ads_cubit.dart';
import '../../../../core/ads/cubit/ads_state.dart';
import '../../../../core/di/injection.dart';

@RoutePage()
class AdsDemoPage extends StatelessWidget {
  const AdsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AdsCubit>()..loadAllAds(),
      child: const AdsDemoView(),
    );
  }
}

class AdsDemoView extends StatelessWidget {
  const AdsDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AdsCubit, AdsState>(
      listenWhen: (previous, current) =>
          current.snackBarMessage != null &&
          current.snackBarMessage != previous.snackBarMessage,
      listener: (context, state) {
        if (state.snackBarMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.snackBarMessage!),
              backgroundColor: state.isSuccessMessage
                  ? Colors.green.shade700
                  : Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AdsCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Google Mobile Ads Demo'),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${state.coins}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Status Card
              Card(
                color: theme.colorScheme.secondaryContainer.withValues(
                  alpha: 0.4,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.statusMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 1. App Open Ad Section
              _buildSectionHeader(context, '1. App Open Ad', Icons.open_in_new),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Open ads display on opening or returning to the app from background.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => cubit.showAppOpenAd(),
                          icon: const Icon(Icons.fullscreen),
                          label: const Text('Show App Open Ad'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Interstitial Ad Section
              _buildSectionHeader(
                context,
                '2. Interstitial Ad',
                Icons.aspect_ratio,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Full-screen ads that display at natural transition points.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: () => cubit.showInterstitialAd(),
                          icon: const Icon(Icons.slideshow),
                          label: const Text('Show Interstitial Ad'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Rewarded Video Ad Section
              _buildSectionHeader(
                context,
                '3. Rewarded Video Ad',
                Icons.video_library,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Users watch a video ad in exchange for in-app items (e.g. +50 Coins).',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => cubit.showRewardedAd(),
                          icon: const Icon(Icons.card_giftcard),
                          label: const Text('Watch Video for 50 Coins'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Rewarded Interstitial Ad Section
              _buildSectionHeader(
                context,
                '4. Rewarded Interstitial Ad',
                Icons.workspace_premium,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Non-interruptive reward experience (+100 Coins).',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => cubit.showRewardedInterstitialAd(),
                          icon: const Icon(Icons.stars),
                          label: const Text('Show Rewarded Interstitial'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Native Ad Section
              _buildSectionHeader(
                context,
                '5. Native Ad (SmartNativeAdView - Medium)',
                Icons.featured_play_list,
              ),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SmartNativeAdView(templateType: TemplateType.medium),
                ),
              ),
              const SizedBox(height: 16),

              // 6. Standard Banner Ad
              _buildSectionHeader(
                context,
                '6. Standard Banner (SmartBannerAdView - 320x50)',
                Icons.view_stream,
              ),
              const Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: SmartBannerAdView(adSize: AdSize.banner),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 7. Medium Rectangle
              _buildSectionHeader(
                context,
                '7. Medium Rectangle (SmartBannerAdView - 300x250)',
                Icons.dashboard,
              ),
              const Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: SmartBannerAdView(adSize: AdSize.mediumRectangle),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
