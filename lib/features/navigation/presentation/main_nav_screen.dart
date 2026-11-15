import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/chat_provider.dart';
import 'package:travel_buddy_finder/core/widgets/screen_background.dart';
import 'package:travel_buddy_finder/features/chat/presentation/screens/chat_inbox_screen.dart';
import 'package:travel_buddy_finder/features/navigation/presentation/widgets/main_bottom_nav_bar.dart';
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
  DateTime? _lastBackPressTime;

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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          // If on another tab, return to Home tab first
          setState(() => _currentIndex = 0);
          return;
        }

        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text('Press back again to exit'),
                ],
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: const Color(0xFF0F172A),
            ),
          );
          return;
        }

        SystemNavigator.pop();
      },
      child: ScreenBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              HomeTab(),
              ExploreScreen(),
              ChatInboxScreen(),
              UserProfileScreen(),
            ],
          ),
          bottomNavigationBar: MainBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onNavTap,
          ),
        ),
      ),
    );
  }
}
