class Review {
  final String id;
  final String tripId;
  final String userName;
  final String userUsername;
  final String userAvatarUrl;
  final double rating;
  final String reviewText;
  final List<String> tags;
  final bool wouldRecommend;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.tripId,
    required this.userName,
    required this.userUsername,
    required this.userAvatarUrl,
    required this.rating,
    required this.reviewText,
    this.tags = const [],
    this.wouldRecommend = true,
    required this.createdAt,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
