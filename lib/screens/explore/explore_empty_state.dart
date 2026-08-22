import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';

class ExploreEmptyState extends StatelessWidget {
  final VoidCallback onReset;

  const ExploreEmptyState({
    super.key,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: .1,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No trips found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "We couldn't find any trips matching your "
              "current search and filters. Try tweaking "
              "your criteria.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Reset All Filters"),
            ),
          ],
        ),
      ),
    );
  }
}