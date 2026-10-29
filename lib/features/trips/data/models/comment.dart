import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';

class CommentReply {
  final String id;
  final String? commentId;
  final String name;
  final String username;
  final String text;
  final String time;
  final String? avatarUrl;
  bool isLiked;
  int likesCount;

  CommentReply({
    required this.id,
    this.commentId,
    required this.name,
    required this.username,
    required this.text,
    required this.time,
    this.avatarUrl,
    this.isLiked = false,
    this.likesCount = 0,
  });

  String get fullAvatarUrl {
    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
      return AppUrl.resolveImageUrl(avatarUrl);
    }
    if (CurrentUser.isCurrentUser(username, inputName: name)) {
      return AppUrl.resolveImageUrl(CurrentUser.avatarUrl);
    }
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (commentId != null) 'comment_id': commentId,
      'name': name,
      'username': username,
      'text': text,
      'time': time,
      'avatarUrl': avatarUrl,
      'isLiked': isLiked,
      'likesCount': likesCount,
    };
  }

  factory CommentReply.fromJson(Map<String, dynamic> json) {
    final String parsedId = json['id']?.toString() ??
        json['reply_id']?.toString() ??
        json['replyId']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final dynamic userObj = json['user'] is Map ? json['user'] : null;

    final String rawName = (json['name'] ??
            json['user_name'] ??
            json['full_name'] ??
            userObj?['name'] ??
            userObj?['user_name'] ??
            userObj?['full_name'] ??
            userObj?['username'] ??
            'User')
        .toString();

    final String rawUsername = (json['username'] ??
            userObj?['username'] ??
            (rawName.startsWith('@')
                ? rawName
                : '@${rawName.toLowerCase().replaceAll(' ', '')}'))
        .toString();

    final String rawText = (json['reply'] ??
            json['reply_comment'] ??
            json['reply_text'] ??
            json['replay'] ??
            json['replay_comment'] ??
            json['replay_text'] ??
            json['comment'] ??
            json['comment_text'] ??
            json['text'] ??
            json['content'] ??
            json['message'] ??
            json['msg'] ??
            json['body'] ??
            json['description'] ??
            json['details'] ??
            '')
        .toString();

    final String rawTime = (json['time'] ??
            json['created_at'] ??
            json['date'] ??
            'Just now')
        .toString();

    final String? rawAvatar = json['avatarUrl'] ??
        json['user_avatar'] ??
        json['avatar'] ??
        json['avatar_url'] ??
        json['profile_pic'] ??
        json['profile_image'] ??
        json['user_image'] ??
        json['image'] ??
        json['photo'] ??
        json['user_photo'] ??
        userObj?['avatar'] ??
        userObj?['user_avatar'] ??
        userObj?['avatar_url'] ??
        userObj?['profile_pic'] ??
        userObj?['profile_image'] ??
        userObj?['image'] ??
        userObj?['photo'];

    final rawLikes = json['likes'] ?? json['likes_count'] ?? json['like_count'];
    final int parsedLikes = rawLikes is int
        ? rawLikes
        : int.tryParse(rawLikes?.toString() ?? '0') ?? 0;

    return CommentReply(
      id: parsedId,
      commentId: json['comment_id']?.toString() ??
          json['commentId']?.toString() ??
          json['parent_id']?.toString(),
      name: rawName,
      username: rawUsername,
      text: rawText,
      time: rawTime,
      avatarUrl: rawAvatar,
      isLiked: json['isLiked'] ?? json['is_liked'] ?? false,
      likesCount: parsedLikes,
    );
  }
}

class CommentItem {
  final String id;
  final String? tripId;
  final String name;
  final String username;
  final String text;
  final String time;
  final String? avatarUrl;
  bool isLiked;
  int likesCount;
  final List<CommentReply> replies;

  CommentItem({
    required this.id,
    this.tripId,
    required this.name,
    required this.username,
    required this.text,
    required this.time,
    this.avatarUrl,
    this.isLiked = false,
    this.likesCount = 0,
    List<CommentReply>? replies,
  }) : replies = replies ?? [];

  String get fullAvatarUrl {
    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
      return AppUrl.resolveImageUrl(avatarUrl);
    }
    if (CurrentUser.isCurrentUser(username, inputName: name)) {
      return AppUrl.resolveImageUrl(CurrentUser.avatarUrl);
    }
    return '';
  }

  void addReply(CommentReply reply) {
    replies.add(reply);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (tripId != null) 'trip_id': tripId,
      'name': name,
      'username': username,
      'text': text,
      'time': time,
      'avatarUrl': avatarUrl,
      'isLiked': isLiked,
      'likesCount': likesCount,
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    final String parsedId = json['id']?.toString() ??
        json['comment_id']?.toString() ??
        json['commentId']?.toString() ??
        json['cid']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final dynamic userObj = json['user'] is Map ? json['user'] : null;

    final String rawName = (json['name'] ??
            json['user_name'] ??
            json['full_name'] ??
            userObj?['name'] ??
            userObj?['user_name'] ??
            userObj?['full_name'] ??
            userObj?['username'] ??
            'User')
        .toString();

    final String rawUsername = (json['username'] ??
            userObj?['username'] ??
            (rawName.startsWith('@')
                ? rawName
                : '@${rawName.toLowerCase().replaceAll(' ', '')}'))
        .toString();

    final String rawText = (json['comment'] ??
            json['comment_text'] ??
            json['comments'] ??
            json['comment_body'] ??
            json['text'] ??
            json['content'] ??
            json['message'] ??
            json['msg'] ??
            json['body'] ??
            json['description'] ??
            json['details'] ??
            json['reply'] ??
            json['reply_comment'] ??
            '')
        .toString();

    final String rawTime = (json['time'] ??
            json['created_at'] ??
            json['date'] ??
            'Just now')
        .toString();

    final String? rawAvatar = json['avatarUrl'] ??
        json['user_avatar'] ??
        json['avatar'] ??
        json['avatar_url'] ??
        json['profile_pic'] ??
        json['profile_image'] ??
        json['user_image'] ??
        json['image'] ??
        json['photo'] ??
        json['user_photo'] ??
        userObj?['avatar'] ??
        userObj?['user_avatar'] ??
        userObj?['avatar_url'] ??
        userObj?['profile_pic'] ??
        userObj?['profile_image'] ??
        userObj?['image'] ??
        userObj?['photo'];

    final rawLikes = json['likes'] ?? json['likes_count'] ?? json['like_count'];
    final int parsedLikes = rawLikes is int
        ? rawLikes
        : int.tryParse(rawLikes?.toString() ?? '0') ?? 0;

    List<CommentReply> parsedReplies = [];
    final dynamic rawReplies = json['replies'] ??
        json['reply'] ??
        json['replay'] ??
        json['reply_list'] ??
        json['comment_replies'] ??
        json['all_replies'];
    if (rawReplies is List) {
      parsedReplies = rawReplies
          .whereType<Map>()
          .map((r) => CommentReply.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }

    return CommentItem(
      id: parsedId,
      tripId: json['trip_id']?.toString() ?? json['tripId']?.toString(),
      name: rawName,
      username: rawUsername,
      text: rawText,
      time: rawTime,
      avatarUrl: rawAvatar,
      isLiked: json['isLiked'] ?? json['is_liked'] ?? false,
      likesCount: parsedLikes,
      replies: parsedReplies,
    );
  }
}
