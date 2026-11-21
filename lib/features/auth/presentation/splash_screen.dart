import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/auth_provider.dart';
import 'package:travel_buddy_finder/api/providers/bookmark_provider.dart';
import 'package:travel_buddy_finder/api/providers/profile_provider.dart';
import 'package:travel_buddy_finder/app.dart';
import 'package:travel_buddy_finder/features/auth/presentation/login_screen.dart';
import 'package:travel_buddy_finder/features/navigation/presentation/main_nav_screen.dart';
import 'package:travel_buddy_finder/core/constants/asset_path.dart';
import 'package:travel_buddy_finder/core/widgets/screen_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleStartup();
    });
  }

  Future<void> _handleStartup() async {
    bool isLoggedIn = false;
    try {
      final authProvider = context.read<AuthProvider>();
      final autoLoginTask = authProvider.tryAutoLogin();

      // Keep splash visible for smooth UX (1.5 - 2 seconds)
      final minSplashDuration = Future.delayed(const Duration(milliseconds: 1500));

      final results = await Future.wait([
        autoLoginTask.timeout(const Duration(seconds: 2), onTimeout: () => false),
        minSplashDuration,
      ]);

      isLoggedIn = results[0];
    } catch (e) {
      debugPrint('Startup auto-login check failed: $e');
      isLoggedIn = false;
    }

    if (!mounted) return;

    try {
      if (isLoggedIn) {
        try {
          context.read<ProfileProvider>().fetchMyProfile();
          context.read<BookmarkProvider>().fetchMyBookmarks(silent: true);
        } catch (_) {}

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
    } catch (navError) {
      debugPrint('Direct navigation failed, attempting root navigatorKey: $navError');
      AppNavigator.navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (_) => isLoggedIn ? const MainNavScreen() : const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: Center(
          child: Image.asset(
            AssetsPath.tbfLogo,
            width: 300,
            height: 300,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                AssetsPath.logoImg,
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              );
            },
          ),
        ),
      ),
    );
  }
}
