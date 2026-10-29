import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/api/controllers/bookmark_controller.dart';
import 'package:travel_buddy_finder/api/models/bookmark_model.dart';
import 'package:travel_buddy_finder/features/bookmarks/data/bookmark_store.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip.dart';

class BookmarkProvider with ChangeNotifier {
  static BookmarkProvider? _instance;
  static BookmarkProvider? get instance => _instance;

  final BookmarkController _bookmarkController = BookmarkController();

  // Internal state
  final List<BookmarkModel> _bookmarks = [];
  final Set<String> _bookmarkedTripIds = <String>{};
  final Set<String> _pendingTripIds = <String>{};
  List<Trip> _savedTrips = [];

  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  BookmarkProvider() {
    _instance = this;
  }

  // Getters with immutable views for memory safety
  UnmodifiableListView<BookmarkModel> get bookmarks =>
      UnmodifiableListView(_bookmarks);
  UnmodifiableListView<Trip> get savedTrips =>
      UnmodifiableListView(_savedTrips);
  UnmodifiableSetView<String> get bookmarkedTripIds =>
      UnmodifiableSetView(_bookmarkedTripIds);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get count => _savedTrips.length;

  /// O(1) fast lookup to check if a trip is bookmarked
  bool isBookmarked(dynamic tripId) {
    if (tripId == null) return false;
    return _bookmarkedTripIds.contains(tripId.toString().trim());
  }

  /// Check if a bookmark action is currently in flight for this trip
  bool isPending(dynamic tripId) {
    if (tripId == null) return false;
    return _pendingTripIds.contains(tripId.toString().trim());
  }

  void _safeNotifyListeners() {
    if (!_disposed && hasListeners) {
      notifyListeners();
    }
  }

  /// Syncs cached trips and updates external static BookmarkStore
  void _syncState() {
    // Reconstruct cached Trip list efficiently
    _savedTrips = _bookmarks.map((b) => b.toTrip()).toList();

    // Sync static BookmarkStore for 100% backward compatibility
    BookmarkStore.syncWithProvider(_savedTrips);
  }

  // 1. GET /my_bookmarks
  Future<void> fetchMyBookmarks({bool silent = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    if (!silent) {
      _safeNotifyListeners();
    }

    try {
      final fetched = await _bookmarkController.getMyBookmarks();

      _bookmarks.clear();
      _bookmarkedTripIds.clear();

      for (final item in fetched) {
        _bookmarks.add(item);
        final String tId = item.tripId.toString();
        if (tId.isNotEmpty && tId != '0') {
          _bookmarkedTripIds.add(tId);
        }
      }

      _syncState();
    } catch (e) {
      _errorMessage = 'Failed to load bookmarks: $e';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // 2. TOGGLE Bookmark with Optimistic UI & In-Flight Deduplication
  Future<({bool success, String message, bool isBookmarked})> toggleBookmark(
    dynamic tripOrId, {
    Trip? trip,
  }) async {
    String cleanId;
    Trip? tripObj;

    if (tripOrId is Trip) {
      tripObj = tripOrId;
      cleanId = tripOrId.id.trim();
    } else {
      cleanId = tripOrId.toString().trim();
      tripObj = trip;
    }

    if (cleanId.isEmpty || cleanId == '0') {
      return (
        success: false,
        message: 'Invalid trip ID',
        isBookmarked: false,
      );
    }

    // Debounce / in-flight protection to avoid duplicate parallel requests
    if (_pendingTripIds.contains(cleanId)) {
      return (
        success: false,
        message: 'Action in progress...',
        isBookmarked: isBookmarked(cleanId),
      );
    }

    _pendingTripIds.add(cleanId);
    final bool wasBookmarked = isBookmarked(cleanId);
    final int existingIndex = _bookmarks.indexWhere(
      (b) => b.tripId.toString() == cleanId || b.id.toString() == cleanId,
    );
    final BookmarkModel? backupModel =
        existingIndex >= 0 ? _bookmarks[existingIndex] : null;

    // --- OPTIMISTIC UPDATE ---
    if (wasBookmarked) {
      _bookmarkedTripIds.remove(cleanId);
      if (existingIndex >= 0) {
        _bookmarks.removeAt(existingIndex);
      }
    } else {
      _bookmarkedTripIds.add(cleanId);
      if (tripObj != null) {
        _bookmarks.insert(0, BookmarkModel.fromTrip(tripObj));
      } else {
        final parsed = int.tryParse(cleanId) ?? 0;
        _bookmarks.insert(0, BookmarkModel(id: parsed, tripId: parsed));
      }
    }
    _syncState();
    _safeNotifyListeners();

    // --- CALL BACKEND API ---
    if (wasBookmarked) {
      final result = await _bookmarkController.removeBookmark(
        cleanId,
        bookmarkId: backupModel?.id,
      );

      _pendingTripIds.remove(cleanId);

      if (result.success) {
        _safeNotifyListeners();
        return (
          success: true,
          message: result.message,
          isBookmarked: false,
        );
      } else {
        // ROLLBACK
        _bookmarkedTripIds.add(cleanId);
        if (backupModel != null) {
          _bookmarks.insert(
            existingIndex.clamp(0, _bookmarks.length),
            backupModel,
          );
        } else if (tripObj != null) {
          _bookmarks.add(BookmarkModel.fromTrip(tripObj));
        }
        _syncState();
        _safeNotifyListeners();
        return (
          success: false,
          message: result.message,
          isBookmarked: true,
        );
      }
    } else {
      final result = await _bookmarkController.addBookmark(cleanId);

      _pendingTripIds.remove(cleanId);

      if (result.success) {
        if (result.bookmarkId != null && _bookmarks.isNotEmpty) {
          final idx = _bookmarks.indexWhere(
            (b) => b.tripId.toString() == cleanId,
          );
          if (idx >= 0) {
            final current = _bookmarks[idx];
            _bookmarks[idx] = BookmarkModel(
              id: result.bookmarkId!,
              tripId: current.tripId,
              userId: current.userId,
              createdAt: current.createdAt,
              tripModel: current.tripModel,
              cachedTrip: current.cachedTrip,
            );
          }
        }
        _safeNotifyListeners();
        return (
          success: true,
          message: result.message,
          isBookmarked: true,
        );
      } else {
        // ROLLBACK
        _bookmarkedTripIds.remove(cleanId);
        _bookmarks.removeWhere((b) => b.tripId.toString() == cleanId);
        _syncState();
        _safeNotifyListeners();
        return (
          success: false,
          message: result.message,
          isBookmarked: false,
        );
      }
    }
  }

  // 3. Explicit Add Bookmark
  Future<({bool success, String message})> addBookmark(
    dynamic tripId, {
    Trip? trip,
  }) async {
    final cleanId = tripId.toString().trim();
    if (isBookmarked(cleanId)) {
      return (success: true, message: 'Trip already bookmarked');
    }
    final res = await toggleBookmark(trip ?? cleanId, trip: trip);
    return (success: res.success, message: res.message);
  }

  // 4. Explicit Remove Bookmark
  Future<({bool success, String message})> removeBookmark(
    dynamic tripId,
  ) async {
    final cleanId = tripId.toString().trim();
    if (!isBookmarked(cleanId)) {
      return (success: true, message: 'Trip is not bookmarked');
    }
    final res = await toggleBookmark(cleanId);
    return (success: res.success, message: res.message);
  }

  /// Clears in-memory data on logout to free RAM
  void clear() {
    _bookmarks.clear();
    _bookmarkedTripIds.clear();
    _pendingTripIds.clear();
    _savedTrips.clear();
    _errorMessage = null;
    _isLoading = false;
    _syncState();
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
