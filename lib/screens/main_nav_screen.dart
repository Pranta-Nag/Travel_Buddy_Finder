import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/screens/explore_screen.dart';
import 'package:travel_buddy_finder/screens/add_new_trip_screen.dart';
import 'package:travel_buddy_finder/screens/user_profile_screen.dart';
import 'package:travel_buddy_finder/models/trip_data.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';
import 'package:travel_buddy_finder/utils/bookmark_store.dart';
import 'package:travel_buddy_finder/widgets/screen_background.dart';
import 'package:travel_buddy_finder/widgets/trip_card.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      _buildHomeTab(),
      const ExploreScreen(),
      _ChatTab(),
      UserProfileScreen(),
    ];

    return Scaffold(
      body: ScreenBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddNewTripScreen(),
              ),
            );
            setState(() {});
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10.0,
          color: Colors.white,
          elevation: 0,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: "HOME",
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.search_rounded,
                  activeIcon: Icons.search_rounded,
                  label: "EXPLORE",
                  index: 1,
                ),
                const SizedBox(width: 48),
                _buildNavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: "CHAT",
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: "PROFILE",
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPLORE FEED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Find Travel Buddies',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_none_outlined,
                    color: Colors.grey.shade800,
                    size: 22,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildSearchBar(),
          const SizedBox(height: 22),
          _buildCategories(),
          const SizedBox(height: 24),
          _buildSectionHeader('Popular Trips'),
          const SizedBox(height: 12),
          _buildTripGrid(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search destinations...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.tune_rounded, color: Colors.white, size: 16),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['All', 'Adventure', 'Beach', 'Cultural', 'Family', 'Romantic', 'Wildlife'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _CategoryPill(
              label: cat,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child:const Text(
            'See All',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

 Widget _buildTripGrid() {
  final screenWidth = MediaQuery.of(context).size.width;

  // Responsive grid
  final crossAxisCount = screenWidth < 600
      ? 1
      : screenWidth < 1000
          ? 2
          : 4;

  // Mobile card needs more height because
  // action buttons are arranged in separate rows.
  final cardHeight = screenWidth < 600 ? 420.0 : 360.0;

  final filteredTrips = _selectedCategory == 'All'
      ? tripList
      : tripList
          .where((t) => t.category == _selectedCategory)
          .toList();

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: filteredTrips.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      mainAxisExtent: cardHeight,
    ),
    itemBuilder: (context, index) {
      final trip = filteredTrips[index];

      return ValueListenableBuilder<List<dynamic>>(
        valueListenable: BookmarkStore.savedTrips,
        builder: (context, savedTrips, _) {
          return TripCard(
            trip: trip,
            isBookmarked:
                savedTrips.any((item) => item.id == trip.id),

            onBookmarkToggle: () {
              BookmarkStore.toggle(trip);
            },

            onDelete: () async {
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
                setState(() {
                  tripList.removeWhere(
                    (t) => t.id == trip.id,
                  );

                  BookmarkStore.remove(trip.id);
                });
              }
            },
          );
        },
      );
    },
  );
}

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey.shade400,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class _ChatTab extends StatelessWidget {
  const _ChatTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Chat Screen"));
  }
}
