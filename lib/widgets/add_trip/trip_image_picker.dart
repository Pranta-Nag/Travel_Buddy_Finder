import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';

class TripImagePicker extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onTap;

  const TripImagePicker({
    super.key,
    required this.imageBytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.fieldColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor.withValues(
              alpha: 0.2,
            ),
          ),
        ),
        child: imageBytes != null
            ? _buildSelectedImage()
            : _buildEmptyState(),
      ),
    );
  }

  Widget _buildSelectedImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.memory(
        imageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.1,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_a_photo_rounded,
            size: 32,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Upload Cover Photo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.greyText,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Tap to select from gallery',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.greyText.withValues(
              alpha: 0.7,
            ),
          ),
        ),
      ],
    );
  }
}