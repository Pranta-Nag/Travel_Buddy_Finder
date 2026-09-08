import 'package:flutter/foundation.dart';
import 'package:travel_buddy_finder/models/app_notification.dart';

class NotificationStore {
  NotificationStore._();

  static final ValueNotifier<List<AppNotification>> notifications =
      ValueNotifier<List<AppNotification>>([]);

  static final Map<String, ValueNotifier<int>> _unreadNotifiers = {};

  static List<AppNotification> visibleTo(String username) {
    return notifications.value
        .where((notification) => notification.recipientUsername == username)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static int unreadCount(String username) =>
      visibleTo(username).where((notification) => !notification.read).length;

  static ValueNotifier<int> unreadCountNotifier(String username) {
    return _unreadNotifiers.putIfAbsent(
      username,
      () => ValueNotifier<int>(unreadCount(username)),
    );
  }

  static void _recomputeUnread(String username) {
    final notifier = _unreadNotifiers[username];
    if (notifier != null) {
      notifier.value = unreadCount(username);
    }
  }

  static void send({
    required String title,
    required String body,
    required String recipientUsername,
    String? tripId,
  }) {
    final list = List<AppNotification>.from(notifications.value);
    final id =
        DateTime.now().millisecondsSinceEpoch.toString().padLeft(16, '0');
    list.add(AppNotification(
      id: id,
      title: title,
      body: body,
      recipientUsername: recipientUsername,
      tripId: tripId,
    ));
    notifications.value = list;
    _recomputeUnread(recipientUsername);
  }

  static void markRead(String id) {
    final list = List<AppNotification>.from(notifications.value);
    final index = list.indexWhere((notification) => notification.id == id);
    if (index < 0) return;
    final username = list[index].recipientUsername;
    list[index].read = true;
    notifications.value = [...list];
    _recomputeUnread(username);
  }

  static void markAllRead(String username) {
    final list = List<AppNotification>.from(notifications.value);
    var changed = false;
    for (var i = 0; i < list.length; i++) {
      if (list[i].recipientUsername == username && !list[i].read) {
        list[i].read = true;
        changed = true;
      }
    }
    if (changed) {
      notifications.value = [...list];
      _recomputeUnread(username);
    }
  }

  static void remove(String id) {
    final list = List<AppNotification>.from(notifications.value);
    final index = list.indexWhere((notification) => notification.id == id);
    if (index < 0) return;
    final username = list[index].recipientUsername;
    list.removeAt(index);
    notifications.value = [...list];
    _recomputeUnread(username);
  }
}
