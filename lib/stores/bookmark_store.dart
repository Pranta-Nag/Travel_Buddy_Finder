import 'package:flutter/foundation.dart';
import 'package:travel_buddy_finder/models/trip.dart';

class BookmarkStore {
  BookmarkStore._();

  static final ValueNotifier<List<Trip>> savedTrips = ValueNotifier([]);

  static void toggle(Trip trip) {
    final trips = List<Trip>.from(savedTrips.value);
    final index = trips.indexWhere((item) => item.id == trip.id);
    index >= 0 ? trips.removeAt(index) : trips.add(trip);
    savedTrips.value = trips;
  }

  static void remove(String tripId) {
    savedTrips.value =
        savedTrips.value.where((trip) => trip.id != tripId).toList();
  }
}
