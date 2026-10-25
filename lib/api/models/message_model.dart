class MessageModel {
  final int messageId;
  final int roomId;
  final int senderId;
  final String senderName;
  final String messageText;
  final bool isMe;
  final String createdAt;
  final bool seenStatus;

  MessageModel({
    required this.messageId,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.messageText,
    required this.isMe,
    required this.createdAt,
    required this.seenStatus,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['message_id'] is int
          ? json['message_id']
          : int.parse(json['message_id'].toString()),
      roomId: json['room_id'] is int
          ? json['room_id']
          : int.parse(json['room_id'].toString()),
      senderId: json['sender_id'] is int
          ? json['sender_id']
          : int.parse(json['sender_id'].toString()),
      senderName: json['sender_name'] ?? '',
      messageText: json['message_text'] ?? '',
      isMe: json['is_me'] == true || json['is_me'] == 1 || json['is_me'] == '1',
      createdAt: json['created_at'] ?? '',
      seenStatus: json['seen_status'] == true || json['seen_status'] == 1 || json['seen_status'] == '1',
    );
  }
}
