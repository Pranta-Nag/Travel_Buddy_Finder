import 'package:flutter/foundation.dart';
import 'package:travel_buddy_finder/api/controllers/rating_controller.dart';
import 'package:travel_buddy_finder/api/models/rating_model.dart';
import 'package:travel_buddy_finder/features/trips/data/stores/trip_store.dart';

class RatingProvider with ChangeNotifier {
  final RatingController _ratingController = RatingController();

  final Map<int, TripRatingModel> _ratings = {};
  bool _isLoading = false;
  String? _errorMessage;

  Map<int, TripRatingModel> get ratings => Map.unmodifiable(_ratings);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TripRatingModel? getRatingForTrip(dynamic tripId) {
    final id = int.tryParse(tripId.toString().trim()) ?? 0;
    return _ratings[id];
  }

  Future<TripRatingModel?> fetchRating(dynamic tripId) async {
    final id = int.tryParse(tripId.toString().trim()) ?? 0;
    if (id <= 0) return null;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _ratingController.getRating(id);

    _isLoading = false;
    if (result != null) {
      _ratings[id] = result;
    }
    notifyListeners();
    return result;
  }

  Future<({bool success, String message, dynamic data})> submitRating({
    required dynamic tripId,
    required int rating,
  }) async {
    final id = int.tryParse(tripId.toString().trim()) ?? 0;
    if (id <= 0) {
      return (success: false, message: 'Invalid trip ID', data: null);
    }

    _isLoading = true;
    notifyListeners();

    final result = await _ratingController.submitOrUpdateRating(
      tripId: id,
      rating: rating,
    );

    if (result.success) {
      // Re-fetch latest rating aggregates from backend
      final updatedRating = await _ratingController.getRating(id);
      if (updatedRating != null) {
        _ratings[id] = updatedRating;

        // Update in-memory Trip in TripStore if present
        final stringId = id.toString();
        final tripIndex = TripStore.trips.indexWhere((t) => t.id == stringId);
        if (tripIndex != -1) {
          final oldTrip = TripStore.trips[tripIndex];
          final updatedTrip = oldTrip.copyWith(
            rating: updatedRating.averageRating.toStringAsFixed(1),
          );
          TripStore.update(updatedTrip);
        }
      }
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }
}
