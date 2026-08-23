
import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/models/trip_data.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';
import 'package:travel_buddy_finder/stores/trip_store.dart';
import 'package:travel_buddy_finder/widgets/screen_background.dart';

import '../widgets/explore/explore_active_filters.dart';
import '../widgets/explore/explore_category_bar.dart';
import '../widgets/explore/explore_empty_state.dart';
import '../widgets/explore/explore_filter.dart';
import '../widgets/explore/explore_filter_sheet.dart';
import '../widgets/explore/explore_header.dart';
import '../widgets/explore/explore_results_bar.dart';
import '../widgets/explore/explore_trip_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  double _budgetCap = ExploreFilterData.maxBudget;

  String _selectedGender = ExploreFilterData.anyGender;

  String _selectedCategory = ExploreFilterData.allCategory;

  final List<String> _selectedTransportations = [];

  SortOption _sortOption = SortOption.recommended;

  bool _isGridView = true;

  double _price(String value) {
    return double.tryParse(
          value.replaceAll(RegExp(r'[^\d.]'), ''),
        ) ??
        0;
  }

  List<Trip> get _filteredTrips {
    final query =
        _searchController.text.trim().toLowerCase();

    final result = tripList.where((trip) {
      final matchesSearch =
          query.isEmpty ||
          trip.title.toLowerCase().contains(query) ||
          trip.location.toLowerCase().contains(query) ||
          trip.description.toLowerCase().contains(query) ||
          trip.hostName.toLowerCase().contains(query);

      final matchesBudget =
          _price(trip.price) <= _budgetCap;

      final matchesGender =
          _selectedGender == ExploreFilterData.anyGender ||
          trip.genderPreference == _selectedGender;

      final matchesCategory =
          _selectedCategory == ExploreFilterData.allCategory ||
          trip.category.toLowerCase() ==
              _selectedCategory.toLowerCase();

      final matchesTransport =
          _selectedTransportations.isEmpty ||
          (trip.transportationMethods != null &&
              _selectedTransportations.any(
                (item) => trip.transportationMethods!.contains(item),
              ));

      return matchesSearch &&
          matchesBudget &&
          matchesGender &&
          matchesCategory &&
          matchesTransport;
    }).toList();

    _sortTrips(result);

    return result;
  }

  void _sortTrips(List<Trip> trips) {
    switch (_sortOption) {
      case SortOption.priceLowToHigh:
        trips.sort(
          (a, b) => _price(a.price).compareTo(
            _price(b.price),
          ),
        );
        break;

      case SortOption.priceHighToLow:
        trips.sort(
          (a, b) => _price(b.price).compareTo(
            _price(a.price),
          ),
        );
        break;

      case SortOption.highestRated:
        trips.sort((a, b) {
          final ratingA =
              double.tryParse(a.rating) ?? 0;

          final ratingB =
              double.tryParse(b.rating) ?? 0;

          return ratingB.compareTo(ratingA);
        });
        break;

      case SortOption.recommended:
        break;
    }
  }

  int get _activeFilterCount {
    int count = 0;

    if (_budgetCap < ExploreFilterData.maxBudget) {
      count++;
    }

    if (_selectedGender != ExploreFilterData.anyGender) {
      count++;
    }

    count += _selectedTransportations.length;

    if (_selectedCategory != ExploreFilterData.allCategory) {
      count++;
    }

    if (_sortOption != SortOption.recommended) {
      count++;
    }

    return count;
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();

      _budgetCap = ExploreFilterData.maxBudget;

      _selectedGender = ExploreFilterData.anyGender;

      _selectedCategory = ExploreFilterData.allCategory;

      _selectedTransportations.clear();

      _sortOption = SortOption.recommended;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Filters reset successfully"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ExploreFilterSheet(
          initialBudget: _budgetCap,
          initialGender: _selectedGender,
          initialTransportations: _selectedTransportations,
          initialCategory: _selectedCategory,
          initialSort: _sortOption,
          onApply: (
            budget,
            gender,
            transportations,
            category,
            sort,
          ) {
            setState(() {
              _budgetCap = budget;
              _selectedGender = gender;

              _selectedTransportations
                ..clear()
                ..addAll(transportations);

              _selectedCategory = category;
              _sortOption = sort;
            });
          },
        );
      },
    );
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  void initState() {
    super.initState();
    TripStore.tripListNotifier.addListener(_onTripListChanged);
  }

  @override
  void dispose() {
    TripStore.tripListNotifier.removeListener(_onTripListChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onTripListChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final trips = _filteredTrips;

    return Scaffold(
     // backgroundColor: const Color(0xFFF8FAFC),
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              ExploreHeader(
                totalTrips: tripList.length,
                activeFilterCount: _activeFilterCount,
                searchController: _searchController,
                onFilterTap: _openFilterSheet,
                onSearchChanged: () {
                  setState(() {});
                },
              ),
        
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: CustomScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 14,
                            bottom: 8,
                          ),
                          child: ExploreCategoryBar(
                            selectedCategory: _selectedCategory,
                            onCategorySelected: _selectCategory,
                          ),
                        ),
                      ),
        
                      if (_activeFilterCount > 0)
                        SliverToBoxAdapter(
                          child: ExploreActiveFilters(
                            category: _selectedCategory,
                            budget: _budgetCap,
                            gender: _selectedGender,
                            transportations:
                                _selectedTransportations,
                            sorted: _sortOption !=
                                SortOption.recommended,
                            onClearAll: _resetFilters,
                            onRemoveCategory: () {
                              setState(() {
                                _selectedCategory =
                                    ExploreFilterData.allCategory;
                              });
                            },
                            onRemoveBudget: () {
                              setState(() {
                                _budgetCap =
                                    ExploreFilterData.maxBudget;
                              });
                            },
                            onRemoveGender: () {
                              setState(() {
                                _selectedGender =
                                    ExploreFilterData.anyGender;
                              });
                            },
                            onRemoveTransport: (item) {
                              setState(() {
                                _selectedTransportations.remove(item);
                              });
                            },
                            onRemoveSort: () {
                              setState(() {
                                _sortOption =
                                    SortOption.recommended;
                              });
                            },
                          ),
                        ),
        
                      SliverToBoxAdapter(
                        child: ExploreResultsBar(
                          resultCount: trips.length,
                          isGridView: _isGridView,
                          onGridTap: () {
                            setState(() {
                              _isGridView = true;
                            });
                          },
                          onListTap: () {
                            setState(() {
                              _isGridView = false;
                            });
                          },
                        ),
                      ),
        
                      if (trips.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: ExploreEmptyState(
                            onReset: _resetFilters,
                          ),
                        )
                      else if (_isGridView)
                        _buildGrid(trips)
                      else
                        _buildList(trips),
        
                       const SliverToBoxAdapter(
                         child: SizedBox(height: 80),
                       ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),
      );
    }

  Widget _buildGrid(List<Trip> trips) {
    final width = MediaQuery.of(context).size.width;

    // Mobile/Tablet = 2 cards
    // Web/Desktop = 3 cards
    final int columns = width < 900 ? 2 : 3;

    final double cardHeight = width < 600
        ? 280.0
        : 260.0;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      sliver: SliverGrid(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 14,
          mainAxisSpacing: 16,
          mainAxisExtent: cardHeight,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ExploreTripCard(
              key: ValueKey(
                'explore-grid-${trips[index].id}',
              ),
              trip: trips[index],
              gridView: true,
            );
          },
          childCount: trips.length,
        ),
      ),
    );
  }

  Widget _buildList(List<Trip> trips) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
              ),
              child: ExploreTripCard(
                key: ValueKey(
                  'explore-list-${trips[index].id}',
                ),
                trip: trips[index],
                gridView: false,
              ),
            );
          },
          childCount: trips.length,
        ),
      ),
    );
  }
}

