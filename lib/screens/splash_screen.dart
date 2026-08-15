import 'dart:async';
import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/screens/login_screen.dart';
import 'package:travel_buddy_finder/utils/asset_path.dart';
import 'package:travel_buddy_finder/widgets/screen_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    });
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
