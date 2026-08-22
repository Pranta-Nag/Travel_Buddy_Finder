import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';

class RatingSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RatingSubmitButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 2,
          shadowColor:
              AppColors.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 18,
            ),

            SizedBox(width: 8),

            Text(
              'Submit Review',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}