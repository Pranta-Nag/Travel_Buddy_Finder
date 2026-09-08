import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';
import 'package:travel_buddy_finder/screens/notifications_screen.dart';
import 'package:travel_buddy_finder/stores/current_user.dart';
import 'package:travel_buddy_finder/stores/notification_store.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EXPLORE FEED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade400,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Find Travel Buddies',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.grey,
                  size: 22,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: NotificationStore.unreadCountNotifier(
                CurrentUser.username,
              ),
              builder: (context, count, _) {
                if (count == 0) return const SizedBox.shrink();
                return Positioned(
                  top: 2,
                  right: 2,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: AppColors.error,
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
