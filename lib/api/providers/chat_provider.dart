import 'dart:async';
import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/api/controllers/chat_controller.dart';
import 'package:travel_buddy_finder/api/models/chat_room_model.dart';
import 'package:travel_buddy_finder/api/models/message_model.dart';
import 'package:travel_buddy_finder/core/services/in_app_notification_service.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';

class ChatProvider with ChangeNotifier {
  final ChatController _chatController = ChatController();

  // In-memory state
  List<ChatRoomModel> _chatRooms = [];
  List<MessageModel> _messages = [];
  int? _activeRoomId;
  Timer? _roomPollingTimer;
  Timer? _inboxPollingTimer;
  bool _isLoading = false;
  bool _isSending = false;

  // Track latest known message IDs per room for new message detection
  final Map<int, int> _lastKnownLatestMessageIds = {};
  bool _isFirstInboxFetch = true;

  // Real-time broadcast Streams for StreamBuilder integration
  final StreamController<List<MessageModel>> _messageStreamController =
      StreamController<List<MessageModel>>.broadcast();
  final StreamController<List<ChatRoomModel>> _roomsStreamController =
      StreamController<List<ChatRoomModel>>.broadcast();

  // Getters
  List<ChatRoomModel> get chatRooms => List.unmodifiable(_chatRooms);
  List<MessageModel> get messages => List.unmodifiable(_messages);
  int? get activeRoomId => _activeRoomId;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;

  /// Total count of unread messages across all conversations
  int get totalUnreadCount {
    try {
      return _chatRooms.fold<int>(0, (sum, room) => sum + room.unseenCount);
    } catch (_) {
      return 0;
    }
  }

  /// Reactive message stream for Flutter StreamBuilder
  Stream<List<MessageModel>> get messageStream =>
      _messageStreamController.stream;

  /// Reactive chat rooms stream for Flutter StreamBuilder
  Stream<List<ChatRoomModel>> get roomsStream => _roomsStreamController.stream;

  // 1. Fetch all chat rooms for inbox
  Future<void> fetchChatRooms({bool? silent}) async {
    final bool isSilent = silent == true;
    if (!isSilent) {
      _isLoading = true;
      try {
        notifyListeners();
      } catch (_) {}
    }

    try {
      final fetchedRooms = await _chatController.getChatRooms();

      // Check for newly arrived messages to show floating in-app notification
      if (_isFirstInboxFetch == false) {
        for (final room in fetchedRooms) {
          final int? msgId = room.lastMessageId;
          final bool isMine = room.isLastMessageMine == true;
          final String msgText = room.lastMessage;

          if (msgId != null && !isMine && msgText.isNotEmpty) {
            final int lastKnownId =
                _lastKnownLatestMessageIds[room.roomId] ?? 0;
            if (msgId > lastKnownId) {
              // Only trigger notification if user is not currently in this room
              if (_activeRoomId != room.roomId) {
                try {
                  InAppNotificationService.showNotification(
                    room: room,
                    messageText: msgText,
                  );
                } catch (e) {
                  debugPrint('Notification show error: $e');
                }
              }
            }
          }
        }
      } else {
        _isFirstInboxFetch = false;
      }

      // Record latest known message IDs
      for (final room in fetchedRooms) {
        final int? msgId = room.lastMessageId;
        if (msgId != null) {
          _lastKnownLatestMessageIds[room.roomId] = msgId;
        }
      }

      _chatRooms = fetchedRooms;
      try {
        if (!_roomsStreamController.isClosed) {
          _roomsStreamController.add(List.unmodifiable(_chatRooms));
        }
      } catch (streamErr) {
        debugPrint('Stream broadcast error: $streamErr');
      }
    } catch (e, stack) {
      debugPrint('Error fetching chat rooms: $e\n$stack');
    } finally {
      _isLoading = false;
      try {
        notifyListeners();
      } catch (_) {}
    }
  }

  // 2. Start global inbox polling (checks every 5 seconds for new messages)
  void startInboxPolling({Duration interval = const Duration(seconds: 5)}) {
    _inboxPollingTimer?.cancel();
    fetchChatRooms(silent: true);
    _inboxPollingTimer = Timer.periodic(interval, (_) {
      fetchChatRooms(silent: true);
    });
  }

  // Stop global inbox polling
  void stopInboxPolling() {
    _inboxPollingTimer?.cancel();
    _inboxPollingTimer = null;
  }

  // 3. Start or get existing chat room for a trip
  Future<({bool success, int? roomId, String message})> startChat(
    dynamic tripId, {
    String? partnerUsername,
  }) async {
    try {
      final res = await _chatController.startChat(
        tripId,
        partnerUsername: partnerUsername,
      );

      if (res.success && res.roomId != null) {
        // Refresh inbox in background
        fetchChatRooms(silent: true);
        return (
          success: true,
          roomId: res.roomId,
          message: res.message,
        );
      }

      return (
        success: false,
        roomId: null,
        message: res.message,
      );
    } catch (e) {
      return (
        success: false,
        roomId: null,
        message: 'Could not start chat: $e',
      );
    }
  }

  // 4. Enter a chat room & start smart room polling stream
  Future<void> enterChatRoom(int roomId) async {
    _activeRoomId = roomId;
    _isLoading = true;
    _messages = [];
    if (!_messageStreamController.isClosed) {
      _messageStreamController.add([]);
    }
    notifyListeners();

    try {
      _messages = await _chatController.getMessages(roomId);
      if (!_messageStreamController.isClosed) {
        _messageStreamController.add(List.unmodifiable(_messages));
      }

      // After entering, update local room unseenCount to 0 immediately
      final roomIndex = _chatRooms.indexWhere((r) => r.roomId == roomId);
      if (roomIndex >= 0) {
        final current = _chatRooms[roomIndex];
        _chatRooms[roomIndex] = ChatRoomModel(
          roomId: current.roomId,
          tripId: current.tripId,
          partnerName: current.partnerName,
          partnerUsername: current.partnerUsername,
          partnerAvatarUrl: current.partnerAvatarUrl,
          tripTitle: current.tripTitle,
          tripDestination: current.tripDestination,
          tripCoverUrl: current.tripCoverUrl,
          lastMessageId: current.lastMessageId,
          lastMessage: current.lastMessage,
          lastMessageTime: current.lastMessageTime,
          isLastMessageMine: current.isLastMessageMine,
          lastMessageSeenStatus: 1, // marked seen
          unseenCount: 0,
        );
        if (!_roomsStreamController.isClosed) {
          _roomsStreamController.add(List.unmodifiable(_chatRooms));
        }
      }
    } catch (e, stack) {
      debugPrint('Error fetching initial messages: $e\n$stack');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Start smart live polling timer (calls API every 1.8 seconds with last_id)
    _roomPollingTimer?.cancel();
    _roomPollingTimer =
        Timer.periodic(const Duration(milliseconds: 1800), (_) async {
      if (_activeRoomId != roomId) return;
      final int lastId = _messages.isNotEmpty ? _messages.last.messageId : 0;
      await _pollNewMessages(roomId, lastId);
    });
  }

  // Smart polling worker: fetches only messages where id > lastId
  Future<void> _pollNewMessages(int roomId, int lastId) async {
    try {
      final newItems =
          await _chatController.getMessages(roomId, lastId: lastId);
      if (newItems.isNotEmpty && _activeRoomId == roomId) {
        // Filter out any duplicates
        final existingIds = _messages.map((m) => m.messageId).toSet();
        final filteredNew =
            newItems.where((m) => !existingIds.contains(m.messageId)).toList();

        if (filteredNew.isNotEmpty) {
          _messages.addAll(filteredNew);
          if (!_messageStreamController.isClosed) {
            _messageStreamController.add(List.unmodifiable(_messages));
          }

          // Also record latest id
          final latestNewMsgId = filteredNew.last.messageId;
          _lastKnownLatestMessageIds[roomId] = latestNewMsgId;

          notifyListeners();
        }
      }
    } catch (e) {
      // Ignore background network blips silently
    }
  }

  // 5. Send message with Instant Optimistic UI & Stream Notification
  Future<bool> sendMessage(int roomId, String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return false;

    _isSending = true;

    // Generate temporary ID for optimistic bubble
    final int tempId = -DateTime.now().millisecondsSinceEpoch;
    final optimisticMsg = MessageModel(
      messageId: tempId,
      roomId: roomId,
      senderUsername: CurrentUser.username.replaceAll('@', ''),
      senderName: CurrentUser.name,
      senderProfilePicUrl: CurrentUser.avatarUrl,
      messageText: cleanText,
      isMe: true,
      createdAt: 'Just now',
      seenStatus: false,
    );

    // Optimistic push to memory & stream
    _messages.add(optimisticMsg);
    if (!_messageStreamController.isClosed) {
      _messageStreamController.add(List.unmodifiable(_messages));
    }
    notifyListeners();

    try {
      final result = await _chatController.sendMessage(roomId, cleanText);

      if (result.success && result.message != null) {
        final idx = _messages.indexWhere((m) => m.messageId == tempId);
        if (idx >= 0) {
          _messages[idx] = result.message!;
        } else {
          _messages.add(result.message!);
        }
        if (!_messageStreamController.isClosed) {
          _messageStreamController.add(List.unmodifiable(_messages));
        }

        // Update latest known message ID
        _lastKnownLatestMessageIds[roomId] = result.message!.messageId;

        notifyListeners();
        _isSending = false;
        return true;
      } else {
        // Rollback on failure
        _messages.removeWhere((m) => m.messageId == tempId);
        if (!_messageStreamController.isClosed) {
          _messageStreamController.add(List.unmodifiable(_messages));
        }
        notifyListeners();
        _isSending = false;
        return false;
      }
    } catch (e) {
      _messages.removeWhere((m) => m.messageId == tempId);
      if (!_messageStreamController.isClosed) {
        _messageStreamController.add(List.unmodifiable(_messages));
      }
      notifyListeners();
      _isSending = false;
      return false;
    }
  }

  // 6. Exit room and stop stream polling
  void exitChatRoom() {
    _roomPollingTimer?.cancel();
    _roomPollingTimer = null;
    _activeRoomId = null;
    _messages = [];
  }

  @override
  void dispose() {
    _roomPollingTimer?.cancel();
    _inboxPollingTimer?.cancel();
    _messageStreamController.close();
    _roomsStreamController.close();
    super.dispose();
  }
}
