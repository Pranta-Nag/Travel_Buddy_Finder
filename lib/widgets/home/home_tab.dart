import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/models/trip_data.dart';
import 'package:travel_buddy_finder/stores/trip_store.dart';
import 'package:travel_buddy_finder/widgets/home/home_header.dart';
import 'package:travel_buddy_finder/widgets/home/home_search_bar.dart';
import 'package:travel_buddy_finder/widgets/home/category_bar.dart';
import 'package:travel_buddy_finder/widgets/home/section_header.dart';
import 'package:travel_buddy_finder/widgets/home/trip_grid.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _searchQuery => _searchController.text.trim().toLowerCase();

  List<Trip> get _filteredTrips {
    final query = _searchQuery;
    final byCategory = _selectedCategory == 'All'
        ? tripList
        : tripList.where((t) => t.category == _selectedCategory);
    if (query.isEmpty) return byCategory.toList();
    return byCategory.where((t) {
      final title = t.title.toLowerCase();
      final location = t.location.toLowerCase();
      final host = t.hostName.toLowerCase();
      final description = t.description.toLowerCase();
      return title.contains(query) ||
          location.contains(query) ||
          host.contains(query) ||
          description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                },
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Popular Trips'),
              const SizedBox(height: 12),
              TripGrid(trips: _filteredTrips),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
