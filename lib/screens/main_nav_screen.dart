import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/screens/explore_screen.dart';
import 'package:travel_buddy_finder/screens/user_profile_screen.dart';
import 'package:travel_buddy_finder/widgets/chat_tab.dart';
import 'package:travel_buddy_finder/widgets/home/home_tab.dart';
import 'package:travel_buddy_finder/widgets/main_bottom_nav_bar.dart';
import 'package:travel_buddy_finder/widgets/main_fab.dart';
import 'package:travel_buddy_finder/widgets/screen_background.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
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
            ChatTab(),
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
