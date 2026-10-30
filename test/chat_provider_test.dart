import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy_finder/api/models/chat_room_model.dart';
import 'package:travel_buddy_finder/api/providers/chat_provider.dart';

void main() {
  test('ChatProvider test with real API simulation', () async {
    final provider = ChatProvider();

    // Test with mock rooms
    final room1 = ChatRoomModel(
      roomId: 4,
      tripId: 1,
      partnerName: 'Galib Sidrath',
      partnerUsername: '@galibsidrath',
      partnerAvatarUrl: '',
      tripTitle: 'Sajek',
      lastMessage: 'how much do you needs?',
      lastMessageTime: '2026-10-30 11:51:07',
      isLastMessageMine: false,
      lastMessageSeenStatus: 1,
      unseenCount: 0,
    );

    final room2 = ChatRoomModel(
      roomId: 1,
      tripId: 4,
      partnerName: 'Tanjim Ahmed',
      partnerUsername: '@tanjim',
      partnerAvatarUrl: '',
      tripTitle: 'Sylhet',
      lastMessage: 'hello',
      lastMessageTime: '2026-10-30 11:51:07',
      isLastMessageMine: true,
      lastMessageSeenStatus: 1,
      unseenCount: 0,
    );

    expect(room1.hasUnread, false);
    expect(room1.isLastMessageSeen, true);
    expect(room2.roomId, 1);
    expect(provider.totalUnreadCount, 0);
  });
}
