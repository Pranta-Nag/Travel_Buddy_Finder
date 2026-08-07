import 'package:flutter/material.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rating"),
      ),
      body: const Center(
        child: Text("Rating Screen"),
      ),
    );
  }
}
