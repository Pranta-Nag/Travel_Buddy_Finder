import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/auth_provider.dart';
import 'package:travel_buddy_finder/api/providers/bookmark_provider.dart';
import 'package:travel_buddy_finder/api/providers/chat_provider.dart';
import 'package:travel_buddy_finder/api/providers/comment_provider.dart';
import 'package:travel_buddy_finder/api/providers/profile_provider.dart';
import 'package:travel_buddy_finder/api/providers/trip_provider.dart';
import 'package:travel_buddy_finder/api/providers/trip_request_provider.dart';
import 'package:travel_buddy_finder/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<BookmarkProvider>(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
        ChangeNotifierProvider<CommentProvider>(create: (_) => CommentProvider()),
        ChangeNotifierProvider<ProfileProvider>(create: (_) => ProfileProvider()),
        ChangeNotifierProvider<TripProvider>(create: (_) => TripProvider()),
        ChangeNotifierProvider<TripRequestProvider>(create: (_) => TripRequestProvider()),
      ],
      child: const App(),
    ),
  );
}
