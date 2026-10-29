import 'package:flutter/foundation.dart';
import 'package:travel_buddy_finder/api/providers/bookmark_provider.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip.dart';

class BookmarkStore {
  BookmarkStore._();

  static final ValueNotifier<List<Trip>> savedTrips = ValueNotifier([]);

  static void syncWithProvider(List<Trip> trips) {
    savedTrips.value = List.unmodifiable(trips);
  }

  static void toggle(Trip trip) {
    final provider = BookmarkProvider.instance;
    if (provider != null) {
      provider.toggleBookmark(trip);
      return;
    }

    // Fallback if provider instance is not yet mounted
    final trips = List<Trip>.from(savedTrips.value);
    final index = trips.indexWhere((item) => item.id == trip.id);
    if (index >= 0) {
      trips.removeAt(index);
    } else {
      trips.add(trip);
    }
    savedTrips.value = trips;
  }

  static void update(Trip updatedTrip) {
    final trips = List<Trip>.from(savedTrips.value);
    final index = trips.indexWhere((item) => item.id == updatedTrip.id);
    if (index >= 0) {
      trips[index] = updatedTrip;
      savedTrips.value = trips;
    }
  }

  static void remove(String tripId) {
    final provider = BookmarkProvider.instance;
    if (provider != null) {
      provider.removeBookmark(tripId);
      return;
    }

    savedTrips.value =
        savedTrips.value.where((trip) => trip.id != tripId).toList();
  }
}
