import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/auth_provider.dart';
import 'package:travel_buddy_finder/api/providers/chat_provider.dart';
import 'package:travel_buddy_finder/api/providers/profile_provider.dart';
import 'package:travel_buddy_finder/api/providers/trip_provider.dart';
import 'package:travel_buddy_finder/app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      child: const App(),
    ),
  );
}
