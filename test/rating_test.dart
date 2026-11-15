import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy_finder/api/models/rating_model.dart';

void main() {
  test('TripRatingModel.fromJson correctly parses backend payload', () {
    final Map<String, dynamic> sampleJson = {
      "trip_id": 2,
      "trip_title": "Cox's Bazar Beach Holiday",
      "host_username": "galib",
      "average_rating": 4.5,
      "total_ratings": 2,
      "has_rated": true,
      "user_rating": 5,
      "breakdown": {
        "5_star": 1,
        "4_star": 1,
        "3_star": 0,
        "2_star": 0,
        "1_star": 0,
      }
    };

    final model = TripRatingModel.fromJson(sampleJson);

    expect(model.tripId, 2);
    expect(model.tripTitle, "Cox's Bazar Beach Holiday");
    expect(model.hostUsername, "galib");
    expect(model.averageRating, 4.5);
    expect(model.totalRatings, 2);
    expect(model.hasRated, true);
    expect(model.userRating, 5);
    expect(model.breakdown['5_star'], 1);
    expect(model.breakdown['4_star'], 1);
    expect(model.breakdown['3_star'], 0);
  });

  test('TripRatingModel.fromJson handles null user_rating gracefully', () {
    final Map<String, dynamic> sampleJson = {
      "trip_id": "4",
      "trip_title": "Sylhet Tour",
      "host_username": "tanjim_traveler",
      "average_rating": "4.0",
      "total_ratings": "1",
      "has_rated": false,
      "user_rating": null,
      "breakdown": null
    };

    final model = TripRatingModel.fromJson(sampleJson);

    expect(model.tripId, 4);
    expect(model.hasRated, false);
    expect(model.userRating, null);
    expect(model.averageRating, 4.0);
    expect(model.totalRatings, 1);
    expect(model.breakdown.isEmpty, true);
  });
}
