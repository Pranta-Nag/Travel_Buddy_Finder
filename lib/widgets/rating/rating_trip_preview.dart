import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';

class RatingTripPreview extends StatelessWidget {
  final Trip trip;

  const RatingTripPreview({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTripImage(),

          const SizedBox(width: 12),

          Expanded(
            child: _buildTripInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildTripImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 60,
        height: 60,
        child: trip.imageBytes != null
            ? Image.memory(
                trip.imageBytes!,
                fit: BoxFit.cover,
              )
            : Image.network(
                trip.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.landscape,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTripInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trip.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF0F172A),
          ),
        ),

        const SizedBox(height: 4),

        Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 14,
              color: AppColors.primary,
            ),

            const SizedBox(width: 4),

            Expanded(
              child: Text(
                trip.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.greyText,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}