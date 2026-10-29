import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travel_buddy_finder/api/models/trip_model.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/core/network/api_client.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip_request.dart';

class TripController {
  // 1. GET All Trips Feed
  Future<List<TripModel>> getAllTrips() async {
    try {
      final response = await ApiClient.get(AppUrl.allTrips);
      print('All Trips Status: ${response.statusCode}');
      print('All Trips Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = (data is Map && data['data'] != null)
            ? data['data']
            : (data is List ? data : []);
        return list.map((item) => TripModel.fromJson(item)).toList();
      }
    } catch (e) {
      print('Get All Trips Error: $e');
    }
    return [];
  }

  // 2. GET Category Filtered Trips
  Future<List<TripModel>> getTripsByCategory(String category) async {
    try {
      final endpoint = '${AppUrl.categoryTrips}?category=${Uri.encodeComponent(category)}';
      final response = await ApiClient.get(endpoint);
      print('Category Trips Status: ${response.statusCode}');
      print('Category Trips Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = (data is Map && data['data'] != null)
            ? data['data']
            : (data is List ? data : []);
        return list.map((item) => TripModel.fromJson(item)).toList();
      }
    } catch (e) {
      print('Get Category Trips Error: $e');
    }
    return [];
  }

  // 3 & 4. POST Create Trip (Text fields & Cover Image)
  Future<({bool success, TripModel? trip, String message})> createTrip({
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
    try {
      final Map<String, dynamic> fields = {
        'title': title,
        'trip_title': title,
        'name': title,

        'destination': location,
        'location': location,
        'city': location,

        'budget': price.toString(),
        'price': price.toString(),
        'cost': price.toString(),

        'start_day': startDate,
        'start_date': startDate,
        'startdate': startDate,
        'from_date': startDate,
        'date': startDate,

        'end_day': endDate,
        'end_date': endDate,
        'enddate': endDate,
        'to_date': endDate,

        'category': category,
        'trip_category': category,

        'description': description,
        'details': description,

        'total_seats': seats.toString(),
        'available_seats': seats.toString(),
        'seats': seats.toString(),
        'seats_left': seats.toString(),

        'transport_method': (transports ?? ['Bus', 'Flight']).join(','),
        'transports': (transports ?? ['Bus', 'Flight']).join(','),
        'transportation': (transports ?? ['Bus', 'Flight']).join(','),
      };

      http.Response response;
      if (coverPhotoBytes != null && coverPhotoBytes.isNotEmpty) {
        // 1. Try standard Multipart file upload first
        final Map<String, String> formFields =
            fields.map((k, v) => MapEntry(k, v.toString()));

        response = await ApiClient.multipartPost(
          AppUrl.createTrip,
          fields: formFields,
          filesBytes: {
            'cover_picture': coverPhotoBytes,
            'image': coverPhotoBytes,
            'cover_photo': coverPhotoBytes,
            'cover_image': coverPhotoBytes,
          },
        );

        // 2. If multipart failed or wasn't accepted by backend, fallback to JSON with Base64 data URI
        if (response.statusCode != 200 && response.statusCode != 201) {
          final String rawBase64 = base64Encode(coverPhotoBytes);
          final String dataUriBase64 = 'data:image/jpeg;base64,$rawBase64';
          final Map<String, dynamic> jsonFields =
              Map<String, dynamic>.from(fields);
          jsonFields['cover_picture'] = dataUriBase64;
          jsonFields['image'] = dataUriBase64;
          jsonFields['cover_photo'] = dataUriBase64;
          jsonFields['cover_image'] = dataUriBase64;
          jsonFields['cover_picture_base64'] = rawBase64;

          final jsonResponse = await ApiClient.post(
            AppUrl.createTrip,
            body: jsonFields,
            isJson: true,
          );
          if (jsonResponse.statusCode == 200 ||
              jsonResponse.statusCode == 201) {
            response = jsonResponse;
          }
        }
      } else {
        response = await ApiClient.post(
          AppUrl.createTrip,
          body: fields,
          isJson: true,
        );
      }

      print('Create Trip Status: ${response.statusCode}');
      print('Create Trip Body: ${response.body}');

      if (response.body.isEmpty) {
        return (
          success: false,
          trip: null,
          message: 'Server returned empty response (Status: ${response.statusCode}).',
        );
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return (
          success: false,
          trip: null,
          message: 'Server returned non-JSON response (Status: ${response.statusCode}).',
        );
      }

      final String message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (data is Map && data['error'] != null)
              ? data['error'].toString()
              : 'Trip creation response (${response.statusCode})';

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          (data is Map && data['status'] == 'success')) {
        final tripJson = data['trip'] ?? data['data'];
        final trip = tripJson != null ? TripModel.fromJson(tripJson) : null;
        return (success: true, trip: trip, message: message.isNotEmpty ? message : 'Trip created successfully');
      }

      return (success: false, trip: null, message: message);
    } catch (e) {
      return (success: false, trip: null, message: 'Network error creating trip: $e');
    }
  }

  // 5. POST Update Trip
  Future<({bool success, TripModel? trip, String message})> updateTrip({
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
    try {
      final Map<String, dynamic> fields = {
        'id': tripId.toString(),
        'trip_id': tripId.toString(),
        'title': title,
        'trip_title': title,

        'destination': location,
        'location': location,

        'budget': price.toString(),
        'price': price.toString(),

        'start_day': startDate,
        'start_date': startDate,

        'end_day': endDate,
        'end_date': endDate,

        'category': category,
        'description': description,
      };

      if (seats != null) {
        fields['seats'] = seats.toString();
        fields['available_seats'] = seats.toString();
        fields['total_seats'] = seats.toString();
      }

      if (transports != null) {
        fields['transport_method'] = transports.join(',');
        fields['transports'] = transports.join(',');
      }

      http.Response response;
      if (coverPhotoBytes != null && coverPhotoBytes.isNotEmpty) {
        final Map<String, String> formFields =
            fields.map((k, v) => MapEntry(k, v.toString()));

        response = await ApiClient.multipartPost(
          AppUrl.updateTrip,
          fields: formFields,
          filesBytes: {
            'cover_picture': coverPhotoBytes,
            'image': coverPhotoBytes,
            'cover_photo': coverPhotoBytes,
            'cover_image': coverPhotoBytes,
          },
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          final String rawBase64 = base64Encode(coverPhotoBytes);
          final String dataUriBase64 = 'data:image/jpeg;base64,$rawBase64';
          final Map<String, dynamic> jsonFields =
              Map<String, dynamic>.from(fields);
          jsonFields['cover_picture'] = dataUriBase64;
          jsonFields['image'] = dataUriBase64;
          jsonFields['cover_photo'] = dataUriBase64;
          jsonFields['cover_image'] = dataUriBase64;

          final jsonResponse = await ApiClient.post(
            AppUrl.updateTrip,
            body: jsonFields,
            isJson: true,
          );
          if (jsonResponse.statusCode == 200 ||
              jsonResponse.statusCode == 201) {
            response = jsonResponse;
          }
        }
      } else {
        response = await ApiClient.post(
          AppUrl.updateTrip,
          body: fields,
          isJson: true,
        );
      }

      print('Update Trip Status: ${response.statusCode}');
      print('Update Trip Body: ${response.body}');

      final data = jsonDecode(response.body);
      final String message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Trip updated successfully';

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          (data is Map && data['status'] == 'success')) {
        final tripJson = data['trip'] ?? data['data'];
        final trip = tripJson != null ? TripModel.fromJson(tripJson) : null;
        return (success: true, trip: trip, message: message);
      }

      return (success: false, trip: null, message: message);
    } catch (e) {
      return (success: false, trip: null, message: 'Network error updating trip: $e');
    }
  }

  // 6. POST Delete Trip
  Future<({bool success, String message})> deleteTrip(int tripId) async {
    try {
      final response = await ApiClient.post(
        AppUrl.deleteTrip,
        body: {
          'id': tripId.toString(),
          'trip_id': tripId.toString(),
        },
        isJson: true,
      );

      print('Delete Trip Status: ${response.statusCode}');
      print('Delete Trip Body: ${response.body}');

      final data = jsonDecode(response.body);
      final String message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Trip deleted successfully';

      return (
        success: (response.statusCode == 200 || response.statusCode == 201) &&
            (data is Map && data['status'] == 'success'),
        message: message,
      );
    } catch (e) {
      return (success: false, message: 'Network error deleting trip: $e');
    }
  }

  // 7. POST Join Trip (/join_trip)
  Future<({bool success, String message, dynamic data})> joinTrip({
    required dynamic tripId,
    String? message,
  }) async {
    try {
      final String cleanTripId = tripId.toString().trim();
      final Map<String, dynamic> body = {
        'trip_id': cleanTripId,
        'id': cleanTripId,
        if (int.tryParse(cleanTripId) != null) 'tripId': int.parse(cleanTripId),
        if (message != null && message.trim().isNotEmpty) ...{
          'message': message.trim(),
          'note': message.trim(),
        },
      };

      final response = await ApiClient.post(
        AppUrl.joinTrip,
        body: body,
        isJson: true,
      );

      print('Join Trip Status: ${response.statusCode}');
      print('Join Trip Body: ${response.body}');

      if (response.body.isEmpty) {
        final bool isSuccess = response.statusCode == 200 || response.statusCode == 201;
        return (
          success: isSuccess,
          message: isSuccess ? 'Join request sent successfully' : 'Server returned status ${response.statusCode}',
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
          message: isSuccess ? 'Join request sent successfully' : response.body,
          data: null,
        );
      }

      final String msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (data is Map && data['error'] != null)
              ? data['error'].toString()
              : 'Join request processed';

      final bool isSuccess = (response.statusCode == 200 || response.statusCode == 201) &&
          (data is! Map ||
              data['status'] == 'success' ||
              data['success'] == true ||
              data['status'] == 200 ||
              data['status'] == 201 ||
              data['status'] == 'ok');

      return (success: isSuccess, message: msg, data: data);
    } catch (e) {
      print('Join Trip Error: $e');
      return (success: false, message: 'Network error sending join request: $e', data: null);
    }
  }

  // 8. POST Accept Request (/accept_request)
  Future<({bool success, String message, dynamic data})> acceptRequest({
    required dynamic requestId,
    dynamic tripId,
  }) async {
    try {
      final String cleanReqId = requestId.toString().trim();
      final Map<String, dynamic> body = {
        'request_id': cleanReqId,
        'id': cleanReqId,
        if (int.tryParse(cleanReqId) != null) 'requestId': int.parse(cleanReqId),
        if (tripId != null) ...{
          'trip_id': tripId.toString().trim(),
          'tripId': tripId.toString().trim(),
        },
        'action': 'accept',
        'status': 'accepted',
      };

      final response = await ApiClient.post(
        AppUrl.acceptRequest,
        body: body,
        isJson: true,
      );

      print('Accept Request Status: ${response.statusCode}');
      print('Accept Request Body: ${response.body}');

      if (response.statusCode == 404) {
        return respondRequest(
          requestId: requestId,
          action: 'accept',
          tripId: tripId,
        );
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {}

      final String msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (data is Map && data['error'] != null)
              ? data['error'].toString()
              : 'Request accepted successfully';

      final bool isSuccess = (response.statusCode == 200 || response.statusCode == 201) &&
          (data is! Map ||
              data['status'] == 'success' ||
              data['success'] == true ||
              data['status'] == 200 ||
              data['status'] == 'ok');

      return (success: isSuccess, message: msg, data: data);
    } catch (e) {
      print('Accept Request Error: $e');
      return (success: false, message: 'Network error accepting request: $e', data: null);
    }
  }

  // 9. POST Reject Request (/reject_request)
  Future<({bool success, String message, dynamic data})> rejectRequest({
    required dynamic requestId,
    dynamic tripId,
  }) async {
    try {
      final String cleanReqId = requestId.toString().trim();
      final Map<String, dynamic> body = {
        'request_id': cleanReqId,
        'id': cleanReqId,
        if (int.tryParse(cleanReqId) != null) 'requestId': int.parse(cleanReqId),
        if (tripId != null) ...{
          'trip_id': tripId.toString().trim(),
          'tripId': tripId.toString().trim(),
        },
        'action': 'reject',
        'status': 'rejected',
      };

      final response = await ApiClient.post(
        AppUrl.rejectRequest,
        body: body,
        isJson: true,
      );

      print('Reject Request Status: ${response.statusCode}');
      print('Reject Request Body: ${response.body}');

      if (response.statusCode == 404) {
        return respondRequest(
          requestId: requestId,
          action: 'reject',
          tripId: tripId,
        );
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {}

      final String msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (data is Map && data['error'] != null)
              ? data['error'].toString()
              : 'Request rejected';

      final bool isSuccess = (response.statusCode == 200 || response.statusCode == 201) &&
          (data is! Map ||
              data['status'] == 'success' ||
              data['success'] == true ||
              data['status'] == 200 ||
              data['status'] == 'ok');

      return (success: isSuccess, message: msg, data: data);
    } catch (e) {
      print('Reject Request Error: $e');
      return (success: false, message: 'Network error rejecting request: $e', data: null);
    }
  }

  // 10. POST Respond Request (/respond_request)
  Future<({bool success, String message, dynamic data})> respondRequest({
    required dynamic requestId,
    required String action,
    dynamic tripId,
  }) async {
    try {
      final String cleanReqId = requestId.toString().trim();
      final String cleanAction = action.trim().toLowerCase();
      final bool isAccept = cleanAction == 'accept' || cleanAction == 'accepted' || cleanAction == 'approved';

      final Map<String, dynamic> body = {
        'request_id': cleanReqId,
        'id': cleanReqId,
        if (int.tryParse(cleanReqId) != null) 'requestId': int.parse(cleanReqId),
        if (tripId != null) ...{
          'trip_id': tripId.toString().trim(),
          'tripId': tripId.toString().trim(),
        },
        'action': isAccept ? 'accept' : 'reject',
        'status': isAccept ? 'accepted' : 'rejected',
        'decision': isAccept ? 'accept' : 'reject',
        'response': isAccept ? 'accept' : 'reject',
      };

      final response = await ApiClient.post(
        AppUrl.respondRequest,
        body: body,
        isJson: true,
      );

      print('Respond Request Status: ${response.statusCode}');
      print('Respond Request Body: ${response.body}');

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {}

      final String msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (data is Map && data['error'] != null)
              ? data['error'].toString()
              : (isAccept ? 'Request accepted' : 'Request rejected');

      final bool isSuccess = (response.statusCode == 200 || response.statusCode == 201) &&
          (data is! Map ||
              data['status'] == 'success' ||
              data['success'] == true ||
              data['status'] == 200 ||
              data['status'] == 'ok');

      return (success: isSuccess, message: msg, data: data);
    } catch (e) {
      print('Respond Request Error: $e');
      return (success: false, message: 'Network error responding to request: $e', data: null);
    }
  }

  // 11. GET Pending Requests (/pending_requests)
  Future<({bool success, String message, List<TripRequest> requests})> getPendingRequests() async {
    try {
      var response = await ApiClient.get(AppUrl.pendingRequests);
      print('Pending Requests GET Status: ${response.statusCode}');
      print('Pending Requests GET Body: ${response.body}');

      if (response.statusCode == 405) {
        response = await ApiClient.post(AppUrl.pendingRequests);
        print('Pending Requests POST Status: ${response.statusCode}');
        print('Pending Requests POST Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final List rawList = (data is Map && (data['data'] != null || data['pending_requests'] != null || data['requests'] != null))
            ? (data['data'] ?? data['pending_requests'] ?? data['requests'])
            : (data is List ? data : []);

        final List<TripRequest> parsed = [];
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            parsed.add(TripRequest.fromJson(item));
          } else if (item is Map) {
            parsed.add(TripRequest.fromJson(Map<String, dynamic>.from(item)));
          }
        }

        return (
          success: true,
          message: 'Fetched ${parsed.length} pending requests',
          requests: parsed,
        );
      } else {
        return (
          success: false,
          message: 'Failed to fetch pending requests: ${response.statusCode}',
          requests: <TripRequest>[],
        );
      }
    } catch (e) {
      print('Pending Requests Error: $e');
      return (
        success: false,
        message: 'Network error fetching pending requests: $e',
        requests: <TripRequest>[],
      );
    }
  }
}
