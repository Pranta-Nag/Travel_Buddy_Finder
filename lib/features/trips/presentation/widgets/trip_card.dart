import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip_request.dart';
import 'package:travel_buddy_finder/features/trips/presentation/screens/comment_screen.dart';
import 'package:travel_buddy_finder/features/trips/presentation/screens/edit_trip_screen.dart';
import 'package:travel_buddy_finder/features/trips/presentation/screens/rating_screen.dart';
import 'package:travel_buddy_finder/features/profile/presentation/user_profile_screen.dart';
import 'package:travel_buddy_finder/features/trips/presentation/screens/view_screen.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/trip_request_provider.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';
import 'package:travel_buddy_finder/features/trips/data/stores/trip_request_store.dart';

class TripCard extends StatefulWidget {
  const TripCard({
    super.key,
    required this.trip,
    required this.isBookmarked,
    this.onBookmarkToggle,
    this.onDelete,
    this.heroTag,
  });

  final Trip trip;
  final bool isBookmarked;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onDelete;
  final String? heroTag;

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  bool _isLiked = false;
  bool _hasRequested = false;

  @override
  Widget build(BuildContext context) {
    final bool isOwner =
        widget.trip.username == '@you' || widget.trip.username == '@yeasin';
    final effectiveHeroTag = widget.heroTag ?? 'card-trip-image-${widget.trip.id}';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: AppColors.greyText.withValues(alpha: .2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Hero(
                  tag: effectiveHeroTag,
                  child: _buildTripCoverImage(),
                ),
              ),

              // Edit button
              Positioned(
                top: 12,
                left: 12,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTripScreen(
                          trip: widget.trip,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.85,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.1,
                          ),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),

              // Location
              Positioned(
                left: 12,
                bottom: 12,
                right: 12,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: _pill(
                    Icons.location_on,
                    widget.trip.location,
                    Colors.black54,
                  ),
                ),
              ),

              // Price
              Positioned(
                top: 12,
                right: 12,
                child: _pill(
                  null,
                  widget.trip.price,
                  AppColors.primary.withValues(alpha: .9),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.trip.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.orange.shade600,
                            size: 18,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            widget.trip.rating,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _openProfile(context),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Row(
                              children: [
                                Builder(
                                  builder: (context) {
                                    final avatarProv = _getAvatarProvider(widget.trip.avatarUrl);
                                    return CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.fieldColor,
                                      backgroundImage: avatarProv,
                                      onBackgroundImageError: (_, __) {},
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'By ${widget.trip.hostName}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        widget.trip.username,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Seats
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${widget.trip.seatsLeft} seats left',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      _actionButton(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        _isLiked ? Colors.red : Colors.grey.shade700,
                        () {
                          setState(() {
                            _isLiked = !_isLiked;
                          });

                          if (_isLiked) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'You liked ${widget.trip.title}',
                                ),
                              ),
                            );
                          }
                        },
                        isActive: _isLiked,
                      ),
                      const SizedBox(width: 5),
                      _actionButton(
                        Icons.chat_bubble_outline,
                        Colors.grey.shade700,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CommentScreen(tripId: widget.trip.id),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      _actionButton(
                        widget.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        widget.isBookmarked
                            ? Colors.blue
                            : Colors.grey.shade700,
                        widget.onBookmarkToggle ?? () {},
                        isActive: widget.isBookmarked,
                      ),
                      const SizedBox(width: 5),
                      _actionButton(
                        Icons.star_border,
                        Colors.grey.shade700,
                        () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RatingScreen(
                                trip: widget.trip,
                              ),
                            ),
                          );

                          if (updated == true && mounted) {
                            setState(() {});
                          }
                        },
                      ),
                      if (isOwner && widget.onDelete != null) ...[
                        const SizedBox(width: 5),
                        _actionButton(
                          Icons.delete_outline,
                          Colors.red,
                          widget.onDelete!,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      if (!isOwner) ...[
                        Expanded(
                          child: SizedBox(
                            height: 34,
                            child: ElevatedButton(
                              onPressed: _hasRequested ? null : _joinTrip,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _hasRequested
                                    ? Colors.green.shade600
                                    : Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _hasRequested ? 'Requested' : 'Join Trip',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewScreen(
                                    trip: widget.trip,
                                    heroTag: effectiveHeroTag,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.grey.shade700,
                              padding: EdgeInsets.zero,
                              elevation: 0,
                              side: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'View Trip',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(
    IconData? icon,
    String label,
    Color color,
  ) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 170,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool isActive = false,
  }) {
    return _AnimatedCardButton(
      icon: icon,
      color: color,
      onPressed: onPressed,
      isActive: isActive,
    );
  }

  Future<void> _joinTrip() async {
    final trip = widget.trip;
    setState(() => _hasRequested = true);

    final request = TripRequest(
      id: '${trip.id}_${CurrentUser.username}_${DateTime.now().millisecondsSinceEpoch}',
      trip: trip,
      requesterName: CurrentUser.name,
      requesterUsername: CurrentUser.username,
      requesterAvatarUrl: CurrentUser.avatarUrl,
      hostName: trip.hostName,
      hostUsername: trip.username,
    );

    TripRequestStore.add(request);

    final messenger = ScaffoldMessenger.of(context);
    final result = await context.read<TripRequestProvider>().joinTrip(
      tripId: trip.id,
    );

    if (mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.success
                ? (result.message.isNotEmpty ? result.message : 'Join request sent to ${trip.hostName}!')
                : (result.message.isNotEmpty ? result.message : 'Join request sent to ${trip.hostName}!'),
          ),
          backgroundColor: result.success ? Colors.green.shade700 : null,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildTripCoverImage() {
    if (widget.trip.imageBytes != null && widget.trip.imageBytes!.isNotEmpty) {
      return Image.memory(
        widget.trip.imageBytes!,
        fit: BoxFit.cover,
      );
    }

    final rawUrl = widget.trip.imageUrl.trim();
    if (rawUrl.isEmpty) {
      return _buildImagePlaceholder();
    }

    // 1. Handle Base64 data URI or raw Base64 string
    if (rawUrl.startsWith('data:image/') ||
        (!rawUrl.startsWith('http') &&
            !rawUrl.startsWith('assets/') &&
            rawUrl.length > 200)) {
      try {
        final base64String =
            rawUrl.contains(',') ? rawUrl.split(',').last : rawUrl;
        final decodedBytes = base64Decode(base64String.trim());
        return Image.memory(
          decodedBytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        );
      } catch (_) {}
    }

    // 2. Handle Asset path
    if (rawUrl.startsWith('assets/')) {
      return Image.asset(
        rawUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      );
    }

    // 3. Resolve and render Network Image
    final resolvedUrl = rawUrl.startsWith('http://') || rawUrl.startsWith('https://')
        ? AppUrl.resolveImageUrl(rawUrl)
        : AppUrl.resolveImageUrl(rawUrl);

    if (resolvedUrl.isNotEmpty) {
      return Image.network(
        resolvedUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey.shade500,
          size: 40,
        ),
      ),
    );
  }

  ImageProvider _getAvatarProvider(String rawUrl) {
    final isMe = CurrentUser.isCurrentUser(
      widget.trip.username,
      inputName: widget.trip.hostName,
    );
    String url = rawUrl.trim();
    if (url.isEmpty && isMe) {
      url = CurrentUser.avatarUrl;
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(AppUrl.resolveImageUrl(url));
    } else if (url.startsWith('assets/')) {
      return AssetImage(url);
    } else if (url.isNotEmpty) {
      final resolved = AppUrl.resolveImageUrl(url);
      if (resolved.isNotEmpty) {
        return NetworkImage(resolved);
      }
    }
    return AssetImage(
      isMe ? CurrentUser.avatarUrl : 'assets/images/dummy_boy.jpg',
    );
  }

  void _openProfile(BuildContext context) {
    final isMe = CurrentUser.isCurrentUser(
      widget.trip.username,
      inputName: widget.trip.hostName,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserProfileScreen(
            name: isMe ? CurrentUser.name : widget.trip.hostName,
            username: isMe ? CurrentUser.username : widget.trip.username,
            avatarUrl: isMe ? CurrentUser.avatarUrl : widget.trip.avatarUrl,
            isCurrentUser: isMe,
          ),
        ),
      );
    });
  }
}

class _AnimatedCardButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isActive;

  const _AnimatedCardButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  State<_AnimatedCardButton> createState() => _AnimatedCardButtonState();
}

class _AnimatedCardButtonState extends State<_AnimatedCardButton> {
  double _scale = 1.0;

  void _onTap() {
    setState(() => _scale = 1.35);
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) setState(() => _scale = 1.0);
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.isActive
                ? widget.color.withValues(alpha: 0.35)
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          splashRadius: 16,
          iconSize: 16,
          color: widget.color,
          onPressed: _onTap,
          icon: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutBack,
            child: Icon(widget.icon),
          ),
        ),
      ),
    );
  }
}
