class TripRatingDetail {
  final int tripId;
  final String tripTitle;
  final String hostUsername;
  final double averageRating;
  final int totalRatings;
  final bool hasRated;
  final int? userRating;
  final Map<int, int> breakdown;

  const TripRatingDetail({
    required this.tripId,
    required this.tripTitle,
    required this.hostUsername,
    required this.averageRating,
    required this.totalRatings,
    required this.hasRated,
    this.userRating,
    this.breakdown = const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
  });

  factory TripRatingDetail.fromJson(Map<String, dynamic> json) {
    final rawTripId = json['trip_id'];
    final int parsedTripId = rawTripId is int
        ? rawTripId
        : int.tryParse(rawTripId?.toString() ?? '0') ?? 0;

    final rawAvg = json['average_rating'] ?? json['avg_rating'];
    final double parsedAvg = rawAvg != null
        ? (rawAvg is num ? rawAvg.toDouble() : double.tryParse(rawAvg.toString()) ?? 0.0)
        : 0.0;

    final rawTotal = json['total_ratings'] ?? json['rating_count'];
    final int parsedTotal = rawTotal != null
        ? (rawTotal is int ? rawTotal : int.tryParse(rawTotal.toString()) ?? 0)
        : 0;

    final rawUserRating = json['user_rating'] ?? json['rating'];
    final int? parsedUserRating = rawUserRating != null
        ? (rawUserRating is int ? rawUserRating : int.tryParse(rawUserRating.toString()))
        : null;

    final Map<int, int> parsedBreakdown = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    final rawBreakdown = json['breakdown'];
    if (rawBreakdown is Map) {
      for (int i = 1; i <= 5; i++) {
        final val = rawBreakdown['${i}_star'] ?? rawBreakdown[i.toString()] ?? rawBreakdown[i];
        if (val != null) {
          parsedBreakdown[i] = val is int ? val : int.tryParse(val.toString()) ?? 0;
        }
      }
    }

    return TripRatingDetail(
      tripId: parsedTripId,
      tripTitle: json['trip_title']?.toString() ?? '',
      hostUsername: json['host_username']?.toString() ?? '',
      averageRating: parsedAvg,
      totalRatings: parsedTotal,
      hasRated: json['has_rated'] == true || parsedUserRating != null,
      userRating: parsedUserRating,
      breakdown: parsedBreakdown,
    );
  }
}

class RatingResult {
  final bool success;
  final String message;
  final int? statusCode;
  final int? rating;
  final double? averageRating;
  final int? totalRatings;
  final int? existingRating;

  const RatingResult({
    required this.success,
    required this.message,
    this.statusCode,
    this.rating,
    this.averageRating,
    this.totalRatings,
    this.existingRating,
  });
}

class TripRatingModel {
  final int tripId;
  final String tripTitle;
  final String hostUsername;
  final double averageRating;
  final int totalRatings;
  final bool hasRated;
  final int? userRating;
  final Map<String, int> breakdown;

  TripRatingModel({
    required this.tripId,
    required this.tripTitle,
    required this.hostUsername,
    required this.averageRating,
    required this.totalRatings,
    required this.hasRated,
    this.userRating,
    this.breakdown = const {},
  });

  factory TripRatingModel.fromJson(Map<String, dynamic> json) {
    final Map<String, int> parsedBreakdown = {};
    if (json['breakdown'] is Map) {
      json['breakdown'].forEach((key, val) {
        parsedBreakdown[key.toString()] = int.tryParse(val.toString()) ?? 0;
      });
    }

    return TripRatingModel(
      tripId: int.tryParse(json['trip_id']?.toString() ?? '0') ?? 0,
      tripTitle: json['trip_title']?.toString() ?? '',
      hostUsername: json['host_username']?.toString() ?? '',
      averageRating:
          double.tryParse(json['average_rating']?.toString() ?? '0.0') ?? 0.0,
      totalRatings: int.tryParse(json['total_ratings']?.toString() ?? '0') ?? 0,
      hasRated: json['has_rated'] == true,
      userRating: json['user_rating'] != null
          ? int.tryParse(json['user_rating'].toString())
          : null,
      breakdown: parsedBreakdown,
    );
  }

  TripRatingModel copyWith({
    int? tripId,
    String? tripTitle,
    String? hostUsername,
    double? averageRating,
    int? totalRatings,
    bool? hasRated,
    int? userRating,
    Map<String, int>? breakdown,
  }) {
    return TripRatingModel(
      tripId: tripId ?? this.tripId,
      tripTitle: tripTitle ?? this.tripTitle,
      hostUsername: hostUsername ?? this.hostUsername,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      hasRated: hasRated ?? this.hasRated,
      userRating: userRating ?? this.userRating,
      breakdown: breakdown ?? this.breakdown,
    );
  }
}

