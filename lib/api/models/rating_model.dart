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
