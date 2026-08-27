/// Simple domain model representing an article or feed item.
class ArticleItem {
  const ArticleItem({
    required this.id,
    required this.title,
    required this.category,
    required this.readTime,
    required this.summary,
    required this.fullContent,
    required this.bonusInsights,
  });

  final String id;
  final String title;
  final String category;
  final String readTime;
  final String summary;
  final String fullContent;
  final String bonusInsights;
}

/// Sample article dataset for realistic list and detail presentation.
final List<ArticleItem> sampleArticles = [
  const ArticleItem(
    id: '1',
    title: 'Mastering Google Mobile Ads Clean Architecture in Flutter',
    category: 'Architecture',
    readTime: '5 min read',
    summary:
        'Learn how to decouple ad SDKs from UI screens using BLoC, Injectable, and standard repository patterns.',
    fullContent:
        'Building scalable mobile applications requires separating commercial third-party SDKs from your domain business logic. '
        'By centralizing ad initializations, consent flows, and full-screen coordinators in a dedicated core module, '
        'features can remain clean, highly testable, and completely agnostic of underlying ad network implementations.\n\n'
        'Key best practices include managing lifecycle events, evicting stale cached ads after 4 hours, '
        'and enforcing rigid container bounds to eliminate Cumulative Layout Shift (CLS).',
    bonusInsights:
        '🏆 Bonus Insights Unlocked: Using automated dependency injection with GetIt ensures that your test suites can mock ad services with zero overhead. Always test with official test ad unit IDs in CI/CD pipelines!',
  ),
  const ArticleItem(
    id: '2',
    title:
        'Understanding Google Play Better Ads Standards for Full-Screen Formats',
    category: 'Policy & Compliance',
    readTime: '4 min read',
    summary:
        'A comprehensive guide to avoiding unexpected interstitial popups, cold-start violations, and accidental clicks.',
    fullContent:
        'Google Play and the Coalition for Better Ads have strict standards for full-screen ads. '
        'Interstitial ads must only display during natural transition points, such as completing a level or tapping to view details. '
        'Never trigger an interstitial immediately upon opening an app if the user has not interacted with content.\n\n'
        'For App Open ads, always preserve the first-launch onboarding experience and enforce a reasonable background threshold (e.g. 15s) on app resume.',
    bonusInsights:
        '🏆 Bonus Insights Unlocked: AdMob policy audits frequently flag apps that trigger interstitial ads during splash exits. Always use deadline timers (e.g. 4 seconds) to ensure slow ads do not interrupt active user interactions.',
  ),
  const ArticleItem(
    id: '3',
    title: 'Implementing GDPR, CPRA, & TCF v2.2 with Google UMP',
    category: 'Privacy',
    readTime: '6 min read',
    summary:
        'Step-by-step implementation of User Messaging Platform consent forms before initializing Mobile Ads.',
    fullContent:
        'Privacy compliance in the European Economic Area (EEA) and the UK requires gathering verifiable user consent before requesting ads. '
        'The User Messaging Platform (UMP) SDK handles TCF v2.2 strings, CMP requirements, and consent form rendering.\n\n'
        'The consent form must be queried on every app cold start, and SDK initialization must be guarded until consent is verified.',
    bonusInsights:
        '🏆 Bonus Insights Unlocked: Test your GDPR consent flows using ConsentDebugSettings with debug geography set to DebugGeography.debugGeographyEea to verify both "Consent" and "Do Not Consent" paths.',
  ),
  const ArticleItem(
    id: '4',
    title: 'Native Ads vs Banner Ads: Maximizing eCPM without UX Friction',
    category: 'Monetization',
    readTime: '4 min read',
    summary:
        'How to design native templates that blend organically with your design system while maintaining policy compliance.',
    fullContent:
        'Native ads provide higher engagement by styling headlines, call-to-actions, and advertiser assets in harmony with your app UI. '
        'However, AdMob policy requires an unmistakable "AD" attribution badge and clear separation between organic content and sponsored assets.\n\n'
        'Fixed height bounding templates (Small: ~90px, Medium: ~350px) ensure the layout never jumps when ads load asynchronously.',
    bonusInsights:
        '🏆 Bonus Insights Unlocked: Placing native ads every 4th to 6th item in scrollable feeds creates an optimal balance between impression volume and reading flow without overwhelming users.',
  ),
  const ArticleItem(
    id: '5',
    title:
        'Offline-First Ads Architecture: Fallbacks with Real-Time Connectivity',
    category: 'Connectivity',
    readTime: '5 min read',
    summary:
        'Using internet connection checkers to smoothly display policy-compliant offline banners when disconnected.',
    fullContent:
        'When a user goes offline or enters airplane mode, ad requests will fail. '
        'Instead of leaving awkward empty gaps or broken layouts, an offline fallback widget can promote premium in-app features, '
        'subscription benefits, or internal app features.\n\n'
        'All fallback ads must still carry clear promotional badging to maintain transparency with users.',
    bonusInsights:
        '🏆 Bonus Insights Unlocked: Real-time network stream listeners allow seamless automatic switching back to live AdMob ads the second the user reconnects to Wi-Fi or cellular data.',
  ),
  const ArticleItem(
    id: '6',
    title: 'State Management with Flutter BLoC in Ad-Monetized Apps',
    category: 'Flutter Dev',
    readTime: '7 min read',
    summary:
        'Managing rewarded ad coins, interstitial preloading, and UI notifications cleanly with BLoC.',
    fullContent:
        'Flutter BLoC decouples the presentation layer from ad lifecycle events. '
        'By emitting discrete states for ad loading status, coin balances, and snackbar messages, '
        'your widgets remain purely declarative and easy to maintain.',
    bonusInsights:
        '🏆 Bonus Insights Unlocked: Keep your BLoC free of direct platform channel calls by injecting an AdsService interface. This enables seamless unit testing of coin rewards and business logic.',
  ),
];
