import 'package:travel_buddy_finder/models/trip.dart';

enum TripRequestStatus { pending, approved, rejected }

class TripRequest {
  final String id;
  final Trip trip;
  final String requesterName;
  final String requesterUsername;
  final String requesterAvatarUrl;
  final String hostName;
  final String hostUsername;
  final DateTime createdAt;
  TripRequestStatus status;

  TripRequest({
    required this.id,
    required this.trip,
    required this.requesterName,
    required this.requesterUsername,
    required this.requesterAvatarUrl,
    required this.hostName,
    required this.hostUsername,
    DateTime? createdAt,
    this.status = TripRequestStatus.pending,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isPending => status == TripRequestStatus.pending;

  String get statusLabel {
    switch (status) {
      case TripRequestStatus.pending:
        return 'Pending';
      case TripRequestStatus.approved:
        return 'Approved';
      case TripRequestStatus.rejected:
        return 'Not Approved';
    }
  }
}
