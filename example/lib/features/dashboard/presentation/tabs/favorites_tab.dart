import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prakash_ads/fp_ads.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../domain/models/article_item.dart';
import '../cubit/favorites_cubit.dart';

/// Favorites Tab — Lists saved articles with tap navigation and remove action.
class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  void _onArticleTapped(BuildContext context, ArticleItem article) {
    final adsService = getIt<AdsService>();
    if (adsService.isInterstitialAdAvailable) {
      adsService.showInterstitialAd(
        onAdDismissedFullScreenContent: () {
          if (context.mounted) {
            context.router.push(ContentDetailRoute(article: article));
          }
        },
        onAdFailedToShowFullScreenContent: (error) {
          if (context.mounted) {
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
    final theme = Theme.of(context);

    return BlocBuilder<FavoritesCubit, List<ArticleItem>>(
      builder: (context, favorites) {
        if (favorites.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Favorites Saved',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the ♡ on any article in the Home feed to save it here for quick offline reference.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: favorites.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final article = favorites[index];

            return Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _onArticleTapped(context, article),
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
                          IconButton(
                            icon: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () {
                              context.read<FavoritesCubit>().toggleFavorite(
                                article,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
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
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
