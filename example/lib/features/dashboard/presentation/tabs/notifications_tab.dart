import 'package:flutter/material.dart';

/// Model representing an in-app notification item.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      time: time,
      icon: icon,
      color: color,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Notifications Tab — Realistic interactive notification center.
class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      const AppNotification(
        id: '1',
        title: '🎉 Welcome Bonus Granted!',
        message: 'You received +50 starter coins for testing rewarded ad formats.',
        time: 'Just now',
        icon: Icons.monetization_on_rounded,
        color: Colors.amber,
      ),
      const AppNotification(
        id: '2',
        title: '🛡️ UMP Consent Active',
        message: 'Google User Messaging Platform GDPR/CPRA consent initialized.',
        time: '5m ago',
        icon: Icons.verified_user_rounded,
        color: Colors.green,
      ),
      const AppNotification(
        id: '3',
        title: '📖 New Architecture Guide',
        message: 'Learn how to avoid full-screen ad collisions and CLS with Clean BLoC/Cubit.',
        time: '1h ago',
        icon: Icons.article_rounded,
        color: Color(0xFF6750A4),
      ),
      const AppNotification(
        id: '4',
        title: '⚡ Offline Mode Available',
        message: 'Custom promotional fallbacks are ready when your connection drops.',
        time: '2h ago',
        icon: Icons.wifi_off_rounded,
        color: Colors.teal,
        isRead: true,
      ),
    ];
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Column(
      children: [
        // Sub-header with count and mark read action
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                '$unreadCount Unread',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              if (unreadCount > 0)
                TextButton(
                  onPressed: _markAllAsRead,
                  child: const Text('Mark all as read', style: TextStyle(fontSize: 13)),
                ),
            ],
          ),
        ),

        // Notifications List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            itemCount: _notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = _notifications[index];

              return Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                color: item.isRead
                    ? theme.colorScheme.surface
                    : theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: item.color.withValues(alpha: 0.15),
                    child: Icon(item.icon, color: item.color, size: 22),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.time,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  trailing: !item.isRead
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _notifications[index] = item.copyWith(isRead: true);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
