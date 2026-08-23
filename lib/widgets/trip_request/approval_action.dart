import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';

class ApprovalAction extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const ApprovalAction({
    super.key,
    this.isProcessing = false,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 34,
          child: ElevatedButton.icon(
            onPressed: isProcessing ? null : onApprove,
            style: style.copyWith(
              backgroundColor: WidgetStateProperty.all(AppColors.success),
            ),
            icon: isProcessing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 16),
            label: const Text(
              'Approve',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 34,
          child: ElevatedButton.icon(
            onPressed: isProcessing ? null : onReject,
            style: style.copyWith(
              backgroundColor: WidgetStateProperty.all(AppColors.error),
            ),
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text(
              'Not Approve',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
