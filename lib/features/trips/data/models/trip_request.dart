import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip.dart';

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

  factory TripRequest.fromJson(
    Map<String, dynamic> json, {
    List<Trip>? availableTrips,
  }) {
    final rawId = json['id'] ?? json['request_id'] ?? json['_id'] ?? '0';

    final statusStr = (json['status'] ?? json['request_status'] ?? 'pending')
        .toString()
        .toLowerCase();
    TripRequestStatus status = TripRequestStatus.pending;
    if (statusStr == 'approved' || statusStr == 'accepted') {
      status = TripRequestStatus.approved;
    } else if (statusStr == 'rejected' || statusStr == 'declined') {
      status = TripRequestStatus.rejected;
    }

    final rawTripId = json['trip_id'] ?? json['tripId'];
    Trip? matchedTrip;
    if (availableTrips != null && rawTripId != null) {
      final tripIdStr = rawTripId.toString();
      try {
        matchedTrip = availableTrips.firstWhere((t) => t.id == tripIdStr);
      } catch (_) {}
    }

    final String tripTitle = json['trip_title'] ??
        json['title'] ??
        json['destination'] ??
        (json['trip'] is Map ? (json['trip']['title'] ?? json['trip']['destination']) : null) ??
        'Trip #${rawTripId ?? 0}';

    matchedTrip ??= Trip(
      id: rawTripId?.toString() ?? '0',
      title: tripTitle,
      location: json['destination'] ?? json['location'] ?? 'Destination',
      price: json['budget'] != null ? '\$${json['budget']}' : '\$0',
      rating: '4.9',
      hostName: json['host_name'] ?? CurrentUser.name,
      username: json['host_username'] ?? CurrentUser.username,
      imageUrl: AppUrl.resolveImageUrl(
        json['trip_image'] ??
            json['cover_picture_url'] ??
            (json['trip'] is Map ? json['trip']['cover_picture_url'] : null),
      ),
      avatarUrl: AppUrl.resolveImageUrl(
        json['host_avatar'] ??
            (json['trip'] is Map ? json['trip']['host_avatar'] : null) ??
            CurrentUser.avatarUrl,
      ),
      category: json['category'] ?? 'Adventure',
      description: json['description'] ?? '',
    );

    final requesterName = json['requester_name'] ??
        json['user_name'] ??
        json['requester_full_name'] ??
        json['full_name'] ??
        (json['requester'] is Map ? json['requester']['full_name'] : null) ??
        (json['user'] is Map ? json['user']['full_name'] : null) ??
        'Traveler';

    final requesterUsername = json['requester_username'] ??
        json['username'] ??
        (json['requester'] is Map ? json['requester']['username'] : null) ??
        (json['user'] is Map ? json['user']['username'] : null) ??
        '@${requesterName.toString().toLowerCase().replaceAll(' ', '')}';

    final rawAvatar = json['requester_avatar'] ??
        json['profile_pic'] ??
        json['requester_profile_pic'] ??
        (json['requester'] is Map ? json['requester']['profile_pic'] : null) ??
        (json['user'] is Map ? json['user']['profile_pic'] : null);

    final requesterAvatarUrl = AppUrl.resolveImageUrl(rawAvatar);

    final hostName = json['host_name'] ?? matchedTrip.hostName;
    final hostUsername = json['host_username'] ?? matchedTrip.username;

    DateTime? createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.tryParse(json['created_at'].toString());
    }

    return TripRequest(
      id: rawId.toString(),
      trip: matchedTrip,
      requesterName: requesterName.toString(),
      requesterUsername: requesterUsername.toString().startsWith('@')
          ? requesterUsername.toString()
          : '@$requesterUsername',
      requesterAvatarUrl: requesterAvatarUrl.isNotEmpty
          ? requesterAvatarUrl
          : 'assets/images/dummy_boy.jpg',
      hostName: hostName.toString(),
      hostUsername: hostUsername.toString().startsWith('@')
          ? hostUsername.toString()
          : '@$hostUsername',
      createdAt: createdAt,
      status: status,
    );
  }
}

