import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';

class RatingStarsCard extends StatelessWidget {
  final String hostName;
  final int rating;
  final String ratingLabel;
  final ValueChanged<int> onRatingChanged;

  const RatingStarsCard({
    super.key,
    required this.hostName,
    required this.rating,
    required this.ratingLabel,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'How was your trip with $hostName?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Your feedback helps the travel community grow safely and trustfully.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.greyText,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          _buildStars(),

          const SizedBox(height: 12),

          _buildRatingLabel(),
        ],
      ),
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) {
          final starValue = index + 1;
          final isSelected = starValue <= rating;

          return GestureDetector(
            onTap: () {
              onRatingChanged(starValue);
            },
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 200,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
              ),
              child: Icon(
                isSelected
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: isSelected
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFFCBD5E1),
                size: 44,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        ratingLabel,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF92400E),
        ),
      ),
    );
  }
}