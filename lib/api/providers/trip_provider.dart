import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/api/controllers/trip_controller.dart';
import 'package:travel_buddy_finder/api/models/trip_model.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip_request.dart';
import 'package:travel_buddy_finder/features/trips/data/stores/trip_request_store.dart';

class TripProvider with ChangeNotifier {
  final TripController _tripController = TripController();

  List<TripModel> _trips = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';

  List<TripRequest> _pendingRequests = [];
  bool _isFetchingRequests = false;

  List<TripModel> get trips => _trips;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  List<TripRequest> get pendingRequests => _pendingRequests;
  bool get isFetchingRequests => _isFetchingRequests;

  Future<void> fetchAllTrips() async {
    _isLoading = true;
    _selectedCategory = 'All';
    notifyListeners();

    _trips = await _tripController.getAllTrips();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTripsByCategory(String category) async {
    if (category.isEmpty || category == 'All') {
      return fetchAllTrips();
    }

    _isLoading = true;
    _selectedCategory = category;
    notifyListeners();

    _trips = await _tripController.getTripsByCategory(category);

    _isLoading = false;
    notifyListeners();
  }

  Future<({bool success, String message})> createTrip({
    required String title,
    required String location,
    required double price,
    required String startDate,
    required String endDate,
    required String category,
    required String description,
    required int seats,
    List<String>? transports,
    List<int>? coverPhotoBytes,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _tripController.createTrip(
      title: title,
      location: location,
      price: price,
      startDate: startDate,
      endDate: endDate,
      category: category,
      description: description,
      seats: seats,
      transports: transports,
      coverPhotoBytes: coverPhotoBytes,
    );

    _isLoading = false;
    if (result.success) {
      await fetchAllTrips();
    } else {
      notifyListeners();
    }

    return (success: result.success, message: result.message);
  }

  Future<({bool success, String message})> updateTrip({
    required int tripId,
    required String title,
    required String location,
    required double price,
    required String startDate,
    required String endDate,
    required String category,
    required String description,
    int? seats,
    List<String>? transports,
    List<int>? coverPhotoBytes,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _tripController.updateTrip(
      tripId: tripId,
      title: title,
      location: location,
      price: price,
      startDate: startDate,
      endDate: endDate,
      category: category,
      description: description,
      seats: seats,
      transports: transports,
      coverPhotoBytes: coverPhotoBytes,
    );

    _isLoading = false;
    if (result.success) {
      await fetchAllTrips();
    } else {
      notifyListeners();
    }

    return (success: result.success, message: result.message);
  }

  Future<({bool success, String message})> deleteTrip(int tripId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _tripController.deleteTrip(tripId);

    _isLoading = false;
    if (result.success) {
      await fetchAllTrips();
    } else {
      notifyListeners();
    }

    return (success: result.success, message: result.message);
  }

  Future<({bool success, String message})> joinTrip({
    required dynamic tripId,
    String? message,
  }) async {
    final result = await _tripController.joinTrip(
      tripId: tripId,
      message: message,
    );
    notifyListeners();
    return (success: result.success, message: result.message);
  }

  Future<({bool success, String message})> acceptRequest({
    required dynamic requestId,
    dynamic tripId,
  }) async {
    final result = await _tripController.acceptRequest(
      requestId: requestId,
      tripId: tripId,
    );
    if (result.success) {
      await fetchAllTrips();
      await fetchPendingRequests();
    } else {
      notifyListeners();
    }
    return (success: result.success, message: result.message);
  }

  Future<({bool success, String message})> rejectRequest({
    required dynamic requestId,
    dynamic tripId,
  }) async {
    final result = await _tripController.rejectRequest(
      requestId: requestId,
      tripId: tripId,
    );
    if (result.success) {
      await fetchPendingRequests();
    } else {
      notifyListeners();
    }
    return (success: result.success, message: result.message);
  }

  Future<({bool success, String message})> respondRequest({
    required dynamic requestId,
    required String action,
    dynamic tripId,
  }) async {
    final result = await _tripController.respondRequest(
      requestId: requestId,
      action: action,
      tripId: tripId,
    );
    if (result.success) {
      if (action == 'accept' || action == 'accepted') {
        await fetchAllTrips();
      }
      await fetchPendingRequests();
    } else {
      notifyListeners();
    }
    return (success: result.success, message: result.message);
  }

  Future<List<TripRequest>> fetchPendingRequests() async {
    _isFetchingRequests = true;
    notifyListeners();

    final result = await _tripController.getPendingRequests();
    _isFetchingRequests = false;

    if (result.success) {
      _pendingRequests = result.requests;
      TripRequestStore.setRequestsFromApi(result.requests);
    }
    notifyListeners();
    return _pendingRequests;
  }
}
