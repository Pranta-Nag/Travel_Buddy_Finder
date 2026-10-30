import 'package:travel_buddy_finder/core/constants/url.dart';

class ChatRoomModel {
  final int roomId;
  final int tripId;
  final String partnerName;
  final String partnerUsername;
  final String partnerAvatarUrl;
  final String tripTitle;
  final String? tripDestination;
  final String? tripCoverUrl;
  final int? lastMessageId;
  final String lastMessage;
  final String lastMessageTime;
  final bool isLastMessageMine;
  final int lastMessageSeenStatus; // 0 = unseen/sent, 1 = seen
  final int unseenCount;

  ChatRoomModel({
    required this.roomId,
    required this.tripId,
    required this.partnerName,
    required this.partnerUsername,
    required this.partnerAvatarUrl,
    required this.tripTitle,
    this.tripDestination,
    this.tripCoverUrl,
    this.lastMessageId,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isLastMessageMine = false,
    this.lastMessageSeenStatus = 0,
    required this.unseenCount,
  });

  bool get hasUnread => (unseenCount) > 0;
  bool get isLastMessageSeen => (lastMessageSeenStatus) == 1;

  String get formattedLastTime {
    if (lastMessageTime.isEmpty) return '';
    try {
      final dt = DateTime.tryParse(lastMessageTime);
      if (dt == null) return lastMessageTime.split(' ').first;
      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inDays == 0 && now.day == dt.day) {
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final minute = dt.minute.toString().padLeft(2, '0');
        final period = dt.hour >= 12 ? 'PM' : 'AM';
        return '$hour:$minute $period';
      } else if (difference.inDays <= 1 && (now.day - dt.day).abs() <= 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[dt.weekday - 1];
      } else {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${months[dt.month - 1]} ${dt.day}';
      }
    } catch (_) {
      return lastMessageTime.split(' ').first;
    }
  }

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    // 1. Room & Trip IDs
    final dynamic rawRoomId = json['room_id'] ?? json['roomId'] ?? json['id'] ?? 0;
    final int parsedRoomId = (rawRoomId is num
        ? rawRoomId.toInt()
        : int.tryParse(rawRoomId?.toString() ?? '')) ?? 0;

    final dynamic rawTripId = json['trip_id'] ?? json['tripId'] ?? 0;
    final int parsedTripId = (rawTripId is num
        ? rawTripId.toInt()
        : int.tryParse(rawTripId?.toString() ?? '')) ?? 0;

    // 2. Partner data (nested object or flat fields)
    final dynamic partnerObj = json['partner'] is Map ? json['partner'] : null;

    final String rawPartnerName = (partnerObj?['full_name'] ??
            partnerObj?['name'] ??
            json['partner_name'] ??
            json['host_name'] ??
            partnerObj?['username'] ??
            json['partner_username'] ??
            'Traveler')
        .toString();

    final String rawPartnerUsername = (partnerObj?['username'] ??
            json['partner_username'] ??
            '@user')
        .toString();

    final dynamic rawPartnerPic = partnerObj?['profile_pic_url'] ??
        partnerObj?['profile_pic'] ??
        json['partner_avatar'] ??
        json['partner_avatar_url'] ??
        json['avatar_url'];

    // 3. Latest message data (nested object or flat fields)
    final dynamic latestMsgObj =
        json['latest_message'] is Map ? json['latest_message'] : null;

    final dynamic rawLastMsgIdVal = latestMsgObj?['id'] ??
        json['last_message_id'] ??
        json['latest_message_id'];
    final int? parsedLastMsgId = rawLastMsgIdVal is num
        ? rawLastMsgIdVal.toInt()
        : int.tryParse(rawLastMsgIdVal?.toString() ?? '');

    final String rawLastMessage = (latestMsgObj?['message_text'] ??
            json['last_message'] ??
            json['message'] ??
            '')
        .toString();

    final String rawLastMessageTime = (latestMsgObj?['created_at'] ??
            json['last_message_time'] ??
            json['time'] ??
            '')
        .toString();

    final dynamic rawIsLastMineVal =
        latestMsgObj?['is_my_message'] ?? json['is_my_message'];
    final bool parsedIsLastMine = rawIsLastMineVal == true ||
        rawIsLastMineVal == 1 ||
        rawIsLastMineVal?.toString().toLowerCase() == 'true' ||
        rawIsLastMineVal?.toString() == '1';

    final dynamic rawSeenStatusVal =
        latestMsgObj?['seen_status'] ?? json['seen_status'] ?? 0;
    final int parsedSeenStatus = (rawSeenStatusVal is num
        ? rawSeenStatusVal.toInt()
        : int.tryParse(rawSeenStatusVal?.toString() ?? '')) ?? 0;

    // 4. Unseen count
    final dynamic rawUnseenVal =
        json['unseen_count'] ?? json['unseenCount'] ?? 0;
    final int parsedUnseen = (rawUnseenVal is num
        ? rawUnseenVal.toInt()
        : int.tryParse(rawUnseenVal?.toString() ?? '')) ?? 0;

    return ChatRoomModel(
      roomId: parsedRoomId,
      tripId: parsedTripId,
      partnerName: rawPartnerName,
      partnerUsername: rawPartnerUsername.startsWith('@')
          ? rawPartnerUsername
          : '@$rawPartnerUsername',
      partnerAvatarUrl: AppUrl.resolveImageUrl(rawPartnerPic?.toString()),
      tripTitle: json['trip_title']?.toString() ?? 'Trip Chat',
      tripDestination: json['trip_destination']?.toString(),
      tripCoverUrl: AppUrl.resolveImageUrl(json['trip_cover_picture_url']?.toString()),
      lastMessageId: parsedLastMsgId,
      lastMessage: rawLastMessage,
      lastMessageTime: rawLastMessageTime,
      isLastMessageMine: parsedIsLastMine,
      lastMessageSeenStatus: parsedSeenStatus,
      unseenCount: parsedUnseen,
    );
  }
}
