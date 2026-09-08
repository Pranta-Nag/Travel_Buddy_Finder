import 'package:flutter/foundation.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/models/trip_data.dart';
import 'package:travel_buddy_finder/models/trip_request.dart';

class TripRequestStore {
  TripRequestStore._();

  static final ValueNotifier<List<TripRequest>> requests =
      ValueNotifier<List<TripRequest>>([_demoRequest()]);

  static TripRequest _demoRequest() {
    final Trip trip = tripList.firstWhere((t) => t.id == 'Kaptai');
    return TripRequest(
      id: 'demo_1',
      trip: trip,
      requesterName: 'Jane Doe',
      requesterUsername: '@jane_d',
      requesterAvatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      hostName: trip.hostName,
      hostUsername: trip.username,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    );
  }

  static List<TripRequest> pendingForHost(String hostUsername) {
    return requests.value
        .where(
          (request) =>
              request.hostUsername == hostUsername &&
              request.status == TripRequestStatus.pending,
        )
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<TripRequest> allForHost(String hostUsername) {
    return requests.value
        .where((request) => request.hostUsername == hostUsername)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<TripRequest> receivedBy(String requesterUsername) {
    return requests.value
        .where((request) => request.requesterUsername == requesterUsername)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static int pendingCountForHost(String hostUsername) =>
      pendingForHost(hostUsername).length;

  static void add(TripRequest request) {
    final list = List<TripRequest>.from(requests.value);
    list.removeWhere((existing) =>
        existing.trip.id == request.trip.id &&
        existing.requesterUsername == request.requesterUsername);
    list.add(request);
    requests.value = list;
  }

  static void updateStatus(String requestId, TripRequestStatus status) {
    final list = List<TripRequest>.from(requests.value);
    final index = list.indexWhere((request) => request.id == requestId);
    if (index < 0) return;
    list[index].status = status;
    requests.value = [...list];
  }
}
