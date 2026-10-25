import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/auth_provider.dart';
import 'package:travel_buddy_finder/api/providers/profile_provider.dart';
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
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    // Keep splash visible for smooth UX (at least 2 seconds)
    final minSplashDuration = Future.delayed(const Duration(seconds: 2));

    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = await authProvider.tryAutoLogin();

    await minSplashDuration;
    if (!mounted) return;

    if (isLoggedIn) {
      // Sync ProfileProvider with the freshly verified profile
      context.read<ProfileProvider>().fetchMyProfile();

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: Center(
          child: Image.asset(
            AssetsPath.logoImg,
            width: 300,
            height: 300,
          ),
        ),
      ),
    );
  }
}
