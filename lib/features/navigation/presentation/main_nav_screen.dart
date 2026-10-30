import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/chat_provider.dart';
import 'package:travel_buddy_finder/core/widgets/screen_background.dart';
import 'package:travel_buddy_finder/features/chat/presentation/screens/chat_inbox_screen.dart';
import 'package:travel_buddy_finder/features/navigation/presentation/widgets/main_bottom_nav_bar.dart';
import 'package:travel_buddy_finder/features/navigation/presentation/widgets/main_fab.dart';
import 'package:travel_buddy_finder/features/profile/presentation/user_profile_screen.dart';
import 'package:travel_buddy_finder/features/trips/presentation/screens/explore_screen.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/home/home_tab.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChatProvider>().startInboxPolling();
      }
    });
  }

  void _onNavTap(int index) {
    if (index == 2) {
      // User tapped CHAT tab: pull fresh rooms immediately
      context.read<ChatProvider>().fetchChatRooms(silent: true);
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            HomeTab(),
            ExploreScreen(),
            ChatInboxScreen(),
            UserProfileScreen(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const MainFloatingActionButton(),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
