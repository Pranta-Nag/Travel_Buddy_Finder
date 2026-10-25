import 'dart:async';
import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/api/controllers/chat_controller.dart';
import 'package:travel_buddy_finder/api/models/chat_room_model.dart';
import 'package:travel_buddy_finder/api/models/message_model.dart';

class ChatProvider with ChangeNotifier {
  final ChatController _chatController = ChatController();

  List<ChatRoomModel> _chatRooms = [];
  List<MessageModel> _messages = [];
  Timer? _pollingTimer;
  bool _isLoading = false;

  List<ChatRoomModel> get chatRooms => _chatRooms;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> fetchChatRooms() async {
    _isLoading = true;
    notifyListeners();
    try {
      _chatRooms = await _chatController.getChatRooms();
    } catch (e) {
      debugPrint('Error fetching chat rooms: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> enterChatRoom(int roomId) async {
    _isLoading = true;
    _messages = [];
    notifyListeners();

    try {
      _messages = await _chatController.getMessages(roomId);
    } catch (e) {
      debugPrint('Error fetching initial messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final int lastId = _messages.isNotEmpty ? _messages.last.messageId : 0;
      await _pollNewMessages(roomId, lastId);
    });
  }

  Future<void> _pollNewMessages(int roomId, int lastId) async {
    try {
      final newItems = await _chatController.getMessages(roomId, lastId: lastId);
      if (newItems.isNotEmpty) {
        _messages.addAll(newItems);
        notifyListeners();
      }
    } catch (e) {
      // Ignore polling connection errors silently
    }
  }

  Future<bool> sendMessage(int roomId, String text) async {
    if (text.trim().isEmpty) return false;
    try {
      final sentMsg = await _chatController.sendMessage(roomId, text.trim());
      if (sentMsg != null) {
        _messages.add(sentMsg);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
    return false;
  }

  void exitChatRoom() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _messages = [];
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
