import 'dart:convert';
import 'package:travel_buddy_finder/api/models/bookmark_model.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/core/network/api_client.dart';

class BookmarkController {
  // 1. GET My Bookmarks (/my_bookmarks)
  Future<List<BookmarkModel>> getMyBookmarks() async {
    try {
      final response = await ApiClient.get(AppUrl.myBookmarks);
      print('My Bookmarks Status: ${response.statusCode}');
      print('My Bookmarks Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];

        final dynamic data = jsonDecode(response.body);
        List rawList = [];

        if (data is List) {
          rawList = data;
        } else if (data is Map) {
          if (data['data'] is List) {
            rawList = data['data'];
          } else if (data['bookmarks'] is List) {
            rawList = data['bookmarks'];
          } else if (data['my_bookmarks'] is List) {
            rawList = data['my_bookmarks'];
          } else if (data['trips'] is List) {
            rawList = data['trips'];
          } else if (data['data'] is Map && data['data']['bookmarks'] is List) {
            rawList = data['data']['bookmarks'];
          }
        }

        return rawList
            .whereType<Map>()
            .map((item) => BookmarkModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      print('Get My Bookmarks Error: $e');
    }
    return [];
  }

  // 2. POST Add Bookmark (/add_bookmark)
  Future<({bool success, String message, dynamic data, int? bookmarkId})> addBookmark(
    dynamic tripId,
  ) async {
    try {
      final String cleanTripId = tripId.toString().trim();
      if (cleanTripId.isEmpty || cleanTripId == '0') {
        return (
          success: false,
          message: 'Invalid trip ID',
          data: null,
          bookmarkId: null,
        );
      }

      final Map<String, dynamic> body = {
        'trip_id': cleanTripId,
        'tripId': cleanTripId,
        'id': cleanTripId,
        if (int.tryParse(cleanTripId) != null) 'trip_id_int': int.parse(cleanTripId),
      };

      var response = await ApiClient.post(
        AppUrl.addBookmark,
        body: body,
        isJson: true,
      );

      print('Add Bookmark Status: ${response.statusCode}');
      print('Add Bookmark Body: ${response.body}');

      // If backend requires form-data instead of JSON
      if (response.statusCode == 400 || response.statusCode == 422) {
        final formResponse = await ApiClient.post(
          AppUrl.addBookmark,
          body: body,
          isJson: false,
        );
        if (formResponse.statusCode == 200 || formResponse.statusCode == 201) {
          response = formResponse;
        }
      }

      if (response.body.isEmpty) {
        final bool isSuccess = response.statusCode == 200 || response.statusCode == 201;
        return (
          success: isSuccess,
          message: isSuccess ? 'Trip bookmarked successfully' : 'Server returned status ${response.statusCode}',
          data: null,
          bookmarkId: null,
        );
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        final bool isSuccess = response.statusCode == 200 || response.statusCode == 201;
        return (
          success: isSuccess,
          message: isSuccess ? 'Trip bookmarked successfully' : response.body,
          data: null,
          bookmarkId: null,
        );
      }

      final String msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (data is Map && data['error'] != null)
              ? data['error'].toString()
              : 'Trip bookmarked successfully';

      final bool isSuccess = (response.statusCode == 200 || response.statusCode == 201) &&
          (data is! Map ||
              data['status'] == 'success' ||
              data['success'] == true ||
              data['status'] == 200 ||
              data['status'] == 201 ||
              data['status'] == 'ok');

      int? bookmarkId;
      if (data is Map) {
        final rawId = data['bookmark_id'] ?? data['id'] ?? data['data']?['id'] ?? data['data']?['bookmark_id'];
        if (rawId != null) {
          bookmarkId = rawId is int ? rawId : int.tryParse(rawId.toString());
        }
      }

      return (success: isSuccess, message: msg, data: data, bookmarkId: bookmarkId);
    } catch (e) {
      print('Add Bookmark Error: $e');
      return (
        success: false,
        message: 'Network error adding bookmark: $e',
        data: null,
        bookmarkId: null,
      );
    }
  }

  // 3. POST Remove Bookmark (/remove_bookmark)
  Future<({bool success, String message, dynamic data})> removeBookmark(
    dynamic tripId, {
    dynamic bookmarkId,
  }) async {
    try {
      final String cleanTripId = tripId.toString().trim();
      final Map<String, dynamic> body = {
        'trip_id': cleanTripId,
        'tripId': cleanTripId,
        'id': cleanTripId,
        if (bookmarkId != null) ...{
          'bookmark_id': bookmarkId.toString().trim(),
          'bookmarkId': bookmarkId.toString().trim(),
        },
        if (int.tryParse(cleanTripId) != null) 'trip_id_int': int.parse(cleanTripId),
      };

      var response = await ApiClient.post(
        AppUrl.removeBookmark,
        body: body,
        isJson: true,
      );

      print('Remove Bookmark Status: ${response.statusCode}');
      print('Remove Bookmark Body: ${response.body}');

      // If backend requires form-data instead of JSON
      if (response.statusCode == 400 || response.statusCode == 422) {
        final formResponse = await ApiClient.post(
          AppUrl.removeBookmark,
          body: body,
          isJson: false,
        );
        if (formResponse.statusCode == 200 || formResponse.statusCode == 201) {
          response = formResponse;
        }
      }

      if (response.body.isEmpty) {
        final bool isSuccess = response.statusCode == 200 || response.statusCode == 201;
        return (
          success: isSuccess,
          message: isSuccess ? 'Bookmark removed successfully' : 'Server returned status ${response.statusCode}',
          data: null,
        );
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        final bool isSuccess = response.statusCode == 200 || response.statusCode == 201;
        return (
          success: isSuccess,
          message: isSuccess ? 'Bookmark removed successfully' : response.body,
          data: null,
        );
      }

      final String msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (data is Map && data['error'] != null)
              ? data['error'].toString()
              : 'Bookmark removed successfully';

      final bool isSuccess = (response.statusCode == 200 || response.statusCode == 201) &&
          (data is! Map ||
              data['status'] == 'success' ||
              data['success'] == true ||
              data['status'] == 200 ||
              data['status'] == 201 ||
              data['status'] == 'ok');

      return (success: isSuccess, message: msg, data: data);
    } catch (e) {
      print('Remove Bookmark Error: $e');
      return (
        success: false,
        message: 'Network error removing bookmark: $e',
        data: null,
      );
    }
  }
}
