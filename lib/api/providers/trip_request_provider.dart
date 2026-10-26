import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/api/controllers/trip_controller.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip_request.dart';
import 'package:travel_buddy_finder/features/trips/data/stores/trip_request_store.dart';

class TripRequestProvider with ChangeNotifier {
  final TripController _tripController = TripController();

  List<TripRequest> _pendingRequests = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _errorMessage;

  List<TripRequest> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  int get pendingCount => _pendingRequests.where((r) => r.isPending).length;

  /// 1. GET Pending Requests (/pending_requests)
  Future<List<TripRequest>> fetchPendingRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _tripController.getPendingRequests();
      if (result.success) {
        _pendingRequests = result.requests;
        TripRequestStore.setRequestsFromApi(result.requests);
      } else {
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _pendingRequests;
  }

  /// 2. POST Join Trip (/join_trip)
  Future<({bool success, String message})> joinTrip({
    required dynamic tripId,
    String? message,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final result = await _tripController.joinTrip(
        tripId: tripId,
        message: message,
      );
      return (success: result.success, message: result.message);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// 3. POST Accept Request (/accept_request)
  Future<({bool success, String message})> acceptRequest({
    required dynamic requestId,
    dynamic tripId,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final result = await _tripController.acceptRequest(
        requestId: requestId,
        tripId: tripId,
      );
      if (result.success) {
        TripRequestStore.updateStatus(
          requestId.toString(),
          TripRequestStatus.approved,
        );
        _pendingRequests.removeWhere((r) => r.id == requestId.toString());
        await fetchPendingRequests();
      }
      return (success: result.success, message: result.message);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// 4. POST Reject Request (/reject_request)
  Future<({bool success, String message})> rejectRequest({
    required dynamic requestId,
    dynamic tripId,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final result = await _tripController.rejectRequest(
        requestId: requestId,
        tripId: tripId,
      );
      if (result.success) {
        TripRequestStore.updateStatus(
          requestId.toString(),
          TripRequestStatus.rejected,
        );
        _pendingRequests.removeWhere((r) => r.id == requestId.toString());
        await fetchPendingRequests();
      }
      return (success: result.success, message: result.message);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// 5. POST Respond Request (/respond_request)
  Future<({bool success, String message})> respondRequest({
    required dynamic requestId,
    required String action,
    dynamic tripId,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final result = await _tripController.respondRequest(
        requestId: requestId,
        action: action,
        tripId: tripId,
      );
      if (result.success) {
        final isApproved = action == 'accept' || action == 'accepted';
        TripRequestStore.updateStatus(
          requestId.toString(),
          isApproved ? TripRequestStatus.approved : TripRequestStatus.rejected,
        );
        _pendingRequests.removeWhere((r) => r.id == requestId.toString());
        await fetchPendingRequests();
      }
      return (success: result.success, message: result.message);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
