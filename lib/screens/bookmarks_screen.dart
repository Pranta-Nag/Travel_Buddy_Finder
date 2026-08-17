import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';
import 'package:travel_buddy_finder/utils/bookmark_store.dart';
import 'package:travel_buddy_finder/widgets/trip_card.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          'Saved Trips',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FB),
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        centerTitle: false,
      ),
      body: ValueListenableBuilder<List<Trip>>(
        valueListenable: BookmarkStore.savedTrips,
        builder: (context, trips, _) {
          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bookmark_border_rounded,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No saved trips yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the bookmark icon on any trip to save it here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          final crossAxisCount = MediaQuery.of(context).size.width < 600 ? 2 : 4;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return TripCard(
                trip: trip,
                isBookmarked: true,
                onBookmarkToggle: () => BookmarkStore.remove(trip.id),
              );
            },
          );
        },
      ),
    );
  }
}
