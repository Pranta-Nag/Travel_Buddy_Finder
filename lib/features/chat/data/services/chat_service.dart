import 'dart:convert';
import 'package:travel_buddy_finder/core/network/api_client.dart';
import 'package:travel_buddy_finder/features/chat/data/models/chat_room_model.dart';
import 'package:travel_buddy_finder/features/chat/data/models/message_model.dart';

class ChatService {
  Future<List<ChatRoomModel>> getChatRooms() async {
    final response = await ApiClient.get('/chat_rooms');
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List list = json['data'] ?? [];
      return list.map((item) => ChatRoomModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<int?> startChat(int tripId) async {
    final response = await ApiClient.post('/start_chat', body: {'trip_id': tripId});
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final data = json['data'];
      if (data != null && data['room_id'] != null) {
        return data['room_id'] is int ? data['room_id'] : int.parse(data['room_id'].toString());
      }
    }
    return null;
  }

  Future<List<MessageModel>> getMessages(int roomId, {int? lastId}) async {
    final endpoint = lastId != null && lastId > 0
        ? '/get_messages?room_id=$roomId&last_id=$lastId'
        : '/get_messages?room_id=$roomId';
    final response = await ApiClient.get(endpoint);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List list = json['data'] ?? [];
      return list.map((item) => MessageModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<MessageModel?> sendMessage(int roomId, String messageText) async {
    final response = await ApiClient.post('/send_message', body: {
      'room_id': roomId,
      'message_text': messageText,
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      if (json['data'] != null) {
        return MessageModel.fromJson(json['data']);
      }
    }
    return null;
  }
}
