import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_buddy_finder/api/models/rating_model.dart';
import 'package:travel_buddy_finder/api/models/trip_map_model.dart';
import 'package:travel_buddy_finder/api/models/trip_model.dart';
import 'package:travel_buddy_finder/api/models/trip_rating_model.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/map/trip_route_planner_widget.dart';

void main() {
  group('Rating Models & Parsing Tests', () {
    test('TripRatingDetail correctly parses backend JSON response', () {
      final json = {
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

      final detail = TripRatingDetail.fromJson(json);

      expect(detail.tripId, 4);
      expect(detail.tripTitle, "Sylhet Ratargul & Jaflong Tour");
      expect(detail.hostUsername, "tanjim_traveler");
      expect(detail.averageRating, 4.5);
      expect(detail.totalRatings, 2);
      expect(detail.hasRated, true);
      expect(detail.userRating, 5);
      expect(detail.breakdown[5], 1);
      expect(detail.breakdown[4], 1);
      expect(detail.breakdown[1], 0);
    });

    test('TripRatingDetail safely handles empty or null data', () {
      final detail = TripRatingDetail.fromJson({});
      expect(detail.tripId, 0);
      expect(detail.averageRating, 0.0);
      expect(detail.totalRatings, 0);
      expect(detail.hasRated, false);
      expect(detail.userRating, isNull);
      expect(detail.breakdown[5], 0);
    });
  });

  group('TripMapModel & Waypoints Tests', () {
    test('TripMapModel correctly deserializes waypoints and route coordinates', () {
      final json = {
        "start_location": "Dhaka Arambagh Bus Counter",
        "distance_km": 395.0,
        "duration_hours": 8.8,
        "waypoints": [
          {
            "order": 1,
            "name": "Dhaka Arambagh Bus Station",
            "label": "Trip Start",
            "lat": 23.7315,
            "lon": 90.4182,
            "color": "green"
          },
          {
            "order": 2,
            "name": "Cumilla Shahjahan Hotel",
            "label": "Toilet Break",
            "lat": 23.4607,
            "lon": 91.1809,
            "color": "amber"
          },
          {
            "order": 3,
            "name": "Cox's Bazar Kolatoli Point",
            "label": "Destination",
            "lat": 21.4272,
            "lon": 91.9701,
            "color": "red"
          }
        ],
        "route_coordinates": [
          [90.4182, 23.7315],
          [91.1809, 23.4607],
          [91.9701, 21.4272]
        ]
      };

      final mapModel = TripMapModel.fromJson(json);

      expect(mapModel.startLocation, "Dhaka Arambagh Bus Counter");
      expect(mapModel.distanceKm, 395.0);
      expect(mapModel.durationHours, 8.8);
      expect(mapModel.waypoints.length, 3);
      expect(mapModel.waypoints.first.name, "Dhaka Arambagh Bus Station");
      expect(mapModel.waypoints.first.color, "green");
      expect(mapModel.waypoints[1].label, "Toilet Break");
      expect(mapModel.waypoints.last.label, "Destination");
      expect(mapModel.routeCoordinates.length, 3);
      expect(mapModel.hasRouteData, true);
    });

    test('TripModel parses embedded map and rating_count correctly', () {
      final tripJson = {
        "id": 8,
        "title": "Dhaka to Cox's Bazar Road Trip with Stops",
        "destination": "Cox's Bazar Kolatoli Beach",
        "budget": 7000.0,
        "start_day": "2026-12-10",
        "end_day": "2026-12-14",
        "category": "adventure",
        "description": "Updated budget and added Feni highway tea break!",
        "host_username": "galib",
        "available_seats": 6,
        "rating": 4.8,
        "rating_count": 5,
        "map": {
          "start_location": "Dhaka Arambagh Bus Counter",
          "distance_km": 395.0,
          "duration_hours": 8.8,
          "waypoints": [
            {
              "order": 1,
              "name": "Dhaka Arambagh Bus Station",
              "label": "Trip Start",
              "lat": 23.7315,
              "lon": 90.4182,
              "color": "green"
            }
          ]
        }
      };

      final tripModel = TripModel.fromJson(tripJson);

      expect(tripModel.id, 8);
      expect(tripModel.title, "Dhaka to Cox's Bazar Road Trip with Stops");
      expect(tripModel.rating, "4.8");
      expect(tripModel.ratingCount, 5);
      expect(tripModel.mapData, isNotNull);
      expect(tripModel.mapData!.startLocation, "Dhaka Arambagh Bus Counter");
      expect(tripModel.mapData!.waypoints.length, 1);

      final trip = tripModel.toTrip();
      expect(trip.rating, "4.8");
      expect(trip.ratingCount, 5);
      expect(trip.tripMap, isNotNull);
      expect(trip.tripMap!.startLocation, "Dhaka Arambagh Bus Counter");
    });

    test('TripMapData toJson and fromJson preserve GeoJSON [lon, lat] convention', () {
      final data = TripMapData(
        startLocation: 'Dhaka',
        distanceKm: 300.0,
        durationHours: 6.5,
        waypoints: [
          WaypointItem(
            order: 1,
            name: 'Dhaka Zero Point',
            label: 'Trip Start',
            lat: 23.7289,
            lon: 90.4109,
          ),
          WaypointItem(
            order: 2,
            name: 'Cox\'s Bazar',
            label: 'Destination',
            lat: 21.4272,
            lon: 91.9701,
          ),
        ],
        routeCoordinates: [
          const LatLng(23.7289, 90.4109),
          const LatLng(21.4272, 91.9701),
        ],
      );

      final json = data.toJson();
      expect(json['route_coordinates'], [
        [90.4109, 23.7289],
        [91.9701, 21.4272],
      ]);

      final restored = TripMapData.fromJson(json);
      expect(restored.routeCoordinates.length, 2);
      expect(restored.routeCoordinates.first.latitude, 23.7289);
      expect(restored.routeCoordinates.first.longitude, 90.4109);
    });

    test('TripRatingSummary parses guideline Table 6 schema', () {
      final json = {
        "status": "success",
        "data": {
          "trip_id": 12,
          "average_rating": 4.8,
          "total_ratings": 15,
          "distribution": {
            "5_star": 12,
            "4_star": 2,
            "3_star": 1,
            "2_star": 0,
            "1_star": 0
          },
          "user_status": {
            "has_rated": true,
            "user_rating": 5
          }
        }
      };

      final summary = TripRatingSummary.fromJson(json);
      expect(summary.tripId, 12);
      expect(summary.averageRating, 4.8);
      expect(summary.totalRatings, 15);
      expect(summary.hasRated, true);
      expect(summary.userRating, 5);
      expect(summary.distribution[5], 12);
      expect(summary.distribution[3], 1);
    });

    testWidgets('TripRoutePlannerWidget renders Destination & Label text fields, Add button, and OSM canvas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TripRoutePlannerWidget(
                onRouteReady: (map) {},
              ),
            ),
          ),
        ),
      );

      // Verify 1. Destination / Stop Place text field exists
      expect(find.text('1. Destination / Stop Place'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Destination & Label

      // Verify 2. Stop Label text field exists
      expect(find.text('2. Stop Label'), findsOneWidget);

      // Verify Add Stop button exists
      expect(find.text('Add Stop to Route'), findsOneWidget);

      // Verify quick preset chips exist
      expect(find.text('Start'), findsWidgets);
      expect(find.text('Toilet break'), findsWidgets);
      expect(find.text('Destination'), findsWidgets);

      // Verify initial label is 'Start'
      final labelField = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(labelField.controller?.text, 'Start');

      // Tapping a preset chip updates the label text field
      await tester.tap(find.text('Toilet break').first);
      await tester.pump();
      expect(labelField.controller?.text, 'Toilet break');
    });
  });
}
