class AppNotification {
  final String id;
  final String title;
  final String body;
  final String recipientUsername;
  final String? tripId;
  final DateTime createdAt;
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.recipientUsername,
    this.tripId,
    DateTime? createdAt,
    this.read = false,
  }) : createdAt = createdAt ?? DateTime.now();
}
