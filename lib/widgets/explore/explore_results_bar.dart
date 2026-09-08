import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';

class ExploreResultsBar extends StatelessWidget {
  final int resultCount;
  final bool isGridView;
  final VoidCallback onGridTap;
  final VoidCallback onListTap;

  const ExploreResultsBar({
    super.key,
    required this.resultCount,
    required this.isGridView,
    required this.onGridTap,
    required this.onListTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Showing $resultCount "
            "${resultCount == 1 ? 'trip' : 'trips'}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
  children: [
    IconButton(
      onPressed: onGridTap,
      icon: Icon(
        Icons.grid_view_rounded,
        color: isGridView
            ? AppColors.primary
            : const Color(0xFF94A3B8),
      ),
    ),
    IconButton(
      onPressed: onListTap,
      icon: Icon(
        Icons.view_list_rounded,
        color: !isGridView
            ? AppColors.primary
            : const Color(0xFF94A3B8),
      ),
    ),
  ],
),
          ),
        ],
      ),
    );
  }
}