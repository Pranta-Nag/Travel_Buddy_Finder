import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';

class ExploreHeader extends StatelessWidget {
  final int totalTrips;
  final int activeFilterCount;
  final TextEditingController searchController;
  final VoidCallback onFilterTap;
  final VoidCallback onSearchChanged;

  const ExploreHeader({
    super.key,
    required this.totalTrips,
    required this.activeFilterCount,
    required this.searchController,
    required this.onFilterTap,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(
                            alpha: .12,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "DISCOVER",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: .8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$totalTrips Trips Available",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Find Travel Buddies",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    onTap: onFilterTap,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: activeFilterCount > 0
                            ? AppColors.primary
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: activeFilterCount > 0
                            ? Colors.white
                            : const Color(0xFF334155),
                      ),
                    ),
                  ),
                  if (activeFilterCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: const Color(0xFFEF4444),
                        child: Text(
                          "$activeFilterCount",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (_) => onSearchChanged(),
              decoration: InputDecoration(
                hintText:
                    "Search destinations, hosts, activities...",
                prefixIcon: const Icon(
                  Icons.search_rounded,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged();
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}