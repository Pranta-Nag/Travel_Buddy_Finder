import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/utils/bookmark_store.dart';
import 'package:travel_buddy_finder/widgets/trip_card.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
            title: const Text('Saved trips'),
            backgroundColor: const Color(0xFFF8F9FB),
            foregroundColor: const Color(0xFF1F2937),
            elevation: 0),
        body: ValueListenableBuilder<List<Trip>>(
          valueListenable: BookmarkStore.savedTrips,
          builder: (context, trips, _) => trips.isEmpty
              ? const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.bookmark_border_rounded,
                      size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No saved trips yet',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text('Tap a trip bookmark icon to save it.',
                      style: TextStyle(color: Colors.grey))
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: trips.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, index) {
                    final trip = trips[index];
                    return TripCard(
                        trip: trip,
                        isBookmarked: true,
                        onBookmarkToggle: () => BookmarkStore.remove(trip.id));
                  }),
        ),
      );
}
