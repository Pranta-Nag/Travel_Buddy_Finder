import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:travel_buddy_finder/api/models/rating_model.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/core/network/api_client.dart';

class RatingController {
  // 1. POST Rate Trip (/rate_trip)
  Future<RatingResult> rateTrip({
    required int tripId,
    required int rating,
  }) async {
    try {
      final response = await ApiClient.post(
        AppUrl.rateTrip,
        body: {
          'trip_id': tripId,
          'rating': rating,
        },
        isJson: true,
      );

      debugPrint('Rate Trip Status: ${response.statusCode}');
      debugPrint('Rate Trip Body: ${response.body}');

      final dynamic data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      final String message = data is Map ? (data['message']?.toString() ?? '') : '';

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = data is Map && data['data'] is Map ? data['data'] : {};
        return RatingResult(
          success: true,
          statusCode: response.statusCode,
          message: message.isNotEmpty ? message : 'Trip rated successfully!',
          rating: rating,
          averageRating: resData['average_rating'] != null
              ? (resData['average_rating'] as num).toDouble()
              : null,
          totalRatings: resData['total_ratings'] != null
              ? (resData['total_ratings'] as num).toInt()
              : null,
        );
      }

      final existingRating = data is Map && data['existing_rating'] != null
          ? int.tryParse(data['existing_rating'].toString())
          : null;

      return RatingResult(
        success: false,
        statusCode: response.statusCode,
        message: message.isNotEmpty ? message : 'Failed to submit rating (HTTP ${response.statusCode})',
        existingRating: existingRating,
      );
    } catch (e) {
      debugPrint('Rate Trip Exception: $e');
      return RatingResult(
        success: false,
        message: 'Network error submitting rating: $e',
      );
    }
  }

  // 2. POST Edit Rating (/edit_rating)
  Future<RatingResult> editRating({
    required int tripId,
    required int rating,
  }) async {
    try {
      final response = await ApiClient.post(
        AppUrl.editRating,
        body: {
          'trip_id': tripId,
          'rating': rating,
        },
        isJson: true,
      );

      debugPrint('Edit Rating Status: ${response.statusCode}');
      debugPrint('Edit Rating Body: ${response.body}');

      final dynamic data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      final String message = data is Map ? (data['message']?.toString() ?? '') : '';

      if (response.statusCode == 200) {
        final resData = data is Map && data['data'] is Map ? data['data'] : {};
        return RatingResult(
          success: true,
          statusCode: response.statusCode,
          message: message.isNotEmpty ? message : 'Rating updated successfully!',
          rating: rating,
          averageRating: resData['average_rating'] != null
              ? (resData['average_rating'] as num).toDouble()
              : null,
          totalRatings: resData['total_ratings'] != null
              ? (resData['total_ratings'] as num).toInt()
              : null,
        );
      }

      return RatingResult(
        success: false,
        statusCode: response.statusCode,
        message: message.isNotEmpty ? message : 'Failed to update rating (HTTP ${response.statusCode})',
      );
    } catch (e) {
      debugPrint('Edit Rating Exception: $e');
      return RatingResult(
        success: false,
        message: 'Network error updating rating: $e',
      );
    }
  }

  // 3. GET Trip Rating Breakdown & Stats (/get_rating?trip_id=X)
  Future<TripRatingDetail?> getTripRating(int tripId) async {
    try {
      final response = await ApiClient.get('${AppUrl.getRating}?trip_id=$tripId');
      debugPrint('Get Rating Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final dynamic data = jsonDecode(response.body);
        if (data is Map && data['data'] is Map) {
          return TripRatingDetail.fromJson(Map<String, dynamic>.from(data['data']));
        } else if (data is Map) {
          return TripRatingDetail.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      debugPrint('Get Rating Exception: $e');
    }
    return null;
  }
}
