import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy_finder/models/trip_request.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';
import 'package:travel_buddy_finder/widgets/trip_request/approval_action.dart';

class TripRequestItem extends StatelessWidget {
  final TripRequest request;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const TripRequestItem({
    super.key,
    required this.request,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final trip = request.trip;
    final time = DateFormat('MMM d, h:mm a').format(request.createdAt);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.fieldColor,
                backgroundImage: NetworkImage(request.requesterAvatarUrl),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requesterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${request.requesterUsername} • ${request.hostName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.greyText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            trip.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 12,
                color: AppColors.primary,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  trip.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (request.isPending)
            ApprovalAction(
              onApprove: onApprove,
              onReject: onReject,
            )
          else
            _StatusChip(status: request.status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TripRequestStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status) {
      case TripRequestStatus.approved:
        bgColor = Colors.green.shade50;
        textColor = const Color(0xFF166534);
        icon = Icons.check_circle_rounded;
        label = 'Approved';
        break;
      case TripRequestStatus.rejected:
        bgColor = Colors.red.shade50;
        textColor = const Color(0xFF7F1D1D);
        icon = Icons.cancel_rounded;
        label = 'Not Approved';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = const Color(0xFF374151);
        icon = Icons.schedule_rounded;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
