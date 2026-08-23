import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy_finder/models/app_notification.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';
import 'package:travel_buddy_finder/stores/current_user.dart';
import 'package:travel_buddy_finder/stores/notification_store.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    NotificationStore.markAllRead(CurrentUser.username);
  }

  @override
  Widget build(BuildContext context) {
    const username = CurrentUser.username;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        actions: [
          ValueListenableBuilder<List<AppNotification>>(
            valueListenable: NotificationStore.notifications,
            builder: (context, _, __) {
              final unread = NotificationStore.unreadCount(username);
              if (unread == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  NotificationStore.markAllRead(username);
                  setState(() {});
                },
                child: const Text(
                  'Mark all read',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder<List<AppNotification>>(
        valueListenable: NotificationStore.notifications,
        builder: (context, notifications, _) {
          final items = NotificationStore.visibleTo(username);

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 40,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You’ll see approval updates for your join requests here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notification = items[index];
              return Dismissible(
                key: ValueKey(notification.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                onDismissed: (_) {
                  NotificationStore.remove(notification.id);
                },
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(
                      _iconFor(notification),
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(
                    notification.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: notification.read
                          ? FontWeight.normal
                          : FontWeight.bold,
                      fontSize: 13,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM d, h:mm a')
                            .format(notification.createdAt),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  trailing: notification.read
                      ? null
                      : const Icon(
                          Icons.brightness_1_rounded,
                          size: 10,
                          color: AppColors.primary,
                        ),
                  onTap: () {
                    NotificationStore.markRead(notification.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconFor(AppNotification notification) {
    final title = notification.title.toLowerCase();
    if (title.contains('approv')) return Icons.check_circle_rounded;
    if (title.contains('not')) return Icons.cancel_rounded;
    return Icons.notifications_rounded;
  }
}
