import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ads/flutter_ads.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../domain/models/article_item.dart';
import '../cubit/favorites_cubit.dart';

/// Home Tab — Article feed with inline native ads and a sticky bottom banner.
///
/// AdMob Policy Compliance:
/// - Sticky banner sits **outside** the scrollview (prevents accidental clicks / CLS).
/// - Inline native ads are placed at natural spacing (every 4th item) with clear "AD" badges.
/// - Interstitial ads are preloaded and triggered with 30s interval throttling on article taps.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  final AdsService _adsService = getIt<AdsService>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _adsService.loadInterstitialAd();
  }

  void _onArticleTapped(ArticleItem article) {
    if (_adsService.isInterstitialAdAvailable) {
      _adsService.showInterstitialAd(
        onAdDismissedFullScreenContent: () {
          if (mounted) {
            context.router.push(ContentDetailRoute(article: article));
          }
        },
        onAdFailedToShowFullScreenContent: (error) {
          if (mounted) {
            context.router.push(ContentDetailRoute(article: article));
          }
        },
      );
    } else {
      context.router.push(ContentDetailRoute(article: article));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: sampleArticles.length + 2,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              // Inline Small Native Ad at position 2
              if (index == 2) {
                return Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SmartNativeAdView(
                      templateType: TemplateType.small,
                      cornerRadius: 12.0,
                    ),
                  ),
                );
              }
              // Inline Medium Native Ad at position 6
              if (index == 6) {
                return Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SmartNativeAdView(
                      templateType: TemplateType.medium,
                      cornerRadius: 12.0,
                    ),
                  ),
                );
              }

              int articleIndex = index;
              if (index > 6) {
                articleIndex -= 2;
              } else if (index > 2) {
                articleIndex -= 1;
              }
              if (articleIndex >= sampleArticles.length) {
                return const SizedBox.shrink();
              }

              final article = sampleArticles[articleIndex];

              return Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _onArticleTapped(article),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                article.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              article.readTime,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(width: 8),
                            BlocBuilder<FavoritesCubit, List<ArticleItem>>(
                              builder: (context, favorites) {
                                final isFav = favorites.any(
                                  (a) => a.id == article.id,
                                );
                                return GestureDetector(
                                  onTap: () {
                                    context
                                        .read<FavoritesCubit>()
                                        .toggleFavorite(article);
                                  },
                                  child: Icon(
                                    isFav
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isFav
                                        ? Colors.redAccent
                                        : theme.colorScheme.outline,
                                    size: 20,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          article.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          article.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Read Article',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Sticky Bottom Banner — outside scroll view (Policy CLS prevention)
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: const SafeArea(
            top: false,
            child: Center(child: SmartBannerAdView(adSize: AdSize.banner)),
          ),
        ),
      ],
    );
  }
}
