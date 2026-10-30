import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/models/chat_room_model.dart';
import 'package:travel_buddy_finder/api/providers/chat_provider.dart';
import 'package:travel_buddy_finder/features/chat/presentation/screens/chat_inbox_screen.dart';
import 'package:travel_buddy_finder/features/navigation/presentation/widgets/main_bottom_nav_bar.dart';

class MockChatProvider extends ChangeNotifier implements ChatProvider {
  List<ChatRoomModel> _rooms = [];

  void setRooms(List<ChatRoomModel> r) {
    _rooms = r;
    notifyListeners();
  }

  @override
  List<ChatRoomModel> get chatRooms => _rooms;

  @override
  int get totalUnreadCount => _rooms.fold(0, (sum, room) => sum + room.unseenCount);

  @override
  Stream<List<ChatRoomModel>> get roomsStream => Stream.value(_rooms);

  @override
  bool get isLoading => false;

  @override
  Future<void> fetchChatRooms({bool? silent}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const jsonResponse = '''
{
    "status": "success",
    "username": "new_traveler",
    "total_rooms": 2,
    "data": [
        {
            "room_id": 3,
            "trip_id": 5,
            "trip_title": "Bandarban Mountain Trekking",
            "trip_destination": "Bandarban, Bangladesh",
            "trip_cover_picture_url": null,
            "partner": {
                "username": "galibsidrath",
                "full_name": "Galib Sidrath",
                "profile_pic": "galibsidrath_profile_1792938755_6ade13039bc87.jpg",
                "profile_pic_url": "uploads/galibsidrath_profile_1792938755_6ade13039bc87.jpg"
            },
            "latest_message": {
                "id": 6,
                "message_text": "Hi Brother! what up?",
                "sender_username": "galibsidrath",
                "is_my_message": false,
                "seen_status": 0,
                "created_at": "2026-10-30 11:41:31"
            },
            "unseen_count": 1,
            "has_unseen": true,
            "last_activity": "2026-10-30 11:41:31"
        },
        {
            "room_id": 2,
            "trip_id": 4,
            "trip_title": "Sylhet Ratargul & Jaflong Tour",
            "trip_destination": "Sylhet, Bangladesh",
            "trip_cover_picture_url": null,
            "partner": {
                "username": "tanjim_traveler",
                "full_name": "Tanjim Ahmed",
                "profile_pic": "tanjim_traveler_profile_1791611581_6ac9d2bd2b6fd.jpg",
                "profile_pic_url": "uploads/tanjim_traveler_profile_1791611581_6ac9d2bd2b6fd.jpg"
            },
            "latest_message": null,
            "unseen_count": 0,
            "has_unseen": false,
            "last_activity": "2026-10-10 21:31:46"
        }
    ]
}
''';

  testWidgets('Test ChatInboxScreen and MainBottomNavBar with real payload', (tester) async {
    final decoded = jsonDecode(jsonResponse);
    final List rawList = decoded['data'];
    final rooms = rawList
        .whereType<Map>()
        .map((item) => ChatRoomModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    final provider = MockChatProvider();
    provider.setRooms(rooms);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ChatProvider>.value(value: provider),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: const ChatInboxScreen(),
            bottomNavigationBar: MainBottomNavBar(
              currentIndex: 2,
              onTap: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Bandarban Mountain Trekking'), findsOneWidget);
    expect(find.text('Sylhet Ratargul & Jaflong Tour'), findsOneWidget);
    expect(find.text('Hi Brother! what up?'), findsOneWidget);
    expect(find.text('Tap to start conversation'), findsOneWidget);
  });
}
