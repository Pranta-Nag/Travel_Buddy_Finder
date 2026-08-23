import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/models/trip_request.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';
import 'package:travel_buddy_finder/stores/current_user.dart';
import 'package:travel_buddy_finder/stores/notification_store.dart';
import 'package:travel_buddy_finder/stores/trip_request_store.dart';
import 'package:travel_buddy_finder/widgets/trip_request/trip_request_item.dart';

class ApprovalsDrawer extends StatefulWidget {
  const ApprovalsDrawer({super.key});

  @override
  State<ApprovalsDrawer> createState() => _ApprovalsDrawerState();
}

class _ApprovalsDrawerState extends State<ApprovalsDrawer> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    const hostUsername = CurrentUser.username;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ValueListenableBuilder<List<TripRequest>>(
                valueListenable: TripRequestStore.requests,
                builder: (context, requests, _) {
                  final all = TripRequestStore.allForHost(hostUsername);
                  if (all.isEmpty) return const _EmptyState();

                  final pending = all.where((r) => r.isPending).toList();
                  final decided = all.where((r) => !r.isPending).toList();

                  return ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      if (pending.isNotEmpty) ...[
                        const _SectionHeader('Pending Requests'),
                        ...pending.map(
                          (r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TripRequestItem(
                              request: r,
                              onApprove: _isProcessing
                                  ? null
                                  : () => _handleApprove(r),
                              onReject:
                                  _isProcessing ? null : () => _handleReject(r),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (decided.isNotEmpty) ...[
                        const _SectionHeader('Your Decisions'),
                        ...decided.map(
                          (r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TripRequestItem(request: r),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Trip Approvals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApprove(TripRequest request) async {
    setState(() => _isProcessing = true);
    await _applyDecision(
      request,
      TripRequestStatus.approved,
      title: 'Request Approved',
      body: '${request.hostName} approved your request to join '
          '${request.trip.title}.',
    );
  }

  Future<void> _handleReject(TripRequest request) async {
    setState(() => _isProcessing = true);
    await _applyDecision(
      request,
      TripRequestStatus.rejected,
      title: 'Request Not Approved',
      body: '${request.hostName} could not approve your request to join '
          '${request.trip.title}.',
    );
  }

  Future<void> _applyDecision(
    TripRequest request,
    TripRequestStatus status, {
    required String title,
    required String body,
  }) async {
    TripRequestStore.updateStatus(request.id, status);

    NotificationStore.send(
      title: title,
      body: body,
      recipientUsername: request.requesterUsername,
      tripId: request.trip.id,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    final action =
        status == TripRequestStatus.approved ? 'approved' : 'rejected';
    final snackBar = SnackBar(
      content: Text(
        'You $action ${request.requesterName}\'s request. '
        'They have been notified.',
      ),
      backgroundColor:
          status == TripRequestStatus.approved ? Colors.green.shade700 : null,
      behavior: SnackBarBehavior.floating,
    );

    if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.greyText,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No requests yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Join requests from travelers will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
