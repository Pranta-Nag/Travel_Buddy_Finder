import 'dart:convert';
import 'package:travel_buddy_finder/api/models/chat_room_model.dart';
import 'package:travel_buddy_finder/api/models/message_model.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/core/network/api_client.dart';

class ChatController {
  Future<List<ChatRoomModel>> getChatRooms() async {
    final response = await ApiClient.get(AppUrl.chatRooms);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List list = json['data'] ?? [];
      return list.map((item) => ChatRoomModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<int?> startChat(int tripId) async {
    final response = await ApiClient.post(AppUrl.startChat, body: {'trip_id': tripId});
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
        ? '${AppUrl.getMessages}?room_id=$roomId&last_id=$lastId'
        : '${AppUrl.getMessages}?room_id=$roomId';
    final response = await ApiClient.get(endpoint);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List list = json['data'] ?? [];
      return list.map((item) => MessageModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<MessageModel?> sendMessage(int roomId, String messageText) async {
    final response = await ApiClient.post(AppUrl.sendMessage, body: {
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
