import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/app.dart';
import 'package:travel_buddy_finder/features/auth/data/providers/auth_provider.dart';
import 'package:travel_buddy_finder/features/chat/data/providers/chat_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const App(),
    ),
  );
}
