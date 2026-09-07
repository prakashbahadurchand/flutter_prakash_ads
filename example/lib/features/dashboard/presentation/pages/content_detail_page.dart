import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prakash_ads/fp_ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/ads/cubit/ads_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../domain/models/article_item.dart';

/// Content Detail Page - Compliant with Google AdMob Policies.
///
/// Policy Highlights:
/// - Rewarded Ad for Premium Content: User explicitly chooses to watch a video to unlock bonus insights.
/// - Below-the-fold Medium Rectangle Ad: Placed naturally after the article body to avoid misclicks.
@RoutePage()
class ContentDetailPage extends StatefulWidget {
  const ContentDetailPage({super.key, required this.article});

  final ArticleItem article;

  @override
  State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage> {
  final AdsService _adsService = getIt<AdsService>();
  bool _isBonusUnlocked = false;

  @override
  void initState() {
    super.initState();
    // Preload rewarded video ad
    _adsService.loadRewardedAd();
  }

  void _onUnlockBonusTapped() {
    if (_adsService.isRewardedAdAvailable) {
      _adsService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          final amount = reward.amount.toInt() == 0
              ? 50
              : reward.amount.toInt();
          getIt<AdsCubit>().userEarnedReward(amount);
          setState(() {
            _isBonusUnlocked = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Bonus Insights Unlocked! (+$amount Coins)'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rewarded video is loading, please try again in a few seconds...',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _adsService.loadRewardedAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final article = widget.article;

    return Scaffold(
      appBar: AppBar(title: Text(article.category), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Category & Read Time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  article.category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                article.readTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            article.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Article Body
          Text(
            article.fullContent,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),

          // 🎁 Rewarded Ad Section (Value Exchange)
          Card(
            color: _isBonusUnlocked
                ? Colors.green.shade50
                : theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: _isBonusUnlocked
                    ? Colors.green.shade300
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isBonusUnlocked
                            ? Icons.check_circle_rounded
                            : Icons.lock_outline_rounded,
                        color: _isBonusUnlocked
                            ? Colors.green.shade700
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Expert Bonus Insights',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _isBonusUnlocked
                              ? Colors.green.shade900
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_isBonusUnlocked)
                    Text(
                      article.bonusInsights,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.green.shade900,
                      ),
                    )
                  else ...[
                    Text(
                      'Watch a short rewarded sponsor video to unlock exclusive architectural analysis and pro insights.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.play_circle_outline_rounded),
                        label: const Text('Watch Video to Unlock'),
                        onPressed: _onUnlockBonusTapped,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 🛡️ Policy-Compliant Below-the-fold Ad Placement (Medium Rectangle 300x250)
          const Text(
            'SPONSORED',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: SmartBannerAdView(adSize: AdSize.mediumRectangle),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
