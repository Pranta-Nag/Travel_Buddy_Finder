import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy_finder/api/models/chat_room_model.dart';

void main() {
  test('Test various payloads for ChatRoomModel and ChatProvider', () async {
    // Case 1: Room with null latest_message
    final Map<String, dynamic> json1 = {
      "room_id": 1,
      "trip_id": 4,
      "trip_title": "Sylhet",
      "trip_destination": null,
      "trip_cover_picture_url": null,
      "partner": {
        "username": "tanjim_traveler",
        "full_name": null,
        "profile_pic": null,
        "profile_pic_url": null
      },
      "latest_message": null,
      "unseen_count": 0,
      "has_unseen": false,
      "last_activity": "2026-10-10 21:13:29"
    };

    final room1 = ChatRoomModel.fromJson(json1);
    expect(room1.hasUnread, false);
    expect(room1.isLastMessageMine, false);
    expect(room1.unseenCount, 0);

    // Case 2: Room with empty map or weird types
    final Map<String, dynamic> json2 = {
      "room_id": "2",
      "trip_id": "5",
      "trip_title": null,
      "partner": null,
      "latest_message": {
        "id": "10",
        "message_text": null,
        "sender_username": null,
        "is_my_message": null,
        "seen_status": null,
        "created_at": null,
      },
      "unseen_count": null,
    };

    final room2 = ChatRoomModel.fromJson(json2);
    expect(room2.hasUnread, false);
    expect(room2.isLastMessageMine, false);
    expect(room2.lastMessageSeenStatus, 0);
    expect(room2.unseenCount, 0);
  });
}
