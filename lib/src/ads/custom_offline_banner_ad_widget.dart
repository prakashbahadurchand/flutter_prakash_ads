import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_event.dart';
import 'ads_manager.dart';
import 'custom_ad_model.dart';

/// A compliant fallback banner ad shown when there is no internet connection or as a house ad.
///
/// Complies with Google AdMob & Google Play policies:
/// - Prominently labeled with "AD" / "Advertisement" or "Sponsored"
/// - Visually distinct from organic content
/// - Exact dimensional constraints preventing layout shifts (CLS)
class CustomOfflineBannerAdWidget extends StatelessWidget {
  const CustomOfflineBannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.customAd,
    this.title = 'Featured App Spotlight',
    this.subtitle = 'Explore premium features offline',
    this.onTap,
  });

  final AdSize adSize;
  final CustomAdModel? customAd;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = adSize.width.toDouble();
    final height = adSize.height.toDouble();

    final activeAd = customAd ?? AdsManager.getCustomAd();
    final effectiveTitle = activeAd?.title ?? title;
    final effectiveSubtitle = activeAd?.description ?? subtitle;
    final effectiveCta = activeAd?.callToAction ?? 'View';
    final effectiveImageUrl = activeAd?.imageUrl;

    final isSmallBanner = height <= 60;

    void handleTap() {
      AdsManager.emitAdEvent(
        AdEvent(
          format: AdFormat.banner,
          type: AdEventType.clicked,
          extras: {
            'isCustomAd': true,
            if (activeAd?.id != null) 'id': activeAd!.id
          },
        ),
      );
      activeAd?.onTap?.call();
      if (activeAd != null) {
        AdsManager.onCustomAdClicked?.call(activeAd);
      }
      onTap?.call();
    }

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: isSmallBanner ? 6.0 : 12.0,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: isSmallBanner
          ? Row(
              children: [
                // Ad Badge (Required by AdMob/Play policy)
                _buildAdBadge(theme),
                const SizedBox(width: 8),
                // Icon / Image
                _buildLeadingImage(theme, effectiveImageUrl,
                    size: 34, iconSize: 20),
                const SizedBox(width: 10),
                // Text info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        effectiveTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        effectiveSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Action
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: handleTap,
                  child:
                      Text(effectiveCta, style: const TextStyle(fontSize: 11)),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAdBadge(theme),
                    const Spacer(),
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    _buildLeadingImage(theme, effectiveImageUrl,
                        size: 56, iconSize: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            effectiveTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            effectiveSubtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 36),
                    ),
                    onPressed: handleTap,
                    child: Text(effectiveCta),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLeadingImage(
    ThemeData theme,
    String? imageUrl, {
    required double size,
    required double iconSize,
  }) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final isNetwork =
          imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: size,
          height: size,
          color: theme.colorScheme.primaryContainer,
          child: isNetwork
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackIcon(theme, iconSize),
                )
              : Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackIcon(theme, iconSize),
                ),
        ),
      );
    }
    return _fallbackIcon(theme, iconSize, containerSize: size);
  }

  Widget _fallbackIcon(ThemeData theme, double iconSize,
      {double? containerSize}) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.offline_bolt_rounded,
        color: theme.colorScheme.primary,
        size: iconSize,
      ),
    );
  }

  Widget _buildAdBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: Colors.amber.shade700,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'AD',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
