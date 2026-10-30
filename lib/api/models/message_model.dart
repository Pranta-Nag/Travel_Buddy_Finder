import 'package:intl/intl.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';

class MessageModel {
  final int messageId;
  final int roomId;
  final String senderUsername;
  final String senderName;
  final String? senderProfilePicUrl;
  final String messageText;
  final bool isMe;
  final String createdAt;
  final bool seenStatus;

  MessageModel({
    required this.messageId,
    required this.roomId,
    required this.senderUsername,
    required this.senderName,
    this.senderProfilePicUrl,
    required this.messageText,
    required this.isMe,
    required this.createdAt,
    required this.seenStatus,
  });

  String get fullSenderAvatarUrl =>
      AppUrl.resolveImageUrl(senderProfilePicUrl);

  String get formattedTime {
    if (createdAt.isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(createdAt);
      if (parsed != null) {
        return DateFormat('h:mm a').format(parsed.toLocal());
      }
    } catch (_) {}
    return createdAt;
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawId =
        json['id'] ?? json['message_id'] ?? json['messageId'] ?? 0;
    final int parsedId = (rawId is num
        ? rawId.toInt()
        : int.tryParse(rawId?.toString() ?? '')) ?? 0;

    final dynamic rawRoomId = json['room_id'] ?? json['roomId'] ?? 0;
    final int parsedRoomId = (rawRoomId is num
        ? rawRoomId.toInt()
        : int.tryParse(rawRoomId?.toString() ?? '')) ?? 0;

    final rawSenderUsername = (json['sender_username'] ??
            json['username'] ??
            json['sender'] ??
            '')
        .toString();

    final rawSenderName = (json['sender_name'] ??
            json['full_name'] ??
            json['name'] ??
            rawSenderUsername)
        .toString();

    final rawSenderAvatar = json['sender_profile_pic_url'] ??
        json['sender_profile_pic'] ??
        json['profile_pic_url'] ??
        json['profile_pic'] ??
        json['avatar_url'];

    final rawMessage =
        (json['message_text'] ?? json['message'] ?? json['text'] ?? '')
            .toString();

    final dynamic rawIsMyMessage = json['is_my_message'] ?? json['is_me'];
    final bool isMyMessage = rawIsMyMessage == true ||
        rawIsMyMessage == 1 ||
        rawIsMyMessage?.toString().toLowerCase() == 'true' ||
        rawIsMyMessage?.toString() == '1' ||
        CurrentUser.isCurrentUser(rawSenderUsername, inputName: rawSenderName);

    final dynamic rawSeenStatus = json['seen_status'] ?? json['is_seen'];
    final bool isSeen = rawSeenStatus == 1 ||
        rawSeenStatus == true ||
        rawSeenStatus?.toString() == '1' ||
        rawSeenStatus?.toString().toLowerCase() == 'true';

    return MessageModel(
      messageId: parsedId,
      roomId: parsedRoomId,
      senderUsername: rawSenderUsername,
      senderName: rawSenderName,
      senderProfilePicUrl: rawSenderAvatar?.toString(),
      messageText: rawMessage,
      isMe: isMyMessage,
      createdAt: json['created_at']?.toString() ?? 'Just now',
      seenStatus: isSeen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': messageId,
      'room_id': roomId,
      'sender_username': senderUsername,
      'sender_name': senderName,
      'sender_profile_pic_url': senderProfilePicUrl,
      'message_text': messageText,
      'is_my_message': isMe,
      'created_at': createdAt,
      'seen_status': seenStatus ? 1 : 0,
    };
  }
}
