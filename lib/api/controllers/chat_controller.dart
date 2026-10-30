import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:travel_buddy_finder/api/models/chat_room_model.dart';
import 'package:travel_buddy_finder/api/models/message_model.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/core/network/api_client.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';

class ChatController {
  // 1. GET Inbox chat rooms
  Future<List<ChatRoomModel>> getChatRooms() async {
    try {
      final username = CurrentUser.username.replaceAll('@', '').trim();
      final endpoint = username.isNotEmpty
          ? '${AppUrl.chatRooms}?username=$username'
          : AppUrl.chatRooms;

      final response = await ApiClient.get(endpoint);
      debugPrint('Chat Rooms Status: ${response.statusCode}');
      debugPrint('Chat Rooms Body: ${response.body}');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final dynamic json = jsonDecode(response.body);
        List rawList = [];

        if (json is List) {
          rawList = json;
        } else if (json is Map) {
          if (json['data'] is List) {
            rawList = json['data'];
          } else if (json['rooms'] is List) {
            rawList = json['rooms'];
          }
        }

        final List<ChatRoomModel> rooms = [];
        for (final item in rawList) {
          if (item is Map) {
            try {
              final Map<String, dynamic> safeMap = {};
              item.forEach((k, v) => safeMap[k.toString()] = v);
              rooms.add(ChatRoomModel.fromJson(safeMap));
            } catch (e, stack) {
              debugPrint('Skipping malformed room item: $e\n$stack');
            }
          }
        }
        return rooms;
      }
    } catch (e, stack) {
      debugPrint('Get Chat Rooms Error: $e\n$stack');
    }
    return [];
  }

  // 2. POST Start or Retrieve Existing Chat Room
  Future<({bool success, int? roomId, String? tripTitle, String? partnerUsername, String message})>
      startChat(dynamic tripId, {String? partnerUsername}) async {
    try {
      final cleanTripId = tripId.toString().trim();
      final int? intTripId = int.tryParse(cleanTripId);

      final Map<String, dynamic> body = {
        'trip_id': intTripId ?? cleanTripId,
        'tripId': intTripId ?? cleanTripId,
        if (partnerUsername != null && partnerUsername.trim().isNotEmpty) ...{
          'partner_username': partnerUsername.trim().replaceAll('@', ''),
          'traveler_username': partnerUsername.trim().replaceAll('@', ''),
        },
        if (CurrentUser.username.isNotEmpty)
          'username': CurrentUser.username.replaceAll('@', ''),
      };

      debugPrint('=== [POST] /start_chat ===');
      debugPrint('Payload: $body');

      var response = await ApiClient.post(
        AppUrl.startChat,
        body: body,
        isJson: true,
      );

      debugPrint('Start Chat Status: ${response.statusCode}');
      debugPrint('Start Chat Body: ${response.body}');

      // Fallback to form urlencoded if 400
      if (response.statusCode == 400) {
        final formResponse = await ApiClient.post(
          AppUrl.startChat,
          body: body,
          isJson: false,
        );
        if (formResponse.statusCode == 200 || formResponse.statusCode == 201) {
          response = formResponse;
        }
      }

      if (response.body.isEmpty) {
        return (
          success: false,
          roomId: null,
          tripTitle: null,
          partnerUsername: null,
          message: 'Server returned empty response (Status: ${response.statusCode})',
        );
      }

      final dynamic json = jsonDecode(response.body);
      final bool isSuccess = (response.statusCode == 200 || response.statusCode == 201) &&
          (json is Map && (json['status'] == 'success' || json['room_id'] != null || json['data'] != null));

      final String msg = (json is Map && json['message'] != null)
          ? json['message'].toString()
          : (isSuccess ? 'Chat room ready' : 'Failed to start chat');

      int? foundRoomId;
      String? foundTripTitle;
      String? foundPartner;

      if (json is Map) {
        final data = json['data'] is Map ? json['data'] : json;
        final rawRoomId = data['room_id'] ?? data['id'] ?? data['roomId'];
        if (rawRoomId != null) {
          foundRoomId = int.tryParse(rawRoomId.toString());
        }
        foundTripTitle = data['trip_title']?.toString();
        foundPartner = data['host_username']?.toString() ?? data['username']?.toString();
      }

      return (
        success: isSuccess && foundRoomId != null,
        roomId: foundRoomId,
        tripTitle: foundTripTitle,
        partnerUsername: foundPartner,
        message: msg,
      );
    } catch (e, stack) {
      debugPrint('Start Chat Error: $e\n$stack');
      return (
        success: false,
        roomId: null,
        tripTitle: null,
        partnerUsername: null,
        message: 'Network error starting chat: $e',
      );
    }
  }

  // 3. GET Messages for a room (Supports Smart Polling via last_id)
  Future<List<MessageModel>> getMessages(int roomId, {int? lastId}) async {
    try {
      final username = CurrentUser.username.replaceAll('@', '').trim();
      String endpoint = '${AppUrl.getMessages}?room_id=$roomId';
      if (lastId != null && lastId > 0) {
        endpoint += '&last_id=$lastId';
      }
      if (username.isNotEmpty) {
        endpoint += '&username=$username';
      }

      final response = await ApiClient.get(endpoint);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final dynamic json = jsonDecode(response.body);
        List rawList = [];

        if (json is List) {
          rawList = json;
        } else if (json is Map) {
          if (json['data'] is List) {
            rawList = json['data'];
          } else if (json['messages'] is List) {
            rawList = json['messages'];
          }
        }

        final List<MessageModel> msgs = [];
        for (final item in rawList) {
          if (item is Map) {
            try {
              final Map<String, dynamic> safeMap = {};
              item.forEach((k, v) => safeMap[k.toString()] = v);
              msgs.add(MessageModel.fromJson(safeMap));
            } catch (e, stack) {
              debugPrint('Skipping malformed message item: $e\n$stack');
            }
          }
        }
        return msgs;
      }
    } catch (e, stack) {
      debugPrint('Get Messages Error: $e\n$stack');
    }
    return [];
  }

  // 4. POST Send Message
  Future<({bool success, MessageModel? message, String error})> sendMessage(
    int roomId,
    String messageText,
  ) async {
    try {
      final cleanText = messageText.trim();
      if (cleanText.isEmpty) {
        return (
          success: false,
          message: null,
          error: 'Message cannot be empty',
        );
      }

      final Map<String, dynamic> body = {
        'room_id': roomId,
        'message_text': cleanText,
        'message': cleanText,
        if (CurrentUser.username.isNotEmpty)
          'username': CurrentUser.username.replaceAll('@', ''),
      };

      var response = await ApiClient.post(
        AppUrl.sendMessage,
        body: body,
        isJson: true,
      );

      // Fallback to form urlencoded if needed
      if (response.statusCode == 400) {
        final formResponse = await ApiClient.post(
          AppUrl.sendMessage,
          body: body,
          isJson: false,
        );
        if (formResponse.statusCode == 200 || formResponse.statusCode == 201) {
          response = formResponse;
        }
      }

      if (response.body.isNotEmpty) {
        final dynamic json = jsonDecode(response.body);
        final bool isSuccess = (response.statusCode == 200 || response.statusCode == 201) &&
            (json is Map && (json['status'] == 'success' || json['data'] != null));

        if (isSuccess && json['data'] is Map) {
          return (
            success: true,
            message: MessageModel.fromJson(Map<String, dynamic>.from(json['data'])),
            error: '',
          );
        }
      }

      return (
        success: false,
        message: null,
        error: 'Failed to send message (Status: ${response.statusCode})',
      );
    } catch (e, stack) {
      debugPrint('Send Message Error: $e\n$stack');
      return (
        success: false,
        message: null,
        error: 'Network error sending message: $e',
      );
    }
  }
}
