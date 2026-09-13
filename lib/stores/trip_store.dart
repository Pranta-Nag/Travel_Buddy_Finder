import 'package:flutter/foundation.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/models/trip_data.dart';
import 'package:travel_buddy_finder/stores/bookmark_store.dart';

class TripStore {
  TripStore._();

  static final ValueNotifier<int> tripListNotifier = ValueNotifier<int>(0);

  static List<Trip> get trips => tripList;

  static void add(Trip trip) {
    tripList.add(trip);
    tripListNotifier.value += 1;
  }

  static void update(Trip updatedTrip) {
    final index = tripList.indexWhere((t) => t.id == updatedTrip.id);
    if (index != -1) {
      tripList[index] = updatedTrip;
      tripListNotifier.value += 1;
      BookmarkStore.update(updatedTrip);
    }
  }

  static void remove(String tripId) {
    tripList.removeWhere((t) => t.id == tripId);
    tripListNotifier.value += 1;
    BookmarkStore.remove(tripId);
  }

  static void removeAll(Iterable<String> tripIds) {
    final ids = tripIds.toSet();
    tripList.removeWhere((t) => ids.contains(t.id));
    for (final id in ids) {
      BookmarkStore.remove(id);
    }
    tripListNotifier.value += 1;
  }

  static void refresh() {
    tripListNotifier.value += 1;
  }
}
