import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';

class TripSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;

  const TripSectionTitle({
    super.key,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = icon ?? _defaultIconForTitle(title);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              effectiveIcon,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  IconData _defaultIconForTitle(String t) {
    final lower = t.toLowerCase();
    if (lower.contains('detail') || lower.contains('trip')) {
      return Icons.explore_outlined;
    } else if (lower.contains('schedule') || lower.contains('budget')) {
      return Icons.calendar_month_outlined;
    } else if (lower.contains('transport') || lower.contains('seat')) {
      return Icons.commute_outlined;
    } else if (lower.contains('photo') || lower.contains('cover')) {
      return Icons.add_photo_alternate_outlined;
    } else if (lower.contains('more') || lower.contains('description')) {
      return Icons.notes_outlined;
    }
    return Icons.label_outline_rounded;
  }
}
