import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/models/trip_data.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';
import 'package:travel_buddy_finder/widgets/trip_card.dart';
import 'package:travel_buddy_finder/stores/bookmark_store.dart';

class MyTripScreen extends StatefulWidget {
  const MyTripScreen({super.key});

  @override
  State<MyTripScreen> createState() => _MyTripScreenState();
}

class _MyTripScreenState extends State<MyTripScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive grid logic from Home page
    final crossAxisCount = screenWidth < 600 ? 1 : screenWidth < 1000 ? 2 : 4;
    final cardHeight = screenWidth < 600 ? 420.0 : 360.0;

    // Filtering trips created by the user
    final myTrips = tripList.where((trip) => 
      trip.username == '@yeasin' || trip.username == '@you'
    ).toList();

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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: myTrips.isEmpty
          ? const Center(
              child: Text(
                "You haven't created any trips yet.",
                style: TextStyle(color: AppColors.greyText),
              ),
            )
          : GridView.builder(
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
                    isBookmarked: savedTrips.any((item) => item.id == trip.id),
                    onBookmarkToggle: () => BookmarkStore.toggle(trip),
                    onDelete: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Trip'),
                          content: Text('Are you sure you want to delete "${trip.title}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        setState(() {
                          tripList.removeWhere((t) => t.id == trip.id);
                          BookmarkStore.remove(trip.id);
                        });
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
