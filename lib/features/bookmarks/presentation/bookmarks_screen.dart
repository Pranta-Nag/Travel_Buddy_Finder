import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/bookmark_provider.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/trip_card.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BookmarkProvider>().fetchMyBookmarks(silent: false);
      }
    });
  }

  void _handleBookmarkToggle(BuildContext context, Trip trip) async {
    final provider = context.read<BookmarkProvider>();
    final result = await provider.toggleBookmark(trip);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isBookmarked
              ? 'Trip added to bookmarks'
              : 'Trip removed from bookmarks',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: !result.isBookmarked
            ? SnackBarAction(
                label: 'Undo',
                textColor: Colors.amber,
                onPressed: () {
                  provider.addBookmark(trip.id, trip: trip);
                },
              )
            : null,
      ),
    );
  }

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
        actions: [
          Consumer<BookmarkProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
                onPressed: () => provider.fetchMyBookmarks(),
              );
            },
          ),
        ],
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, provider, _) {
          // 1. Initial full-page loading state
          if (provider.isLoading && provider.savedTrips.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          final trips = provider.savedTrips;

          // 2. Empty state
          if (trips.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => provider.fetchMyBookmarks(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.bookmark_border_rounded,
                                size: 56,
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
                              'Tap the bookmark icon on any trip card to save it for your next adventure.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.explore_rounded, size: 18),
                              label: const Text('Explore Trips'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // 3. Grid View with Responsive Columns & Memory-Efficient builder
          final screenWidth = MediaQuery.of(context).size.width;
          final crossAxisCount = screenWidth < 600
              ? 1
              : screenWidth < 1000
                  ? 2
                  : 4;
          final cardHeight = screenWidth < 600 ? 420.0 : 370.0;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => provider.fetchMyBookmarks(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: cardHeight,
              ),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return TripCard(
                  trip: trip,
                  heroTag: 'bookmark-trip-${trip.id}-$index',
                  isBookmarked: true,
                  onBookmarkToggle: () => _handleBookmarkToggle(context, trip),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
