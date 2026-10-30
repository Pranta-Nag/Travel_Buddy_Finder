import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy_finder/api/models/chat_room_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Debug chat provider fetchChatRooms with various room data', () async {
    // Create room with null latest message
    final roomNoMsg = ChatRoomModel(
      roomId: 2,
      tripId: 4,
      partnerName: 'Tanjim',
      partnerUsername: '@tanjim',
      partnerAvatarUrl: '',
      tripTitle: 'Sylhet',
      lastMessage: '',
      lastMessageTime: '',
      isLastMessageMine: false,
      lastMessageSeenStatus: 0,
      unseenCount: 0,
    );

    // Create room with message from partner
    final roomPartnerMsg = ChatRoomModel(
      roomId: 3,
      tripId: 5,
      partnerName: 'Galib',
      partnerUsername: '@galibsidrath',
      partnerAvatarUrl: '',
      tripTitle: 'Bandarban',
      lastMessageId: 6,
      lastMessage: 'Hi Brother!',
      lastMessageTime: '2026-10-30 11:41:31',
      isLastMessageMine: false,
      lastMessageSeenStatus: 0,
      unseenCount: 1,
    );

    expect(roomNoMsg.hasUnread, false);
    expect(roomPartnerMsg.hasUnread, true);
  });
}
