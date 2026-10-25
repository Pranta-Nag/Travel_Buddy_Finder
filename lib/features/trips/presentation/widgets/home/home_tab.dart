import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/trip_provider.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip_data.dart';
import 'package:travel_buddy_finder/features/trips/data/stores/trip_store.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/home/home_header.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/home/home_search_bar.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/home/category_bar.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/home/section_header.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/home/trip_grid.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().fetchAllTrips();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _searchQuery => _searchController.text.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final apiTripModels = tripProvider.trips;

    // Use API trips if available, otherwise fallback to demo tripList
    final List<Trip> sourceList = apiTripModels.isNotEmpty
        ? apiTripModels.map((m) => m.toTrip()).toList()
        : tripList;

    final byCategory = _selectedCategory == 'All'
        ? sourceList
        : sourceList.where((t) => t.category == _selectedCategory);

    final query = _searchQuery;
    final List<Trip> filteredTrips = query.isEmpty
        ? byCategory.toList()
        : byCategory.where((t) {
            final title = t.title.toLowerCase();
            final location = t.location.toLowerCase();
            final host = t.hostName.toLowerCase();
            final description = t.description.toLowerCase();
            return title.contains(query) ||
                location.contains(query) ||
                host.contains(query) ||
                description.contains(query);
          }).toList();

    return SafeArea(
      child: ValueListenableBuilder<int>(
        valueListenable: TripStore.tripListNotifier,
        builder: (context, _, __) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 8),
              const HomeHeader(),
              const SizedBox(height: 18),
              HomeSearchBar(
                controller: _searchController,
                query: _searchQuery,
                onChanged: () => setState(() {}),
                onClear: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
              const SizedBox(height: 22),
              CategoryBar(
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) {
                  setState(() => _selectedCategory = cat);
                  context.read<TripProvider>().fetchTripsByCategory(cat);
                },
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Popular Trips'),
              const SizedBox(height: 12),
              tripProvider.isLoading && apiTripModels.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : TripGrid(trips: filteredTrips),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
