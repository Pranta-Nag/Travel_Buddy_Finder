import 'package:travel_buddy_finder/api/providers/chat_provider.dart';
import 'package:travel_buddy_finder/features/chat/presentation/screens/chat_room_screen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip_request.dart';
import 'package:travel_buddy_finder/features/trips/data/models/review.dart';
import 'package:travel_buddy_finder/features/trips/data/stores/review_store.dart';
import 'package:travel_buddy_finder/features/trips/presentation/screens/rating_screen.dart';
import 'package:travel_buddy_finder/features/trips/presentation/screens/comment_screen.dart';
import 'package:travel_buddy_finder/features/profile/presentation/user_profile_screen.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/bookmark_provider.dart';
import 'package:travel_buddy_finder/api/providers/comment_provider.dart';
import 'package:travel_buddy_finder/api/providers/trip_request_provider.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';
import 'package:travel_buddy_finder/features/trips/data/stores/trip_request_store.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/comment_reply_sheet.dart';

class ViewScreen extends StatefulWidget {
  final Trip trip;
  final String heroTag;
  const ViewScreen({super.key, required this.trip, required this.heroTag});

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CommentProvider>().fetchComments(widget.trip.id);
      }
    });
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

    final result = await context.read<CommentProvider>().addComment(
      tripId: widget.trip.id,
      comment: text,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.success ? "Comment posted!" : result.message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openUserProfile(String name, String username, String? avatarUrl) {
    final isMe = CurrentUser.isCurrentUser(username, inputName: name);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => isMe
            ? const UserProfileScreen(isCurrentUser: true)
            : UserProfileScreen(
                name: name,
                username: username,
                avatarUrl: AppUrl.resolveImageUrl(avatarUrl),
                isCurrentUser: false,
              ),
      ),
    );
  }

  Future<void> _joinTrip() async {
    final trip = widget.trip;
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

    final result = await context.read<TripRequestProvider>().joinTrip(
      tripId: trip.id,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              result.success ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: result.success ? AppColors.primary : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(result.success ? "Join Request Sent!" : "Request Submitted"),
          ],
        ),
        content: Text(
          result.message.isNotEmpty
              ? result.message
              : "Your request to join '${trip.title}' with ${trip.hostName} has been submitted successfully.",
          style: const TextStyle(
              color: AppColors.greyText, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close",
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  IconData _getTransportationIcon(String method) {
    final m = method.toLowerCase();
    if (m.contains('flight') || m.contains('plane')) {
      return Icons.flight_takeoff_rounded;
    }
    if (m.contains('train') || m.contains('bullet')) return Icons.train_rounded;
    if (m.contains('bus')) return Icons.directions_bus_rounded;
    if (m.contains('car') || m.contains('carpool') || m.contains('road')) {
      return Icons.directions_car_rounded;
    }
    if (m.contains('boat') || m.contains('sail') || m.contains('ferry')) {
      return Icons.directions_boat_rounded;
    }
    return Icons.commute_rounded;
  }

  IconData _getGenderIcon(String? gender) {
    if (gender == null) return Icons.groups_rounded;
    final g = gender.toLowerCase();
    if (g.contains('female')) return Icons.female_rounded;
    if (g.contains('male')) return Icons.male_rounded;
    return Icons.groups_rounded;
  }

  Widget _buildTripCoverImage(Trip trip) {
    if (trip.imageBytes != null && trip.imageBytes!.isNotEmpty) {
      return Image.memory(trip.imageBytes!, fit: BoxFit.cover);
    }

    final rawUrl = trip.imageUrl.trim();
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
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
          size: 50,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 290,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.black87, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Consumer<BookmarkProvider>(
                  builder: (context, bookmarkProvider, _) {
                    final bool isSaved =
                        bookmarkProvider.isBookmarked(widget.trip.id);
                    final bool isBusy =
                        bookmarkProvider.isPending(widget.trip.id);

                    return CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: IconButton(
                        icon: isBusy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary),
                                ),
                              )
                            : Icon(
                                isSaved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_outline_rounded,
                                color: isSaved
                                    ? AppColors.primary
                                    : Colors.black87,
                                size: 20,
                              ),
                        onPressed: isBusy
                            ? null
                            : () async {
                                final res = await bookmarkProvider
                                    .toggleBookmark(widget.trip);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res.isBookmarked
                                        ? "Trip added to bookmarks"
                                        : "Trip removed from bookmarks"),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, bottom: 8.0, right: 12.0, left: 4.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined,
                        color: Colors.black87, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Trip link copied to clipboard!"),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: widget.heroTag,
                    child: _buildTripCoverImage(trip),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.category_rounded,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                trip.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.event_seat_rounded,
                                  color: Colors.orange, size: 14),
                              const SizedBox(width: 5),
                              Text(
                                "${trip.seatsLeft} Spots Left",
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          trip.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFD97706), size: 18),
                            const SizedBox(width: 4),
                            Text(
                              trip.rating,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        trip.location,
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            final isMe = CurrentUser.isCurrentUser(trip.username, inputName: trip.hostName);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserProfileScreen(
                                    name: isMe ? CurrentUser.name : trip.hostName,
                                    username: isMe ? CurrentUser.username : trip.username,
                                    avatarUrl: isMe ? CurrentUser.avatarUrl : trip.avatarUrl,
                                    isCurrentUser: isMe,
                                  ),
                                ),
                              );
                            });
                          },
                          child: Stack(
                            children: [
                              Builder(
                                builder: (context) {
                                  final hostProv = AppUrl.imageProvider(
                                    trip.avatarUrl.isNotEmpty
                                        ? trip.avatarUrl
                                        : (CurrentUser.isCurrentUser(trip.username, inputName: trip.hostName)
                                            ? CurrentUser.avatarUrl
                                            : 'assets/images/dummy_boy.jpg'),
                                  );
                                  return CircleAvatar(
                                    radius: 26,
                                    backgroundColor: AppColors.fieldColor,
                                    backgroundImage: hostProv,
                                    onBackgroundImageError: hostProv != null ? (_, __) {} : null,
                                    child: hostProv == null
                                        ? Text(
                                            trip.hostName.isNotEmpty
                                                ? trip.hostName[0].toUpperCase()
                                                : 'H',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  );
                                },
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.verified_rounded,
                                    color: Colors.blue,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              final isMe = CurrentUser.isCurrentUser(trip.username, inputName: trip.hostName);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!context.mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserProfileScreen(
                                      name: isMe ? CurrentUser.name : trip.hostName,
                                      username: isMe ? CurrentUser.username : trip.username,
                                      avatarUrl: isMe ? CurrentUser.avatarUrl : trip.avatarUrl,
                                      isCurrentUser: isMe,
                                    ),
                                  ),
                                );
                              });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        trip.hostName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        "Host",
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  trip.username,
                                  style: const TextStyle(
                                    color: AppColors.greyText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final isMe = CurrentUser.isCurrentUser(trip.username, inputName: trip.hostName);
                            if (isMe) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("You are the host of this trip."),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                child: CircularProgressIndicator(color: AppColors.primary),
                              ),
                            );

                            final result = await context.read<ChatProvider>().startChat(trip.id);
                            if (!context.mounted) return;
                            Navigator.pop(context); // close loading

                            if (result.success && result.roomId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatRoomScreen(
                                    roomId: result.roomId!,
                                    partnerName: trip.hostName,
                                    partnerAvatarUrl: trip.avatarUrl,
                                    tripTitle: trip.title,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result.message.isNotEmpty
                                      ? result.message
                                      : "Could not initiate chat with host."),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded,
                              size: 14, color: AppColors.primary),
                          label: const Text("Chat",
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.primary, width: 1.2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Trip Overview",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _featureCard(
                          icon: Icons.payments_rounded,
                          iconColor: Colors.teal,
                          bgColor: const Color(0xFFF0FDFA),
                          title: "Price",
                          value: trip.price,
                          subtitle: "per person",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _featureCard(
                          icon: Icons.airline_seat_recline_normal_rounded,
                          iconColor: Colors.indigo,
                          bgColor: const Color(0xFFEEF2FF),
                          title: "Availability",
                          value: "${trip.seatsLeft} Seats",
                          subtitle: "instant booking",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _featureCard(
                          icon: _getGenderIcon(trip.genderPreference),
                          iconColor: Colors.purple,
                          bgColor: const Color(0xFFFAF5FF),
                          title: "Preference",
                          value: trip.genderPreference ?? "Everyone",
                          subtitle: "gender rule",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _featureCard(
                          icon: Icons.explore_rounded,
                          iconColor: Colors.amber.shade800,
                          bgColor: const Color(0xFFFFFBEB),
                          title: "Category",
                          value: trip.category,
                          subtitle: "travel type",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (trip.transportationMethods != null &&
                      trip.transportationMethods!.isNotEmpty) ...[
                    const Text(
                      "Transportation",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: trip.transportationMethods!.map((method) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTransportationIcon(method),
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                method,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    "About This Trip",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      trip.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF334155),
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildReviewsSection(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Discussion",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Consumer<CommentProvider>(
                            builder: (context, commentProvider, _) {
                              final count = commentProvider
                                  .getCommentsForTrip(widget.trip.id)
                                  .length;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "$count",
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CommentScreen(tripId: widget.trip.id),
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Text(
                              "View all",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 12, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _openUserProfile(
                            CurrentUser.name,
                            CurrentUser.username,
                            CurrentUser.avatarUrl,
                          ),
                          child: Builder(
                            builder: (context) {
                              final myProv = AppUrl.imageProvider(CurrentUser.avatarUrl);
                              return CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.fieldColor,
                                backgroundImage: myProv,
                                onBackgroundImageError: myProv != null ? (_, __) {} : null,
                                child: myProv == null
                                    ? Text(
                                        CurrentUser.name.isNotEmpty
                                            ? CurrentUser.name[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: "Ask host a question...",
                              hintStyle: TextStyle(
                                  fontSize: 13, color: AppColors.greyText),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            onSubmitted: (_) => _addComment(),
                          ),
                        ),
                        IconButton(
                          onPressed: _addComment,
                          icon: const Icon(Icons.send_rounded,
                              color: AppColors.primary, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<CommentProvider>(
                    builder: (context, commentProvider, _) {
                      final tripComments =
                          commentProvider.getCommentsForTrip(widget.trip.id);
                      final isLoading =
                          commentProvider.isLoading(widget.trip.id);

                      if (isLoading && tripComments.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2.5,
                            ),
                          ),
                        );
                      }

                      if (tripComments.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "No questions yet. Be the first to ask!",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tripComments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = tripComments[index];
                          final String itemAvatar = item.fullAvatarUrl;
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _openUserProfile(
                                        item.name,
                                        item.username,
                                        itemAvatar,
                                      ),
                                      child: Builder(
                                        builder: (context) {
                                          final itemProv = AppUrl.imageProvider(itemAvatar);
                                          return CircleAvatar(
                                            radius: 18,
                                            backgroundColor: AppColors.fieldColor,
                                            backgroundImage: itemProv,
                                            onBackgroundImageError: itemProv != null ? (_, __) {} : null,
                                            child: itemProv == null
                                                ? Text(
                                                    item.name.isNotEmpty
                                                        ? item.name[0].toUpperCase()
                                                        : 'U',
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                : null,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () => _openUserProfile(
                                                  item.name,
                                                  item.username,
                                                  itemAvatar,
                                                ),
                                                child: Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                item.time,
                                                style: const TextStyle(
                                                  color: AppColors.greyText,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.text,
                                            style: const TextStyle(
                                              color: Color(0xFF334155),
                                              fontSize: 13,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Action buttons: Like and Reply
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          item.isLiked = !item.isLiked;
                                          item.likesCount +=
                                              item.isLiked ? 1 : -1;
                                          if (item.likesCount < 0) {
                                            item.likesCount = 0;
                                          }
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 3),
                                        child: Row(
                                          children: [
                                            Icon(
                                              item.isLiked
                                                  ? Icons.favorite_rounded
                                                  : Icons.favorite_border_rounded,
                                              size: 15,
                                              color: item.isLiked
                                                  ? Colors.redAccent
                                                  : const Color(0xFF64748B),
                                            ),
                                            if (item.likesCount > 0) ...[
                                              const SizedBox(width: 4),
                                              Text(
                                                '${item.likesCount}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: item.isLiked
                                                      ? Colors.redAccent
                                                      : const Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () {
                                        CommentReplySheet.show(
                                          context,
                                          comment: item,
                                          tripId: widget.trip.id,
                                          onReplyAdded: (_) => setState(() {}),
                                          onStateChanged: () => setState(() {}),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.reply_rounded,
                                              size: 14,
                                              color: Color(0xFF475569),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              item.replies.isNotEmpty
                                                  ? '${item.replies.length} ${item.replies.length == 1 ? "reply" : "replies"}'
                                                  : 'Reply',
                                              style: const TextStyle(
                                                fontSize: 11,
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
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Price",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        trip.price,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "/ person",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              if (!CurrentUser.isCurrentUser(trip.username))
                Expanded(
                  child: ElevatedButton(
                    onPressed: _joinTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 2,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Join Trip Now",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return ValueListenableBuilder<List<Review>>(
      valueListenable: ReviewStore.reviewsNotifier,
      builder: (context, allReviews, _) {
        final tripReviews = ReviewStore.getReviewsForTrip(widget.trip.id);
        final reviewCount = tripReviews.length;
        final avgRating = reviewCount > 0
            ? ReviewStore.getAverageRating(widget.trip.id)
            : (double.tryParse(widget.trip.rating) ?? 5.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      "Reviews & Ratings",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "$reviewCount",
                        style: const TextStyle(
                          color: Color(0xFFB45309),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RatingScreen(trip: widget.trip),
                      ),
                    );
                    if (updated == true && mounted) {
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.rate_review_outlined,
                      size: 15, color: AppColors.primary),
                  label: const Text(
                    "Rate Trip",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF78350F),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "/ 5.0",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          final starFill = index < avgRating.round();
                          return Icon(
                            starFill
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 18,
                            color: const Color(0xFFD97706),
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$reviewCount verified ${reviewCount == 1 ? 'review' : 'reviews'}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF92400E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.thumb_up_alt_rounded,
                          color: Colors.green,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Recommended",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          reviewCount > 0
                              ? "${((tripReviews.where((r) => r.wouldRecommend).length / reviewCount) * 100).round()}% recommend"
                              : "100% positive",
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (tripReviews.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.rate_review_outlined,
                        size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    const Text(
                      "No reviews for this trip yet",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Be the first travel buddy to share your experience!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.greyText,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RatingScreen(trip: widget.trip),
                          ),
                        );
                        if (updated == true && mounted) {
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      icon: const Icon(Icons.star_rounded, size: 16),
                      label: const Text(
                        "Write First Review",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tripReviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final review = tripReviews[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Builder(
                              builder: (context) {
                                final revProv = AppUrl.imageProvider(review.userAvatarUrl);
                                return CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.fieldColor,
                                  backgroundImage: revProv,
                                  onBackgroundImageError: revProv != null ? (_, __) {} : null,
                                  child: revProv == null
                                      ? Text(
                                          review.userName.isNotEmpty
                                              ? review.userName[0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        review.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        review.timeAgo,
                                        style: const TextStyle(
                                          color: AppColors.greyText,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    review.userUsername,
                                    style: const TextStyle(
                                      color: AppColors.greyText,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Row(
                              children: List.generate(5, (starIdx) {
                                final isFull = starIdx < review.rating.round();
                                return Icon(
                                  isFull
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 16,
                                  color: Colors.amber.shade700,
                                );
                              }),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              review.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF78350F),
                              ),
                            ),
                            const Spacer(),
                            if (review.wouldRecommend)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFA7F3D0)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        size: 11,
                                        color: Color(0xFF059669)),
                                    SizedBox(width: 4),
                                    Text(
                                      "Recommends",
                                      style: TextStyle(
                                        color: Color(0xFF059669),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (review.reviewText.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            review.reviewText,
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ],
                        if (review.tags.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: review.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 28),
          ],
        );
      },
    );
  }
}
