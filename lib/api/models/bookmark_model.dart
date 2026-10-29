import 'package:travel_buddy_finder/api/models/trip_model.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip.dart';

class BookmarkModel {
  final int id;
  final int tripId;
  final int? userId;
  final String createdAt;
  final TripModel? tripModel;
  final Trip? cachedTrip;

  BookmarkModel({
    required this.id,
    required this.tripId,
    this.userId,
    this.createdAt = '',
    this.tripModel,
    this.cachedTrip,
  });

  Trip toTrip() {
    if (tripModel != null) {
      return tripModel!.toTrip();
    }
    if (cachedTrip != null) {
      return cachedTrip!;
    }
    return Trip(
      id: tripId.toString(),
      title: 'Saved Trip',
      location: 'Destination',
      price: '\$0',
      rating: '5.0',
      hostName: 'Traveler Host',
      username: '@traveler',
      imageUrl: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800',
      avatarUrl: 'assets/images/dummy_boy.jpg',
      category: 'Adventure',
      description: '',
    );
  }

  factory BookmarkModel.fromTrip(Trip trip, {int? bookmarkId}) {
    final parsedTripId = int.tryParse(trip.id) ?? 0;
    return BookmarkModel(
      id: bookmarkId ?? parsedTripId,
      tripId: parsedTripId,
      cachedTrip: trip,
    );
  }

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    // 1. Identify nested trip data if present
    TripModel? parsedTrip;
    final dynamic rawTrip = json['trip'] ?? json['trip_details'] ?? json['trip_data'];
    if (rawTrip is Map<String, dynamic>) {
      parsedTrip = TripModel.fromJson(rawTrip);
    } else if (rawTrip is Map) {
      parsedTrip = TripModel.fromJson(Map<String, dynamic>.from(rawTrip));
    } else if (json.containsKey('destination') ||
        json.containsKey('trip_title') ||
        json.containsKey('budget') ||
        json.containsKey('start_day') ||
        json.containsKey('cover_picture_url') ||
        json.containsKey('category')) {
      // The JSON itself is the trip joined with bookmark fields
      parsedTrip = TripModel.fromJson(json);
    }

    // 2. Resolve bookmark ID and trip ID
    final rawBookmarkId = json['bookmark_id'] ?? json['id'];
    final int parsedId = rawBookmarkId != null
        ? (rawBookmarkId is int
            ? rawBookmarkId
            : int.tryParse(rawBookmarkId.toString()) ?? 0)
        : (parsedTrip?.id ?? 0);

    final rawTripId = json['trip_id'] ?? json['tripId'] ?? parsedTrip?.id ?? json['id'];
    final int parsedTripId = rawTripId != null
        ? (rawTripId is int
            ? rawTripId
            : int.tryParse(rawTripId.toString()) ?? parsedId)
        : parsedId;

    final rawUserId = json['user_id'] ?? json['userId'];
    final int? parsedUserId = rawUserId != null
        ? (rawUserId is int
            ? rawUserId
            : int.tryParse(rawUserId.toString()))
        : null;

    final String createdAt = json['created_at']?.toString() ??
        json['createdAt']?.toString() ??
        json['date']?.toString() ??
        '';

    return BookmarkModel(
      id: parsedId,
      tripId: parsedTripId,
      userId: parsedUserId,
      createdAt: createdAt,
      tripModel: parsedTrip,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      if (userId != null) 'user_id': userId,
      'created_at': createdAt,
      if (tripModel != null) 'trip': tripModel!.toJson(),
    };
  }
}
