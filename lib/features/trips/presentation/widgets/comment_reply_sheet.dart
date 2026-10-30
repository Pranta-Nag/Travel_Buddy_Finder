import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/comment_provider.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';
import 'package:travel_buddy_finder/features/profile/presentation/user_profile_screen.dart';
import 'package:travel_buddy_finder/features/trips/data/models/comment.dart';

class CommentReplySheet extends StatefulWidget {
  final CommentItem comment;
  final dynamic tripId;
  final void Function(CommentReply newReply)? onReplyAdded;
  final VoidCallback? onStateChanged;

  const CommentReplySheet({
    super.key,
    required this.comment,
    this.tripId,
    this.onReplyAdded,
    this.onStateChanged,
  });

  /// Static helper to open the classy reply sheet
  static Future<void> show(
    BuildContext context, {
    required CommentItem comment,
    dynamic tripId,
    void Function(CommentReply newReply)? onReplyAdded,
    VoidCallback? onStateChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => CommentReplySheet(
        comment: comment,
        tripId: tripId,
        onReplyAdded: onReplyAdded,
        onStateChanged: onStateChanged,
      ),
    );
  }

  @override
  State<CommentReplySheet> createState() => _CommentReplySheetState();
}

class _CommentReplySheetState extends State<CommentReplySheet> {
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  String? _replyingToUsername;

  @override
  void initState() {
    super.initState();
    _replyingToUsername = widget.comment.username;
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final String finalReplyText = _replyingToUsername != null &&
            !text.startsWith('@')
        ? '$_replyingToUsername $text'
        : text;

    _replyController.clear();
    _focusNode.unfocus();

    // Call CommentProvider to post real API request with optimistic UI
    final commentProvider = context.read<CommentProvider>();
    final result = await commentProvider.replyComment(
      commentId: widget.comment.id,
      reply: finalReplyText,
      tripId: widget.tripId ?? widget.comment.tripId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success
              ? "Reply posted successfully!"
              : (result.message.isNotEmpty
                  ? result.message
                  : "Failed to post reply")),
          backgroundColor:
              result.success ? AppColors.primary : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    if (result.reply != null) {
      widget.onReplyAdded?.call(result.reply!);
    }
    widget.onStateChanged?.call();
    if (mounted) setState(() {});

    // Auto-scroll to newly added reply
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _openUserProfile(String name, String username, String? avatarUrl) {
    final isMe = CurrentUser.isCurrentUser(username, inputName: name);
    final String effectiveAvatar = isMe
        ? CurrentUser.avatarUrl
        : (avatarUrl != null && avatarUrl.isNotEmpty
            ? (avatarUrl.startsWith('http')
                ? avatarUrl
                : AppUrl.resolveImageUrl(avatarUrl))
            : '');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          name: isMe ? CurrentUser.name : name,
          username: isMe ? CurrentUser.username : username,
          avatarUrl: effectiveAvatar,
          isCurrentUser: isMe,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = context.watch<CommentProvider>();
    final List<CommentItem> tripComments = widget.tripId != null
        ? commentProvider.getCommentsForTrip(widget.tripId)
        : <CommentItem>[];

    // Find the live synchronized CommentItem in memory
    final CommentItem liveComment = tripComments.firstWhere(
      (c) => c.id == widget.comment.id,
      orElse: () => widget.comment,
    );

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Drag Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.forum_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Replies',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${liveComment.replies.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF64748B), size: 22),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF8FAFC),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16, thickness: 1, color: Color(0xFFF1F5F9)),

              // 3. Scrollable Content: Original Comment & Threaded Replies
              Flexible(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                  children: [
                    // Original Parent Comment Card
                    _buildParentCommentCard(liveComment),

                    const SizedBox(height: 16),

                    // Replies Title Separator
                    if (liveComment.replies.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 1.5,
                              color: const Color(0xFFCBD5E1),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Conversation (${liveComment.replies.length})',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Replies list or empty state
                    if (liveComment.replies.isEmpty)
                      _buildEmptyRepliesState(liveComment)
                    else
                      ...liveComment.replies.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final CommentReply reply = entry.value;
                        return _buildReplyItem(reply, index);
                      }),
                  ],
                ),
              ),

              // 4. Classy Reply Input Section
              _buildInputSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Original parent comment card
  Widget _buildParentCommentCard(CommentItem liveComment) {
    final avatarProvider = AppUrl.imageProvider(
      liveComment.fullAvatarUrl.isNotEmpty
          ? liveComment.fullAvatarUrl
          : liveComment.avatarUrl,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _openUserProfile(
                  liveComment.name,
                  liveComment.username,
                  liveComment.fullAvatarUrl.isNotEmpty
                      ? liveComment.fullAvatarUrl
                      : liveComment.avatarUrl,
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  backgroundImage: avatarProvider,
                  onBackgroundImageError:
                      avatarProvider != null ? (_, __) {} : null,
                  child: avatarProvider == null
                      ? Text(
                          liveComment.name.isNotEmpty
                              ? liveComment.name[0].toUpperCase()
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
                    GestureDetector(
                      onTap: () => _openUserProfile(
                        liveComment.name,
                        liveComment.username,
                        liveComment.fullAvatarUrl.isNotEmpty
                            ? liveComment.fullAvatarUrl
                            : liveComment.avatarUrl,
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              liveComment.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            liveComment.username,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      liveComment.time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              // Like original comment button
              IconButton(
                icon: Icon(
                  liveComment.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: liveComment.isLiked
                      ? Colors.redAccent
                      : const Color(0xFF94A3B8),
                  size: 18,
                ),
                onPressed: () {
                  setState(() {
                    liveComment.isLiked = !liveComment.isLiked;
                    liveComment.likesCount +=
                        liveComment.isLiked ? 1 : -1;
                    if (liveComment.likesCount < 0) {
                      liveComment.likesCount = 0;
                    }
                  });
                  widget.onStateChanged?.call();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            liveComment.text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Empty replies placeholder
  Widget _buildEmptyRepliesState(CommentItem liveComment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.quickreply_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No replies yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Be the first to reply to ${liveComment.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Single threaded reply item
  Widget _buildReplyItem(CommentReply reply, int index) {
    final avatarProvider = AppUrl.imageProvider(
      reply.fullAvatarUrl.isNotEmpty ? reply.fullAvatarUrl : reply.avatarUrl,
    );

    return Padding(
      padding: const EdgeInsets.only(left: 18, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left vertical thread guide line
          Container(
            width: 2,
            height: 44,
            margin: const EdgeInsets.only(right: 12, top: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Reply Avatar
          GestureDetector(
            onTap: () => _openUserProfile(
              reply.name,
              reply.username,
              reply.fullAvatarUrl.isNotEmpty
                  ? reply.fullAvatarUrl
                  : reply.avatarUrl,
            ),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              backgroundImage: avatarProvider,
              onBackgroundImageError:
                  avatarProvider != null ? (_, __) {} : null,
              child: avatarProvider == null
                  ? Text(
                      reply.name.isNotEmpty
                          ? reply.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          // Reply content card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _openUserProfile(
                          reply.name,
                          reply.username,
                          reply.fullAvatarUrl.isNotEmpty
                              ? reply.fullAvatarUrl
                              : reply.avatarUrl,
                        ),
                        child: Row(
                          children: [
                            Text(
                              reply.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              reply.time,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Heart like button
                      InkWell(
                        onTap: () {
                          setState(() {
                            reply.isLiked = !reply.isLiked;
                            reply.likesCount += reply.isLiked ? 1 : -1;
                            if (reply.likesCount < 0) reply.likesCount = 0;
                          });
                          widget.onStateChanged?.call();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Icon(
                                reply.isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 14,
                                color: reply.isLiked
                                    ? Colors.redAccent
                                    : const Color(0xFF94A3B8),
                              ),
                              if (reply.likesCount > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '${reply.likesCount}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: reply.isLiked
                                        ? Colors.redAccent
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    reply.text,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF334155),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Classy bottom reply input bar with user avatar and dynamic header
  Widget _buildInputSection() {
    final avatarProvider = AppUrl.imageProvider(CurrentUser.avatarUrl);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Replying To pill banner
          if (_replyingToUsername != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.reply_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Replying to ${_replyingToUsername!}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _replyingToUsername = null;
                      });
                    },
                    child: const Icon(
                      Icons.cancel,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Input Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Current User Avatar
              GestureDetector(
                onTap: () => _openUserProfile(
                  CurrentUser.name,
                  CurrentUser.username,
                  CurrentUser.avatarUrl,
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  backgroundImage: avatarProvider,
                  onBackgroundImageError:
                      avatarProvider != null ? (_, __) {} : null,
                  child: avatarProvider == null
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
              const SizedBox(width: 10),

              // Text Field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _replyController,
                    focusNode: _focusNode,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: _replyingToUsername != null
                          ? "Write a reply to ${_replyingToUsername!}..."
                          : "Write a reply...",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _submitReply(),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Send Action Button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _submitReply,
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(),
                  tooltip: 'Send reply',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
