import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';

class ExploreActiveFilters extends StatelessWidget {
  final String category;
  final double budget;
  final String gender;
  final List<String> transportations;
  final bool sorted;

  final VoidCallback onClearAll;
  final VoidCallback onRemoveCategory;
  final VoidCallback onRemoveBudget;
  final VoidCallback onRemoveGender;
  final Function(String) onRemoveTransport;
  final VoidCallback onRemoveSort;

  const ExploreActiveFilters({
    super.key,
    required this.category,
    required this.budget,
    required this.gender,
    required this.transportations,
    required this.sorted,
    required this.onClearAll,
    required this.onRemoveCategory,
    required this.onRemoveBudget,
    required this.onRemoveGender,
    required this.onRemoveTransport,
    required this.onRemoveSort,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          const Text(
            "Active:",
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),

          if (category != "All")
            _tag(category, onRemoveCategory),

          if (budget < 5000)
            _tag("≤ \$${budget.round()}", onRemoveBudget),

          if (gender != "Any (Everyone is welcome)")
            _tag(
              gender.split(' ').first,
              onRemoveGender,
            ),

          ...transportations.map(
            (item) => _tag(
              item,
              () => onRemoveTransport(item),
            ),
          ),

          if (sorted)
            _tag("Sorted", onRemoveSort),

          InkWell(
            onTap: onClearAll,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                "Clear all",
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(
    String label,
    VoidCallback onRemove,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 3, 4, 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}