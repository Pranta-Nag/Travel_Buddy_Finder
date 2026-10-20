import 'package:travel_buddy_finder/core/constants/api_constants.dart';

class ChatRoomModel {
  final int roomId;
  final int tripId;
  final String partnerName;
  final String partnerUsername;
  final String partnerAvatarUrl;
  final String tripTitle;
  final String lastMessage;
  final String lastMessageTime;
  final int unseenCount;

  ChatRoomModel({
    required this.roomId,
    required this.tripId,
    required this.partnerName,
    required this.partnerUsername,
    required this.partnerAvatarUrl,
    required this.tripTitle,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unseenCount,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      roomId: json['room_id'] is int ? json['room_id'] : int.parse(json['room_id'].toString()),
      tripId: json['trip_id'] is int ? json['trip_id'] : int.parse(json['trip_id'].toString()),
      partnerName: json['partner_name'] ?? json['host_name'] ?? 'Traveler',
      partnerUsername: json['partner_username'] ?? '@user',
      partnerAvatarUrl: ApiConstants.resolveImageUrl(json['partner_avatar'] ?? json['avatar_url']),
      tripTitle: json['trip_title'] ?? 'Trip',
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['last_message_time'] ?? '',
      unseenCount: json['unseen_count'] is int
          ? json['unseen_count']
          : int.tryParse(json['unseen_count']?.toString() ?? '0') ?? 0,
    );
  }
}
