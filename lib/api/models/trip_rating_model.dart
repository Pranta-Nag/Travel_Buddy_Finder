class TripRatingSummary {
  final int tripId;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> distribution; // e.g. {5: 10, 4: 2, 3: 0, 2: 0, 1: 0}
  final bool hasRated;
  final int? userRating;

  TripRatingSummary({
    required this.tripId,
    required this.averageRating,
    required this.totalRatings,
    required this.distribution,
    required this.hasRated,
    this.userRating,
  });

  factory TripRatingSummary.fromJson(Map<String, dynamic> json) {
    final payload = (json['data'] is Map) ? json['data'] as Map<String, dynamic> : json;

    final rawDist = (payload['distribution'] ?? payload['breakdown']) as Map?;
    final parsedDist = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    if (rawDist != null) {
      rawDist.forEach((key, val) {
        final star = int.tryParse(key.toString().replaceAll('_star', '')) ?? 0;
        if (star >= 1 && star <= 5) {
          parsedDist[star] = (val as num?)?.toInt() ?? 0;
        }
      });
    }

    final userStatus = payload['user_status'] as Map?;

    final rawTripId = payload['trip_id'];
    final int parsedTripId = rawTripId is int
        ? rawTripId
        : int.tryParse(rawTripId?.toString() ?? '0') ?? 0;

    final rawAvg = payload['average_rating'] ?? payload['avg_rating'];
    final double parsedAvg = rawAvg != null
        ? (rawAvg is num ? rawAvg.toDouble() : double.tryParse(rawAvg.toString()) ?? 0.0)
        : 0.0;

    final rawTotal = payload['total_ratings'] ?? payload['rating_count'];
    final int parsedTotal = rawTotal != null
        ? (rawTotal is int ? rawTotal : int.tryParse(rawTotal.toString()) ?? 0)
        : 0;

    final bool parsedHasRated = (userStatus?['has_rated'] == true) ||
        (payload['has_rated'] == true) ||
        (userStatus?['user_rating'] != null) ||
        (payload['user_rating'] != null);

    final rawUserRating = userStatus?['user_rating'] ?? payload['user_rating'];
    final int? parsedUserRating = rawUserRating != null
        ? (rawUserRating is int ? rawUserRating : int.tryParse(rawUserRating.toString()))
        : null;

    return TripRatingSummary(
      tripId: parsedTripId,
      averageRating: parsedAvg,
      totalRatings: parsedTotal,
      distribution: parsedDist,
      hasRated: parsedHasRated,
      userRating: parsedUserRating,
    );
  }
}
