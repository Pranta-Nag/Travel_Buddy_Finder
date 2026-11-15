import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/chat_provider.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/features/navigation/presentation/widgets/bottom_nav_item.dart';
import 'package:travel_buddy_finder/features/trips/presentation/screens/add_new_trip_screen.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget _buildAddTripButton(BuildContext context) {
    return Semantics(
      label: 'Create New Trip',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            HapticFeedback.mediumImpact();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddNewTripScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(26),
          child: Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.38),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int unreadChatCount = context.watch<ChatProvider>().totalUnreadCount;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BottomNavItem(
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                label: "Home",
                index: 0,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              BottomNavItem(
                icon: Icons.search_rounded,
                activeIcon: Icons.search_rounded,
                label: "Explore",
                index: 1,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _buildAddTripButton(context),
              BottomNavItem(
                icon: Icons.chat_bubble_outline_rounded,
                activeIcon: Icons.chat_bubble_rounded,
                label: "Chat",
                index: 2,
                currentIndex: currentIndex,
                onTap: onTap,
                badgeCount: unreadChatCount,
              ),
              BottomNavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: "Profile",
                index: 3,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
