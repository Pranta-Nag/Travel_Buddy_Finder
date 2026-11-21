import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/trip_provider.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/features/bookmarks/data/bookmark_store.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip.dart';
import 'package:travel_buddy_finder/features/trips/data/stores/trip_store.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/trip_card.dart';

class MyTripScreen extends StatefulWidget {
  const MyTripScreen({super.key});

  @override
  State<MyTripScreen> createState() => _MyTripScreenState();
}

class _MyTripScreenState extends State<MyTripScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().fetchAllTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final apiTrips = tripProvider.trips.map((m) => m.toTrip()).toList();

    return ValueListenableBuilder<int>(
      valueListenable: TripStore.tripListNotifier,
      builder: (context, _, __) {
        final screenWidth = MediaQuery.of(context).size.width;

        final crossAxisCount =
            screenWidth < 600 ? 1 : screenWidth < 1000 ? 2 : 4;
        final cardHeight = screenWidth < 600 ? 420.0 : 360.0;

        final List<Trip> combined = apiTrips.isNotEmpty
            ? apiTrips
            : TripStore.trips;

        final myTrips = combined.where((trip) {
          return CurrentUser.isCurrentUser(
            trip.username,
            inputName: trip.hostName,
          );
        }).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "My Trips",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await context.read<TripProvider>().fetchAllTrips();
            },
            child: myTrips.isEmpty
                ? LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: const Center(
                          child: Text(
                            "You haven't created any trips yet.",
                            style: TextStyle(color: AppColors.greyText),
                          ),
                        ),
                      ),
                    ),
                  )
                : GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: myTrips.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: cardHeight,
                    ),
                    itemBuilder: (context, index) {
                      final trip = myTrips[index];
                      return ValueListenableBuilder<List<dynamic>>(
                        valueListenable: BookmarkStore.savedTrips,
                        builder: (context, savedTrips, _) => TripCard(
                          trip: trip,
                          heroTag: 'mytrip-trip-${trip.id}-$index',
                          isBookmarked:
                              savedTrips.any((item) => item.id == trip.id),
                          onBookmarkToggle: () => BookmarkStore.toggle(trip),
                          onDelete: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Trip'),
                                content: Text(
                                    'Are you sure you want to delete "${trip.title}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.red),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              TripStore.remove(trip.id);
                              final intId = int.tryParse(trip.id.toString());
                              if (intId != null && intId > 0 && context.mounted) {
                                context.read<TripProvider>().deleteTrip(intId);
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
