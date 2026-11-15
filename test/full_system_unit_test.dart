import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_buddy_finder/api/models/bookmark_model.dart';
import 'package:travel_buddy_finder/api/models/rating_model.dart';
import 'package:travel_buddy_finder/api/models/trip_map_model.dart';
import 'package:travel_buddy_finder/api/models/trip_model.dart';
import 'package:travel_buddy_finder/api/models/user_model.dart';
import 'package:travel_buddy_finder/core/services/map_routing_service.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';
import 'package:travel_buddy_finder/features/trips/data/models/comment.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip.dart';

void main() {
  group('1. Rating & Zero-State Unit Tests', () {
    test('Unrated trip JSON maps correctly to 0.0 and 0 count (No fake 5 stars)', () {
      final unratedTripJson = {
        "id": 12,
        "title": "Cox's Bazar Road Trip",
        "destination": "Cox's Bazar",
        "budget": 5000.0,
        "start_day": "2026-11-19",
        "end_day": "2026-11-23",
        "category": "Beach",
        "host_username": "galibsidrath",
        "rating": 0.0,
        "rating_count": 0,
      };

      final tripModel = TripModel.fromJson(unratedTripJson);
      expect(tripModel.id, 12);
      expect(tripModel.ratingCount, 0);
      expect(tripModel.rating, '0.0');

      final trip = tripModel.toTrip();
      expect(trip.ratingCount, 0);
      expect(trip.rating, '0.0');
    });

    test('TripRatingDetail handles empty backend rating payload (Trip #12 scenario)', () {
      final emptyRatingJson = {
        "trip_id": 12,
        "trip_title": "Cox's Bazar Road Trip",
        "host_username": "galibsidrath",
        "average_rating": 0,
        "total_ratings": 0,
        "has_rated": false,
        "user_rating": null,
        "breakdown": {
          "5_star": 0,
          "4_star": 0,
          "3_star": 0,
          "2_star": 0,
          "1_star": 0,
        }
      };

      final detail = TripRatingDetail.fromJson(emptyRatingJson);
      expect(detail.tripId, 12);
      expect(detail.averageRating, 0.0);
      expect(detail.totalRatings, 0);
      expect(detail.hasRated, false);
      expect(detail.userRating, isNull);
      expect(detail.breakdown[5], 0);
      expect(detail.breakdown[1], 0);
    });

    test('TripRatingDetail parses non-zero ratings and breakdown correctly', () {
      final populatedRatingJson = {
        "trip_id": 4,
        "trip_title": "Sylhet Ratargul & Jaflong Tour",
        "host_username": "tanjim_traveler",
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

      final detail = TripRatingDetail.fromJson(populatedRatingJson);
      expect(detail.tripId, 4);
      expect(detail.averageRating, 4.5);
      expect(detail.totalRatings, 2);
      expect(detail.hasRated, true);
      expect(detail.userRating, 5);
      expect(detail.breakdown[5], 1);
      expect(detail.breakdown[4], 1);
    });

    test('Host is forbidden from self-rating their own trips', () {
      CurrentUser.activeUser = UserModel(
        id: 1,
        username: 'galibsidrath',
        email: 'galib@example.com',
        fullName: 'Galib Sidrath',
      );

      final hostTrip = Trip(
        id: '12',
        title: "Cox's Bazar Road Trip",
        location: "Cox's Bazar",
        price: "\$5000",
        rating: '0.0',
        ratingCount: 0,
        hostName: 'Galib Sidrath',
        username: '@galibsidrath',
        imageUrl: '',
        avatarUrl: '',
        category: 'Beach',
        description: 'Test trip',
      );

      final isHost = CurrentUser.isCurrentUser(
        hostTrip.username,
        inputName: hostTrip.hostName,
      );

      expect(isHost, isTrue);
    });
  });

  group('2. OpenStreetMap & Coordinate Parser Unit Tests', () {
    test('parseCoordinates detects comma-separated latitude and longitude', () {
      final coords = MapRoutingService.parseCoordinates('23.4607, 91.1809');
      expect(coords, isNotNull);
      expect(coords!.lat, closeTo(23.4607, 0.0001));
      expect(coords.lon, closeTo(91.1809, 0.0001));
    });

    test('parseCoordinates detects space-separated latitude and longitude', () {
      final coords = MapRoutingService.parseCoordinates('23.8103 90.4125');
      expect(coords, isNotNull);
      expect(coords!.lat, closeTo(23.8103, 0.0001));
      expect(coords.lon, closeTo(90.4125, 0.0001));
    });

    test('parseCoordinates handles negative coordinates correctly', () {
      final coords = MapRoutingService.parseCoordinates('-33.8688, 151.2093');
      expect(coords, isNotNull);
      expect(coords!.lat, closeTo(-33.8688, 0.0001));
      expect(coords.lon, closeTo(151.2093, 0.0001));
    });

    test('parseCoordinates returns null for invalid non-coordinate text', () {
      expect(MapRoutingService.parseCoordinates('Cumilla'), isNull);
      expect(MapRoutingService.parseCoordinates('Dhaka, Bangladesh'), isNull);
      expect(MapRoutingService.parseCoordinates(''), isNull);
    });

    test('parseCoordinates returns null for out-of-range coordinates', () {
      expect(MapRoutingService.parseCoordinates('120.5, 90.0'), isNull); // Lat > 90
      expect(MapRoutingService.parseCoordinates('23.0, 250.0'), isNull); // Lon > 180
    });

    test('searchLocation matches preloaded Cumilla and Dhaka hubs immediately', () async {
      final cumillaResults = await MapRoutingService.searchLocation('Cumilla');
      expect(cumillaResults, isNotEmpty);
      expect(cumillaResults.first.displayName.toLowerCase(), contains('cumilla'));
      expect(cumillaResults.first.lat, closeTo(23.46, 0.05));
      expect(cumillaResults.first.lon, closeTo(91.18, 0.05));

      final dhakaResults = await MapRoutingService.searchLocation('Dhaka');
      expect(dhakaResults, isNotEmpty);
      expect(dhakaResults.first.displayName.toLowerCase(), contains('dhaka'));
    });
  });

  group('3. TripMapData & Waypoints Model Unit Tests', () {
    test('TripMapData converts LatLng to OSRM GeoJSON [lon, lat] convention in toJson', () {
      final mapData = TripMapData(
        startLocation: 'Dhaka Arambagh',
        distanceKm: 395.0,
        durationHours: 8.5,
        waypoints: [
          WaypointItem(
            order: 1,
            name: 'Dhaka Arambagh',
            label: 'Start',
            lat: 23.7315,
            lon: 90.4182,
            color: 'green',
          ),
          WaypointItem(
            order: 2,
            name: 'Cumilla',
            label: 'Toilet break',
            lat: 23.4607,
            lon: 91.1809,
            color: 'amber',
          ),
          WaypointItem(
            order: 3,
            name: 'Cox\'s Bazar',
            label: 'Destination',
            lat: 21.4272,
            lon: 91.9701,
            color: 'red',
          ),
        ],
        routeCoordinates: [
          const LatLng(23.7315, 90.4182),
          const LatLng(23.4607, 91.1809),
          const LatLng(21.4272, 91.9701),
        ],
      );

      final json = mapData.toJson();
      expect(json['start_location'], 'Dhaka Arambagh');
      expect(json['distance_km'], 395.0);
      expect(json['duration_hours'], 8.5);
      expect(json['waypoints'], isA<List>());
      expect((json['waypoints'] as List).length, 3);

      // Verify GeoJSON [lon, lat] coordinate ordering
      final List coords = json['route_coordinates'];
      expect(coords[0], [90.4182, 23.7315]);
      expect(coords[1], [91.1809, 23.4607]);
      expect(coords[2], [91.9701, 21.4272]);
    });

    test('TripMapData deserializes GeoJSON [lon, lat] back to Flutter LatLng(lat, lon)', () {
      final json = {
        "start_location": "Dhaka Arambagh",
        "distance_km": 395.0,
        "duration_hours": 8.5,
        "waypoints": [
          {
            "order": 1,
            "name": "Dhaka Arambagh",
            "label": "Start",
            "lat": 23.7315,
            "lon": 90.4182,
            "color": "green"
          }
        ],
        "route_coordinates": [
          [90.4182, 23.7315]
        ]
      };

      final mapData = TripMapData.fromJson(json);
      expect(mapData.startLocation, 'Dhaka Arambagh');
      expect(mapData.hasRouteData, isTrue);
      expect(mapData.waypoints.length, 1);
      expect(mapData.routeCoordinates.length, 1);
      expect(mapData.routeCoordinates.first.latitude, 23.7315);
      expect(mapData.routeCoordinates.first.longitude, 90.4182);
    });
  });

  group('4. User & Auth Model Unit Tests', () {
    test('UserModel correctly parses full user details from JSON', () {
      final json = {
        "id": 1,
        "username": "galibsidrath",
        "email": "galib@example.com",
        "full_name": "Galib Sidrath",
        "gender": "Male",
        "country": "Bangladesh",
        "level": "Pro Explorer",
        "rating": "4.9",
        "total_hosted_trips": 5,
        "total_joined_trips": 12,
        "pending_requests_count": 2,
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 1);
      expect(user.username, "galibsidrath");
      expect(user.email, "galib@example.com");
      expect(user.fullName, "Galib Sidrath");
      expect(user.gender, "Male");
      expect(user.country, "Bangladesh");
      expect(user.level, "Pro Explorer");
      expect(user.rating, "4.9");
      expect(user.totalHostedTrips, 5);
      expect(user.totalJoinedTrips, 12);
      expect(user.pendingRequestsCount, 2);
    });

    test('UserModel safely handles missing or null fields with defaults', () {
      final user = UserModel.fromJson({});
      expect(user.id, 0);
      expect(user.username, '');
      expect(user.email, '');
      expect(user.fullName, '');
      expect(user.level, 'Traveler');
      expect(user.totalHostedTrips, 0);
      expect(user.totalJoinedTrips, 0);
      expect(user.pendingRequestsCount, 0);
    });
  });

  group('5. Bookmark Model Unit Tests', () {
    test('BookmarkModel correctly deserializes nested trip data', () {
      final json = {
        "id": 101,
        "trip_id": 8,
        "created_at": "2026-11-15 12:00:00",
        "trip": {
          "id": 8,
          "title": "Sundarbans Wild Mangrove Exploration",
          "destination": "Sundarbans, Khulna",
          "budget": 8500.0,
          "start_day": "2026-12-01",
          "end_day": "2026-12-05",
          "category": "Wildlife",
          "host_username": "nature_guide",
          "rating": 4.8,
          "rating_count": 6,
        }
      };

      final bookmark = BookmarkModel.fromJson(json);
      expect(bookmark.id, 101);
      expect(bookmark.tripId, 8);
      expect(bookmark.tripModel, isNotNull);
      expect(bookmark.tripModel!.title, "Sundarbans Wild Mangrove Exploration");

      final convertedTrip = bookmark.toTrip();
      expect(convertedTrip.id, "8");
      expect(convertedTrip.title, "Sundarbans Wild Mangrove Exploration");
      expect(convertedTrip.location, "Sundarbans, Khulna");
      expect(convertedTrip.rating, "4.8");
      expect(convertedTrip.ratingCount, 6);
    });

    test('BookmarkModel.fromTrip preserves in-memory trip references', () {
      final trip = Trip(
        id: '25',
        title: 'Bandarban Nilgiri Tour',
        location: 'Bandarban',
        price: '\$3500',
        rating: '4.7',
        ratingCount: 3,
        hostName: 'Hill Tracker',
        username: '@hilltracker',
        imageUrl: '',
        avatarUrl: '',
        category: 'Mountain',
        description: 'Trekking clouds at Nilgiri',
      );

      final bookmark = BookmarkModel.fromTrip(trip, bookmarkId: 999);
      expect(bookmark.id, 999);
      expect(bookmark.tripId, 25);
      expect(bookmark.toTrip().title, 'Bandarban Nilgiri Tour');
    });
  });

  group('6. Comments & Replies Model Unit Tests', () {
    test('CommentReply correctly deserializes and handles likes state', () {
      final json = {
        "id": "rep_1",
        "comment_id": "com_10",
        "name": "Sarah Ahmed",
        "username": "sarah_a",
        "text": "What time does the bus leave from Arambagh?",
        "time": "2 hours ago",
        "is_liked": true,
        "likes_count": 4,
      };

      final reply = CommentReply.fromJson(json);
      expect(reply.id, "rep_1");
      expect(reply.name, "Sarah Ahmed");
      expect(reply.username, "sarah_a");
      expect(reply.text, "What time does the bus leave from Arambagh?");
      expect(reply.isLiked, isTrue);
      expect(reply.likesCount, 4);

      final serialized = reply.toJson();
      expect(serialized['text'], "What time does the bus leave from Arambagh?");
      expect(serialized['isLiked'], isTrue);
      expect(serialized['likesCount'], 4);
    });
  });
}
