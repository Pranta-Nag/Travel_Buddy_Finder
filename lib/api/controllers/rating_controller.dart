import 'dart:convert';
import 'package:travel_buddy_finder/api/models/rating_model.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/core/network/api_client.dart';

class RatingController {
  // 1. GET Rating Details for a Trip (/get_rating?trip_id=X)
  Future<TripRatingModel?> getRating(dynamic tripId) async {
    try {
      final cleanId = tripId.toString().trim();
      if (cleanId.isEmpty || cleanId == '0') return null;

      final response = await ApiClient.get('${AppUrl.getRating}?trip_id=$cleanId');
      print('Get Rating Status: ${response.statusCode}');
      print('Get Rating Body: ${response.body}');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final dynamic data = jsonDecode(response.body);
        if (data is Map && data['data'] is Map) {
          return TripRatingModel.fromJson(Map<String, dynamic>.from(data['data']));
        }
      }
    } catch (e) {
      print('Get Rating Error: $e');
    }
    return null;
  }

  // 2. POST Rate Trip (/rate_trip)
  Future<({bool success, String message, dynamic data, bool isAlreadyRated})> rateTrip({
    required dynamic tripId,
    required int rating,
  }) async {
    try {
      final int parsedId = int.tryParse(tripId.toString().trim()) ?? 0;
      if (parsedId <= 0) {
        return (
          success: false,
          message: 'Invalid trip ID',
          data: null,
          isAlreadyRated: false,
        );
      }

      final Map<String, dynamic> body = {
        'trip_id': parsedId,
        'rating': rating,
      };

      final response = await ApiClient.post(
        AppUrl.rateTrip,
        body: body,
        isJson: true,
      );

      print('Rate Trip Status: ${response.statusCode}');
      print('Rate Trip Body: ${response.body}');

      dynamic responseData;
      if (response.body.isNotEmpty) {
        try {
          responseData = jsonDecode(response.body);
        } catch (_) {}
      }

      final String message = (responseData is Map && responseData['message'] != null)
          ? responseData['message'].toString()
          : 'Trip rating response (${response.statusCode})';

      if (response.statusCode == 200 || response.statusCode == 201) {
        return (
          success: true,
          message: message,
          data: responseData is Map ? responseData['data'] : null,
          isAlreadyRated: false,
        );
      }

      // Status 409 means the user already rated this trip
      if (response.statusCode == 409) {
        return (
          success: false,
          message: message,
          data: responseData,
          isAlreadyRated: true,
        );
      }

      return (
        success: false,
        message: message,
        data: null,
        isAlreadyRated: false,
      );
    } catch (e) {
      print('Rate Trip Error: $e');
      return (
        success: false,
        message: 'Network error rating trip: $e',
        data: null,
        isAlreadyRated: false,
      );
    }
  }

  // 3. POST Edit Rating (/edit_rating)
  Future<({bool success, String message, dynamic data})> editRating({
    required dynamic tripId,
    required int rating,
  }) async {
    try {
      final int parsedId = int.tryParse(tripId.toString().trim()) ?? 0;
      if (parsedId <= 0) {
        return (
          success: false,
          message: 'Invalid trip ID',
          data: null,
        );
      }

      final Map<String, dynamic> body = {
        'trip_id': parsedId,
        'rating': rating,
      };

      final response = await ApiClient.post(
        AppUrl.editRating,
        body: body,
        isJson: true,
      );

      print('Edit Rating Status: ${response.statusCode}');
      print('Edit Rating Body: ${response.body}');

      dynamic responseData;
      if (response.body.isNotEmpty) {
        try {
          responseData = jsonDecode(response.body);
        } catch (_) {}
      }

      final String message = (responseData is Map && responseData['message'] != null)
          ? responseData['message'].toString()
          : 'Edit rating response (${response.statusCode})';

      if (response.statusCode == 200 || response.statusCode == 201) {
        return (
          success: true,
          message: message,
          data: responseData is Map ? responseData['data'] : null,
        );
      }

      return (
        success: false,
        message: message,
        data: null,
      );
    } catch (e) {
      print('Edit Rating Error: $e');
      return (
        success: false,
        message: 'Network error editing rating: $e',
        data: null,
      );
    }
  }

  // 4. Combined submitOrUpdate (calls rate_trip, or edit_rating if already rated)
  Future<({bool success, String message, dynamic data})> submitOrUpdateRating({
    required dynamic tripId,
    required int rating,
  }) async {
    final rateResult = await rateTrip(tripId: tripId, rating: rating);
    if (rateResult.success) {
      return (
        success: true,
        message: rateResult.message,
        data: rateResult.data,
      );
    }

    if (rateResult.isAlreadyRated) {
      // User has rated previously, update via edit_rating
      return await editRating(tripId: tripId, rating: rating);
    }

    return (
      success: false,
      message: rateResult.message,
      data: rateResult.data,
    );
  }
}
