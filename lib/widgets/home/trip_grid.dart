import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/stores/bookmark_store.dart';
import 'package:travel_buddy_finder/stores/trip_store.dart';
import 'package:travel_buddy_finder/widgets/trip_card.dart';
import 'package:travel_buddy_finder/widgets/home/trip_grid_empty_state.dart';

class TripGrid extends StatelessWidget {
  final List<Trip> trips;

  const TripGrid({
    super.key,
    required this.trips,
  });

  Future<void> _confirmDelete(BuildContext context, Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text(
          'Are you sure you want to delete "${trip.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      TripStore.remove(trip.id);
      BookmarkStore.remove(trip.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final crossAxisCount = screenWidth < 600
        ? 1
        : screenWidth < 1000
            ? 2
            : 4;

    final cardHeight = screenWidth < 600 ? 420.0 : 360.0;

    if (trips.isEmpty) {
      return const TripGridEmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trips.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: cardHeight,
      ),
      itemBuilder: (context, index) {
        final trip = trips[index];

        return ValueListenableBuilder<List<dynamic>>(
          valueListenable: BookmarkStore.savedTrips,
          builder: (context, savedTrips, _) {
            return TripCard(
              trip: trip,
              isBookmarked: savedTrips.any((item) => item.id == trip.id),
              onBookmarkToggle: () {
                BookmarkStore.toggle(trip);
              },
              onDelete: () => _confirmDelete(context, trip),
            );
          },
        );
      },
    );
  }
}
