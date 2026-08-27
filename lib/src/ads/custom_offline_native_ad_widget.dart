import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_event.dart';
import 'ads_manager.dart';
import 'custom_ad_model.dart';

/// A compliant fallback Native Ad shown when the device is offline or for custom house campaigns.
///
/// Fully aligned with Google AdMob Native Ad Policies:
/// - Distinct and clear "AD" attribution badge in contrasting color
/// - Clear separation between ad content and organic app UI
/// - Well-defined Call-To-Action button with clear target
/// - Matches standard TemplateType sizing (Small: ~90px, Medium: ~350px)
class CustomOfflineNativeAdWidget extends StatelessWidget {
  const CustomOfflineNativeAdWidget({
    super.key,
    this.templateType = TemplateType.medium,
    this.customAd,
    this.headline = 'Upgrade to Offline Pro',
    this.body =
        'Enjoy uninterrupted features, offline caching, premium analytics, and extra benefits.',
    this.callToAction = 'Install Now',
    this.advertiser = 'Sponsored Partner',
    this.cornerRadius = 12.0,
    this.onTap,
  });

  final TemplateType templateType;
  final CustomAdModel? customAd;
  final String headline;
  final String body;
  final String callToAction;
  final String advertiser;
  final double cornerRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmall = templateType == TemplateType.small;
    final height = isSmall ? 90.0 : 350.0;

    final activeAd = customAd ?? AdsManager.getCustomAd();
    final effectiveHeadline = activeAd?.title ?? headline;
    final effectiveBody = activeAd?.description ?? body;
    final effectiveCta = activeAd?.callToAction ?? callToAction;
    final effectiveAdvertiser = activeAd?.advertiser ?? advertiser;
    final effectiveImageUrl = activeAd?.imageUrl;
    final effectiveRating = activeAd?.rating ?? 4.9;

    void handleTap() {
      AdsManager.emitAdEvent(
        AdEvent(
          format: AdFormat.native,
          type: AdEventType.clicked,
          extras: {
            'isCustomAd': true,
            if (activeAd?.id != null) 'id': activeAd!.id,
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
      height: height,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(cornerRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isSmall
          ? _buildSmallLayout(
              theme,
              headline: effectiveHeadline,
              advertiser: effectiveAdvertiser,
              cta: effectiveCta,
              imageUrl: effectiveImageUrl,
              onTap: handleTap,
            )
          : _buildMediumLayout(
              theme,
              headline: effectiveHeadline,
              body: effectiveBody,
              advertiser: effectiveAdvertiser,
              cta: effectiveCta,
              imageUrl: effectiveImageUrl,
              rating: effectiveRating,
              onTap: handleTap,
            ),
    );
  }

  Widget _buildSmallLayout(
    ThemeData theme, {
    required String headline,
    required String advertiser,
    required String cta,
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        // App Icon
        _buildImageOrIcon(theme, imageUrl, size: 56, icon: Icons.star_rounded),
        const SizedBox(width: 12),
        // Headline & Advertiser
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  _buildAdBadge(),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      advertiser,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                headline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // CTA
        FilledButton(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            minimumSize: const Size(0, 36),
          ),
          onPressed: onTap,
          child: Text(cta, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildMediumLayout(
    ThemeData theme, {
    required String headline,
    required String body,
    required String advertiser,
    required String cta,
    required String? imageUrl,
    required double rating,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with AD Badge and Advertiser
        Row(
          children: [
            _buildAdBadge(),
            const SizedBox(width: 8),
            Text(
              advertiser,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.info_outline,
              size: 16,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
        const SizedBox(height: 10),

        // App Icon, Headline & Rating
        Row(
          children: [
            _buildImageOrIcon(theme, imageUrl,
                size: 48, icon: Icons.rocket_launch_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$rating (12.4k)',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Media View Area (Creative Card)
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                  theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.offline_pin_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    body,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Call to action button
        SizedBox(
          width: double.infinity,
          height: 44,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onTap,
            child: Text(
              cta,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageOrIcon(
    ThemeData theme,
    String? imageUrl, {
    required double size,
    required IconData icon,
  }) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final isNetwork =
          imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: size,
          height: size,
          color: theme.colorScheme.primaryContainer,
          child: isNetwork
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackIcon(theme, size, icon),
                )
              : Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackIcon(theme, size, icon),
                ),
        ),
      );
    }
    return _fallbackIcon(theme, size, icon);
  }

  Widget _fallbackIcon(ThemeData theme, double size, IconData icon) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: theme.colorScheme.primary,
        size: size * 0.55,
      ),
    );
  }

  Widget _buildAdBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.shade700,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'AD',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
