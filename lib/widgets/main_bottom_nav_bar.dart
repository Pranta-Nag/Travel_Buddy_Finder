import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/widgets/bottom_nav_item.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        color: Colors.white,
        elevation: 0,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BottomNavItem(
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore,
                label: "HOME",
                index: 0,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              BottomNavItem(
                icon: Icons.search_rounded,
                activeIcon: Icons.search_rounded,
                label: "EXPLORE",
                index: 1,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              const SizedBox(width: 48),
              BottomNavItem(
                icon: Icons.chat_bubble_outline_rounded,
                activeIcon: Icons.chat_bubble_rounded,
                label: "CHAT",
                index: 2,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              BottomNavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: "PROFILE",
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
