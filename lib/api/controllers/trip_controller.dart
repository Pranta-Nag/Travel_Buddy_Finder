import 'dart:convert';
import 'package:travel_buddy_finder/api/models/trip_model.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/core/network/api_client.dart';

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

      if (coverPhotoBytes != null && coverPhotoBytes.isNotEmpty) {
        final String rawBase64 = base64Encode(coverPhotoBytes);
        final String dataUriBase64 = 'data:image/jpeg;base64,$rawBase64';

        fields['cover_picture'] = dataUriBase64;
        fields['cover_photo'] = dataUriBase64;
        fields['image'] = dataUriBase64;
        fields['cover_picture_base64'] = rawBase64;
      }

      var response = coverPhotoBytes != null && coverPhotoBytes.isNotEmpty
          ? await ApiClient.multipartPost(
              AppUrl.createTrip,
              fields: fields.map((k, v) => MapEntry(k, v.toString())),
              filesBytes: {
                'cover_picture': coverPhotoBytes,
                'cover_photo': coverPhotoBytes,
                'image': coverPhotoBytes,
              },
            )
          : await ApiClient.post(
              AppUrl.createTrip,
              body: fields,
              isJson: true,
            );

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

      if (coverPhotoBytes != null && coverPhotoBytes.isNotEmpty) {
        final String rawBase64 = base64Encode(coverPhotoBytes);
        final String dataUriBase64 = 'data:image/jpeg;base64,$rawBase64';

        fields['cover_picture'] = dataUriBase64;
        fields['cover_photo'] = dataUriBase64;
        fields['image'] = dataUriBase64;
      }

      var response = coverPhotoBytes != null && coverPhotoBytes.isNotEmpty
          ? await ApiClient.multipartPost(
              AppUrl.updateTrip,
              fields: fields.map((k, v) => MapEntry(k, v.toString())),
              filesBytes: {
                'cover_picture': coverPhotoBytes,
                'cover_photo': coverPhotoBytes,
              },
            )
          : await ApiClient.post(
              AppUrl.updateTrip,
              body: fields,
              isJson: true,
            );

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
}
