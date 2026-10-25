import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/api/controllers/trip_controller.dart';
import 'package:travel_buddy_finder/api/models/trip_model.dart';

class TripProvider with ChangeNotifier {
  final TripController _tripController = TripController();

  List<TripModel> _trips = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';

  List<TripModel> get trips => _trips;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

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
}
