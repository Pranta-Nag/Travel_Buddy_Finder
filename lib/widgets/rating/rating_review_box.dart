import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';

class RatingReviewBox extends StatelessWidget {
  final TextEditingController controller;
  final bool wouldRecommend;
  final ValueChanged<bool> onRecommendationChanged;

  const RatingReviewBox({
    super.key,
    required this.controller,
    required this.wouldRecommend,
    required this.onRecommendationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),

          const SizedBox(height: 12),

          _buildTextField(),

          const SizedBox(height: 12),

          _buildRecommendation(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Write a Review',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),

        Text(
          'Optional',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        maxLength: 400,
        textCapitalization:
            TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText:
              'Share tips, vibes, safety experiences, or fun moments from this trip...',
          hintStyle: TextStyle(
            fontSize: 13,
            color: AppColors.greyText,
          ),
          contentPadding: EdgeInsets.all(14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRecommendation() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text(
            'Would you travel with this buddy again?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ),

        Switch.adaptive(
          value: wouldRecommend,
          activeThumbColor: AppColors.primary,
          activeTrackColor:
              AppColors.primary.withValues(alpha: 0.4),
          onChanged: onRecommendationChanged,
        ),
      ],
    );
  }
}