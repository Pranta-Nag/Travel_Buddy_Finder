import 'package:flutter/foundation.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/models/trip_data.dart';

class TripStore {
  TripStore._();

  static final ValueNotifier<int> tripListNotifier = ValueNotifier<int>(0);

  static List<Trip> get trips => tripList;

  static void add(Trip trip) {
    tripList.add(trip);
    tripListNotifier.value += 1;
  }

  static void remove(String tripId) {
    tripList.removeWhere((t) => t.id == tripId);
    tripListNotifier.value += 1;
  }

  static void removeAll(Iterable<String> tripIds) {
    final ids = tripIds.toSet();
    tripList.removeWhere((t) => ids.contains(t.id));
    tripListNotifier.value += 1;
  }

  static void refresh() {
    tripListNotifier.value += 1;
  }
}
