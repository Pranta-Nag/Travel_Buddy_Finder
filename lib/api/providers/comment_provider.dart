import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/api/controllers/comment_controller.dart';
import 'package:travel_buddy_finder/api/models/comment_model.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';

class CommentProvider with ChangeNotifier {
  static CommentProvider? _instance;
  static CommentProvider? get instance => _instance;

  final CommentController _controller = CommentController();

  // In-memory cache mapped by trip_id for O(1) lookups & memory efficiency
  final Map<String, List<CommentItem>> _commentsByTripId = {};
  final Map<String, bool> _isLoadingByTrip = {};
  final Map<String, String?> _errorsByTrip = {};

  // In-flight deduplication sets
  final Set<String> _pendingCommentTripIds = <String>{};
  final Set<String> _pendingReplyCommentIds = <String>{};

  bool _disposed = false;

  CommentProvider() {
    _instance = this;
  }

  /// Get immutable view of comments for a specific trip
  UnmodifiableListView<CommentItem> getCommentsForTrip(dynamic tripId) {
    if (tripId == null) return UnmodifiableListView([]);
    final cleanId = tripId.toString().trim();
    return UnmodifiableListView(_commentsByTripId[cleanId] ?? []);
  }

  bool isLoading(dynamic tripId) {
    if (tripId == null) return false;
    return _isLoadingByTrip[tripId.toString().trim()] ?? false;
  }

  String? getError(dynamic tripId) {
    if (tripId == null) return null;
    return _errorsByTrip[tripId.toString().trim()];
  }

  bool isCommentSubmitting(dynamic tripId) {
    if (tripId == null) return false;
    return _pendingCommentTripIds.contains(tripId.toString().trim());
  }

  bool isReplySubmitting(dynamic commentId) {
    if (commentId == null) return false;
    return _pendingReplyCommentIds.contains(commentId.toString().trim());
  }

  int getCommentCount(dynamic tripId) {
    if (tripId == null) return 0;
    final cleanId = tripId.toString().trim();
    return _commentsByTripId[cleanId]?.length ?? 0;
  }

  void _safeNotifyListeners() {
    if (!_disposed && hasListeners) {
      notifyListeners();
    }
  }

  // 1. GET /get_comments?trip_id=4
  Future<void> fetchComments(
    dynamic tripId, {
    bool silent = false,
    bool forceRefresh = false,
  }) async {
    final cleanTripId = tripId.toString().trim();
    if (cleanTripId.isEmpty) return;

    // Return cached data if already fetched and not forced
    if (!forceRefresh && _commentsByTripId.containsKey(cleanTripId)) {
      if (!silent) _safeNotifyListeners();
      return;
    }

    if (!silent) {
      _isLoadingByTrip[cleanTripId] = true;
      _errorsByTrip[cleanTripId] = null;
      _safeNotifyListeners();
    }

    try {
      final fetched = await _controller.getComments(cleanTripId);
      _commentsByTripId[cleanTripId] = fetched;
      _errorsByTrip[cleanTripId] = null;
    } catch (e) {
      _errorsByTrip[cleanTripId] = 'Failed to load comments: $e';
    } finally {
      _isLoadingByTrip[cleanTripId] = false;
      _safeNotifyListeners();
    }
  }

  // 2. POST /add_comment with Optimistic UI & Rollback
  Future<({bool success, String message, CommentItem? comment})> addComment({
    required dynamic tripId,
    required String comment,
  }) async {
    final cleanTripId = tripId.toString().trim();
    final cleanComment = comment.trim();

    if (cleanTripId.isEmpty || cleanComment.isEmpty) {
      return (
        success: false,
        message: 'Trip ID and comment are required',
        comment: null,
      );
    }

    // Deduplication check
    if (_pendingCommentTripIds.contains(cleanTripId)) {
      return (
        success: false,
        message: 'A comment is already being posted...',
        comment: null,
      );
    }

    _pendingCommentTripIds.add(cleanTripId);

    // Prepare optimistic comment
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticComment = CommentItem(
      id: tempId,
      tripId: cleanTripId,
      name: CurrentUser.name,
      username: CurrentUser.username,
      text: cleanComment,
      time: 'Just now',
      avatarUrl: CurrentUser.avatarUrl,
      isLiked: false,
      likesCount: 0,
      replies: [],
    );

    // --- OPTIMISTIC UPDATE ---
    _commentsByTripId.putIfAbsent(cleanTripId, () => []);
    _commentsByTripId[cleanTripId]!.insert(0, optimisticComment);
    _safeNotifyListeners();

    try {
      // --- CALL BACKEND API ---
      final result = await _controller.addComment(
        tripId: cleanTripId,
        comment: cleanComment,
      );

      if (result.success) {
        // Replace optimistic comment with server-returned version
        final list = _commentsByTripId[cleanTripId];
        if (list != null) {
          final idx = list.indexWhere((c) => c.id == tempId);
          if (idx >= 0) {
            list[idx] = result.comment ??
                CommentItem(
                  id: result.data?['id']?.toString() ??
                      result.data?['comment_id']?.toString() ??
                      tempId,
                  tripId: cleanTripId,
                  name: CurrentUser.name,
                  username: CurrentUser.username,
                  text: cleanComment,
                  time: 'Just now',
                  avatarUrl: CurrentUser.avatarUrl,
                  isLiked: false,
                  likesCount: 0,
                  replies: [],
                );
          }
        }
        _safeNotifyListeners();

        // Re-fetch in background to sync real MySQL auto-increment IDs
        fetchComments(cleanTripId, silent: true, forceRefresh: true);
        return (
          success: true,
          message: result.message,
          comment: result.comment,
        );
      } else {
        // --- ROLLBACK ON FAILURE ---
        final list = _commentsByTripId[cleanTripId];
        if (list != null) {
          list.removeWhere((c) => c.id == tempId);
        }
        _safeNotifyListeners();
        return (
          success: false,
          message: result.message,
          comment: null,
        );
      }
    } catch (e) {
      final list = _commentsByTripId[cleanTripId];
      if (list != null) {
        list.removeWhere((c) => c.id == tempId);
      }
      _safeNotifyListeners();
      return (
        success: false,
        message: 'Failed to post comment: $e',
        comment: null,
      );
    } finally {
      _pendingCommentTripIds.remove(cleanTripId);
    }
  }

  // 3. POST /reply_comment with Optimistic UI & Rollback
  Future<({bool success, String message, CommentReply? reply})> replyComment({
    required dynamic commentId,
    required String reply,
    dynamic tripId,
  }) async {
    final cleanCommentId = commentId.toString().trim();
    final cleanReply = reply.trim();

    if (cleanCommentId.isEmpty || cleanReply.isEmpty) {
      return (
        success: false,
        message: 'Comment ID and reply are required',
        reply: null,
      );
    }

    if (_pendingReplyCommentIds.contains(cleanCommentId)) {
      return (
        success: false,
        message: 'A reply is already being posted...',
        reply: null,
      );
    }

    _pendingReplyCommentIds.add(cleanCommentId);

    // Locate parent CommentItem across trip caches
    CommentItem? parentComment;
    String? matchedTripId = tripId?.toString().trim();

    if (matchedTripId != null && _commentsByTripId.containsKey(matchedTripId)) {
      final list = _commentsByTripId[matchedTripId]!;
      final idx = list.indexWhere((c) => c.id == cleanCommentId);
      if (idx >= 0) parentComment = list[idx];
    } else {
      for (final entry in _commentsByTripId.entries) {
        final idx = entry.value.indexWhere((c) => c.id == cleanCommentId);
        if (idx >= 0) {
          parentComment = entry.value[idx];
          matchedTripId = entry.key;
          break;
        }
      }
    }

    final tempReplyId = 'temp_rep_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticReply = CommentReply(
      id: tempReplyId,
      commentId: cleanCommentId,
      name: CurrentUser.name,
      username: CurrentUser.username,
      text: cleanReply,
      time: 'Just now',
      avatarUrl: CurrentUser.avatarUrl,
      isLiked: false,
      likesCount: 0,
    );

    // --- OPTIMISTIC UPDATE ---
    parentComment?.addReply(optimisticReply);
    _safeNotifyListeners();

    try {
      // --- CALL BACKEND API ---
      final result = await _controller.replyComment(
        commentId: cleanCommentId,
        reply: cleanReply,
        tripId: matchedTripId,
      );

      if (result.success) {
        if (parentComment != null) {
          final idx =
              parentComment.replies.indexWhere((r) => r.id == tempReplyId);
          if (idx >= 0) {
            parentComment.replies[idx] = result.reply ??
                CommentReply(
                  id: result.data?['id']?.toString() ??
                      result.data?['reply_id']?.toString() ??
                      tempReplyId,
                  commentId: cleanCommentId,
                  name: CurrentUser.name,
                  username: CurrentUser.username,
                  text: cleanReply,
                  time: 'Just now',
                  avatarUrl: CurrentUser.avatarUrl,
                  isLiked: false,
                  likesCount: 0,
                );
          }
        }
        _safeNotifyListeners();

        // Re-fetch comments to sync newly inserted replies directly from server
        if (matchedTripId != null) {
          fetchComments(matchedTripId, silent: true, forceRefresh: true);
        }

        return (
          success: true,
          message: result.message,
          reply: result.reply,
        );
      } else {
        // --- ROLLBACK ON FAILURE ---
        parentComment?.replies.removeWhere((r) => r.id == tempReplyId);
        _safeNotifyListeners();
        return (
          success: false,
          message: result.message,
          reply: null,
        );
      }
    } catch (e) {
      parentComment?.replies.removeWhere((r) => r.id == tempReplyId);
      _safeNotifyListeners();
      return (
        success: false,
        message: 'Failed to post reply: $e',
        reply: null,
      );
    } finally {
      _pendingReplyCommentIds.remove(cleanCommentId);
    }
  }

  /// Manually populate initial or sample comments for a trip (useful for testing or prefetch)
  void setInitialComments(dynamic tripId, List<CommentItem> initialComments) {
    final cleanTripId = tripId.toString().trim();
    if (cleanTripId.isEmpty) return;
    if (!_commentsByTripId.containsKey(cleanTripId)) {
      _commentsByTripId[cleanTripId] = List.from(initialComments);
      _safeNotifyListeners();
    }
  }

  /// Purges in-memory cached comments for a trip to free RAM
  void clearForTrip(dynamic tripId) {
    if (tripId == null) return;
    final cleanId = tripId.toString().trim();
    _commentsByTripId.remove(cleanId);
    _isLoadingByTrip.remove(cleanId);
    _errorsByTrip.remove(cleanId);
    _pendingCommentTripIds.remove(cleanId);
    _safeNotifyListeners();
  }

  /// Clears all in-memory comment caches on user logout
  void clear() {
    _commentsByTripId.clear();
    _isLoadingByTrip.clear();
    _errorsByTrip.clear();
    _pendingCommentTripIds.clear();
    _pendingReplyCommentIds.clear();
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_instance == this) {
      _instance = null;
    }
    super.dispose();
  }
}
