import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/comment_provider.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/core/widgets/screen_background.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';
import 'package:travel_buddy_finder/features/profile/presentation/user_profile_screen.dart';
import 'package:travel_buddy_finder/features/trips/data/models/comment.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/comment_reply_sheet.dart';

class CommentScreen extends StatefulWidget {
  final dynamic tripId;
  const CommentScreen({super.key, this.tripId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  final List<CommentItem> comments = [
    CommentItem(
      id: 'c1',
      name: "John Doe",
      username: "@johndoe",
      text: "Amazing trip! Looking forward to joining this adventure.",
      time: "2h ago",
      avatarUrl:
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
      isLiked: false,
      likesCount: 3,
      replies: [
        CommentReply(
          id: 'r1',
          name: "Sarah Ahmed",
          username: "@sarah",
          text:
              "@johndoe You should definitely come! We have a great crew already.",
          time: "1h ago",
          avatarUrl:
              "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
          isLiked: true,
          likesCount: 2,
        ),
      ],
    ),
    CommentItem(
      id: 'c2',
      name: "Sarah Ahmed",
      username: "@sarah",
      text: "Is transportation included in the overall budget package?",
      time: "5h ago",
      avatarUrl:
          "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
      isLiked: true,
      likesCount: 5,
      replies: [
        CommentReply(
          id: 'r2',
          name: "Takeshi Yamamoto",
          username: "@takeshi",
          text:
              "@sarah Yes, flight and bus transit are both covered in the plan!",
          time: "4h ago",
          avatarUrl:
              "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200",
          isLiked: false,
          likesCount: 1,
        ),
      ],
    ),
    CommentItem(
      id: 'c3',
      name: "Takeshi Yamamoto",
      username: "@takeshi",
      text: "The itinerary looks perfect. Count me in for the entire tour!",
      time: "1d ago",
      avatarUrl:
          "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200",
      isLiked: false,
      likesCount: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.tripId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<CommentProvider>().fetchComments(widget.tripId);
        }
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    _commentController.clear();
    FocusScope.of(context).unfocus();

    if (widget.tripId != null) {
      final res = await context.read<CommentProvider>().addComment(
            tripId: widget.tripId,
            comment: text,
          );
      if (!mounted) return;
      if (!res.success && res.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      setState(() {
        comments.insert(
          0,
          CommentItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: CurrentUser.name,
            username: CurrentUser.username,
            text: text,
            time: "Just now",
            avatarUrl: CurrentUser.avatarUrl,
          ),
        );
      });
    }
  }

  void _openReplies(CommentItem comment) {
    CommentReplySheet.show(
      context,
      comment: comment,
      tripId: widget.tripId ?? comment.tripId,
      onReplyAdded: (_) {
        setState(() {});
      },
      onStateChanged: () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider =
        widget.tripId != null ? context.watch<CommentProvider>() : null;
    final List<CommentItem> displayComments = widget.tripId != null
        ? commentProvider!.getCommentsForTrip(widget.tripId)
        : comments;
    final bool isLoading = widget.tripId != null &&
        commentProvider!.isLoading(widget.tripId) &&
        displayComments.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: ScreenBackground(
        child: Column(
          children: [
            _buildAppBar(displayComments.length),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : displayComments.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: displayComments.length,
                          itemBuilder: (context, index) {
                            final item = displayComments[index];
                            return _CommentCard(
                              name: item.name,
                              comment: item.text,
                              time: item.time,
                              avatarUrl: item.avatarUrl,
                              isLiked: item.isLiked,
                              commentItem: item,
                              onLike: () {
                                setState(() {
                                  item.isLiked = !item.isLiked;
                                  item.likesCount += item.isLiked ? 1 : -1;
                                  if (item.likesCount < 0) item.likesCount = 0;
                                });
                              },
                              onReply: () => _openReplies(item),
                              onProfileTap: () {
                                final name = item.name;
                                final username = item.username;
                                final isMe = CurrentUser.isCurrentUser(username,
                                    inputName: name);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfileScreen(
                                      name: isMe ? CurrentUser.name : name,
                                      username: isMe
                                          ? CurrentUser.username
                                          : username,
                                      avatarUrl: isMe
                                          ? CurrentUser.avatarUrl
                                          : (item.fullAvatarUrl.isNotEmpty
                                              ? item.fullAvatarUrl
                                              : AppUrl.resolveImageUrl(item.avatarUrl)),
                                      isCurrentUser: isMe,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
            _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int count) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F2937)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Comments",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Color(0xFF111827),
              letterSpacing: -0.3,
            ),
          ),
          Text(
            "$count comments",
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      centerTitle: false,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No comments yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your thoughts.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    name: CurrentUser.name,
                    username: CurrentUser.username,
                    avatarUrl: CurrentUser.avatarUrl,
                    isCurrentUser: true,
                  ),
                ),
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: CurrentUser.avatarUrl.isNotEmpty
                  ? (CurrentUser.avatarUrl.startsWith('http')
                      ? NetworkImage(CurrentUser.avatarUrl)
                      : AssetImage(CurrentUser.avatarUrl) as ImageProvider)
                  : null,
              backgroundColor: Colors.grey.shade200,
              onBackgroundImageError: (_, __) {},
              child: CurrentUser.avatarUrl.isEmpty
                  ? Text(
                      CurrentUser.name.isNotEmpty
                          ? CurrentUser.name[0].toUpperCase()
                          : 'Y',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: _commentController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "Write a comment...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _addComment(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _addComment,
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final String name;
  final String comment;
  final String time;
  final String? avatarUrl;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onProfileTap;
  final CommentItem? commentItem;
  final VoidCallback? onReply;

  const _CommentCard({
    required this.name,
    required this.comment,
    required this.time,
    this.avatarUrl,
    required this.isLiked,
    required this.onLike,
    required this.onProfileTap,
    this.commentItem,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final String resolvedAvatar = (commentItem != null && commentItem!.fullAvatarUrl.isNotEmpty)
        ? commentItem!.fullAvatarUrl
        : AppUrl.resolveImageUrl(commentItem?.avatarUrl ?? avatarUrl);
    final effectiveAvatarUrl = resolvedAvatar.isNotEmpty
        ? resolvedAvatar
        : (commentItem?.avatarUrl ?? avatarUrl);
    final int repliesCount = commentItem?.replies.length ?? 0;
    final String displayName = commentItem?.name ?? name;
    final String displayComment = commentItem?.text ?? comment;
    final String displayTime = commentItem?.time ?? time;
    final bool displayIsLiked = commentItem?.isLiked ?? isLiked;
    final int displayLikesCount =
        commentItem?.likesCount ?? (displayIsLiked ? 1 : 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 22,
              backgroundImage: effectiveAvatarUrl != null && effectiveAvatarUrl.isNotEmpty
                  ? (effectiveAvatarUrl.startsWith('http')
                      ? NetworkImage(effectiveAvatarUrl)
                      : (effectiveAvatarUrl.startsWith('assets/')
                          ? AssetImage(effectiveAvatarUrl) as ImageProvider
                          : NetworkImage(AppUrl.resolveImageUrl(effectiveAvatarUrl))))
                  : null,
              onBackgroundImageError: (_, __) {},
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: effectiveAvatarUrl == null || effectiveAvatarUrl.isEmpty
                  ? Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onProfileTap,
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1D5DB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      displayTime,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  displayComment,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Like button with counter
                    InkWell(
                      onTap: onLike,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        child: Row(
                          children: [
                            Icon(
                              displayIsLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 16,
                              color: displayIsLiked
                                  ? Colors.redAccent
                                  : const Color(0xFF6B7280),
                            ),
                            if (displayLikesCount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '$displayLikesCount',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: displayIsLiked
                                      ? Colors.redAccent
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Reply button - opens classy reply sheet
                    InkWell(
                      onTap: onReply,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.reply_rounded,
                              size: 15,
                              color: Color(0xFF475569),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              repliesCount > 0
                                  ? '$repliesCount ${repliesCount == 1 ? "reply" : "replies"}'
                                  : 'Reply',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
