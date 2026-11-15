import 'package:flutter/foundation.dart';
import 'package:travel_buddy_finder/api/controllers/rating_controller.dart';
import 'package:travel_buddy_finder/api/models/rating_model.dart';

class RatingProvider with ChangeNotifier {
  final RatingController _controller = RatingController();

  final Map<int, TripRatingDetail> _ratingCache = {};
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TripRatingDetail? getRatingForTrip(int tripId) => _ratingCache[tripId];

  // 1. Fetch live rating stats from backend
  Future<TripRatingDetail?> fetchRating(int tripId, {bool notify = true}) async {
    _isLoading = true;
    _errorMessage = null;
    if (notify) notifyListeners();

    final detail = await _controller.getTripRating(tripId);
    _isLoading = false;

    if (detail != null) {
      _ratingCache[tripId] = detail;
    }
    if (notify) notifyListeners();
    return detail;
  }

  // 2. Submit new rating to backend
  Future<RatingResult> submitRating({
    required int tripId,
    required int rating,
    bool autoUpdateIfAlreadyRated = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    RatingResult result = await _controller.rateTrip(
      tripId: tripId,
      rating: rating,
    );

    // If already rated (HTTP 409), automatically fall back to editRating if enabled
    if (!result.success && result.statusCode == 409 && autoUpdateIfAlreadyRated) {
      result = await _controller.editRating(
        tripId: tripId,
        rating: rating,
      );
    }

    _isLoading = false;

    if (result.success) {
      // Refresh cache for this trip
      await fetchRating(tripId, notify: false);
    } else {
      _errorMessage = result.message;
    }

    notifyListeners();
    return result;
  }

  // 3. Edit existing rating in backend
  Future<RatingResult> updateRating({
    required int tripId,
    required int rating,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _controller.editRating(
      tripId: tripId,
      rating: rating,
    );

    _isLoading = false;

    if (result.success) {
      await fetchRating(tripId, notify: false);
    } else {
      _errorMessage = result.message;
    }

    notifyListeners();
    return result;
  }
}
