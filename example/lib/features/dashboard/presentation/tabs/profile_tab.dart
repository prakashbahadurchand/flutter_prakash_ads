import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ads/flutter_ads.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/ads/cubit/ads_cubit.dart';
import '../../../../core/ads/cubit/ads_state.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/theme/theme_cubit.dart';

/// Profile Tab — User profile overview with interactive theme, locale, and live coin stats.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const SizedBox(height: 16),

        // Profile Header
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_rounded,
                  size: 48,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'John Doe',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'john.doe@example.com',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Quick Stats Row with Live Synchronized Coins
        Row(
          children: [
            _StatCard(
              icon: Icons.article_outlined,
              label: 'Articles',
              value: '24',
              color: theme.colorScheme.primary,
              theme: theme,
            ),
            const SizedBox(width: 12),
            _StatCard(
              icon: Icons.favorite_rounded,
              label: 'Favorites',
              value: '8',
              color: Colors.redAccent,
              theme: theme,
            ),
            const SizedBox(width: 12),
            BlocBuilder<AdsCubit, AdsState>(
              builder: (context, adsState) {
                return _StatCard(
                  icon: Icons.monetization_on_rounded,
                  label: 'Coins',
                  value: '${adsState.coins}',
                  color: Colors.amber.shade700,
                  theme: theme,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Settings Section
        Text(
          'Settings',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),

        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, currentMode) {
                  final modeText = switch (currentMode) {
                    ThemeMode.light => 'Light Mode',
                    ThemeMode.dark => 'Dark Mode',
                    ThemeMode.system => 'System Default',
                  };

                  return _SettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'Theme',
                    subtitle: modeText,
                    onTap: () => _showThemeDialog(context, currentMode),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: 'English (US)',
                onTap: () => _showLanguageDialog(context),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.tune_rounded,
                title: 'Ad Formats Playground',
                subtitle: 'Test all Google Mobile Ad formats',
                onTap: () => context.router.push(const AdsDemoRoute()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Privacy Section
        Text(
          'Privacy & Legal',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),

        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy & Consent Settings',
                subtitle: 'Manage GDPR / CPRA consent',
                onTap: () async {
                  final error = await AdsManager.showPrivacyOptionsForm();
                  if (error != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Privacy: ${error.message}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'View terms and conditions',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _showThemeDialog(BuildContext context, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              icon: Icons.brightness_auto_rounded,
              label: 'System Default',
              isSelected: currentMode == ThemeMode.system,
              onTap: () {
                context.read<ThemeCubit>().setThemeMode(ThemeMode.system);
                Navigator.pop(dialogContext);
              },
            ),
            _ThemeOption(
              icon: Icons.light_mode_rounded,
              label: 'Light Mode',
              isSelected: currentMode == ThemeMode.light,
              onTap: () {
                context.read<ThemeCubit>().setThemeMode(ThemeMode.light);
                Navigator.pop(dialogContext);
              },
            ),
            _ThemeOption(
              icon: Icons.dark_mode_rounded,
              label: 'Dark Mode',
              isSelected: currentMode == ThemeMode.dark,
              onTap: () {
                context.read<ThemeCubit>().setThemeMode(ThemeMode.dark);
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              flag: '🇺🇸',
              label: 'English (US)',
              isSelected: true,
              onTap: () => Navigator.pop(dialogContext),
            ),
            _LanguageOption(
              flag: '🇪🇸',
              label: 'Español',
              isSelected: false,
              onTap: () => Navigator.pop(dialogContext),
            ),
            _LanguageOption(
              flag: '🇩🇪',
              label: 'Deutsch',
              isSelected: false,
              onTap: () => Navigator.pop(dialogContext),
            ),
            _LanguageOption(
              flag: '🇯🇵',
              label: '日本語',
              isSelected: false,
              onTap: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────── Private Helper Widgets ───────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: theme.colorScheme.outline,
      ),
      onTap: onTap,
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline,
      ),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
