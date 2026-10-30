import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy_finder/api/models/chat_room_model.dart';

void main() {
  test('Test ChatRoomModel parsing with realistic data', () {
    const jsonStr = '''
{
  "status": "success",
  "username": "galib",
  "total_rooms": 2,
  "data": [
    {
      "room_id": 4,
      "trip_id": 1,
      "trip_title": "Sajek Valley Tour",
      "trip_destination": "Sajek Valley, Rangamati",
      "trip_cover_picture_url": null,
      "partner": {
        "username": "galibsidrath",
        "full_name": "Galib Sidrath",
        "profile_pic": "galibsidrath_profile_1792938755_6ade13039bc87.jpg",
        "profile_pic_url": "uploads/galibsidrath_profile_1792938755_6ade13039bc87.jpg"
      },
      "latest_message": {
        "id": 12,
        "message_text": "how much do you needs?",
        "sender_username": "galibsidrath",
        "is_my_message": false,
        "seen_status": 1,
        "created_at": "2026-10-30 11:51:07"
      },
      "unseen_count": 0,
      "has_unseen": false,
      "last_activity": "2026-10-30 11:51:07"
    },
    {
      "room_id": 1,
      "trip_id": 4,
      "trip_title": "Sylhet Ratargul & Jaflong Tour",
      "trip_destination": "Sylhet, Bangladesh",
      "trip_cover_picture_url": null,
      "partner": {
        "username": "tanjim_traveler",
        "full_name": "Tanjim Ahmed",
        "profile_pic": null,
        "profile_pic_url": null
      },
      "latest_message": null,
      "unseen_count": 0,
      "has_unseen": false,
      "last_activity": "2026-10-10 21:13:29"
    }
  ]
}
''';

    final decoded = jsonDecode(jsonStr);
    final List rawList = decoded['data'];
    final rooms = rawList
        .whereType<Map>()
        .map((item) => ChatRoomModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    expect(rooms.length, 2);
    expect(rooms[0].hasUnread, false);
    expect(rooms[1].lastMessage, '');
    expect(rooms[1].hasUnread, false);
  });
}
