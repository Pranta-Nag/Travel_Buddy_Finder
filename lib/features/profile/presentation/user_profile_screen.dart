import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/auth_provider.dart';
import 'package:travel_buddy_finder/api/providers/profile_provider.dart';
import 'package:travel_buddy_finder/api/providers/trip_provider.dart';
import 'package:travel_buddy_finder/api/providers/trip_request_provider.dart';
import 'package:travel_buddy_finder/features/bookmarks/data/bookmark_store.dart';
import 'package:travel_buddy_finder/features/profile/presentation/manage_account_settings_screen.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip_request.dart';
import 'package:travel_buddy_finder/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:travel_buddy_finder/features/trips/data/stores/trip_store.dart';
import 'package:travel_buddy_finder/features/trips/presentation/screens/my_trip_screen.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';
import 'package:travel_buddy_finder/features/trips/data/stores/trip_request_store.dart';
import 'dart:convert';
import 'package:travel_buddy_finder/core/widgets/screen_background.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/trip_request/approvals_drawer.dart';
import 'package:travel_buddy_finder/features/trips/presentation/screens/view_screen.dart';
import 'package:travel_buddy_finder/features/trips/presentation/screens/edit_trip_screen.dart';
import 'package:travel_buddy_finder/features/trips/presentation/screens/add_new_trip_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String name;
  final String username;
  final String level;
  final String avatarUrl;
  final Uint8List? avatarBytes;
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    this.name = "",
    this.username = "",
    this.level = "Traveler",
    this.avatarUrl = "",
    this.avatarBytes,
    this.isCurrentUser = true,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late String _name;
  late String _username;
  late String _avatarUrl;
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _username = widget.username;
    _avatarUrl = widget.avatarUrl;
    _avatarBytes = widget.avatarBytes;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isCurrentUser) {
        context.read<ProfileProvider>().fetchMyProfile();
        context.read<TripRequestProvider>().fetchPendingRequests();
      } else if (widget.username.isNotEmpty) {
        context.read<ProfileProvider>().fetchUserProfile(widget.username);
      }
      context.read<TripProvider>().fetchAllTrips();
    });
  }

  void _updateProfile(Map<String, dynamic> data) {
    setState(() {
      _name = data['name'] as String;
      _username = data['username'] as String;
      _avatarUrl = data['avatarUrl'] as String;
      _avatarBytes = data['avatarBytes'] as Uint8List?;
    });
  }

  Widget _buildAvatarWidget(String avatarUrl, String? gender) {
    final defaultAsset = (gender ?? '').toLowerCase().contains('fem') ||
            (gender ?? '').toLowerCase().contains('girl')
        ? 'assets/images/dummy_girl.png'
        : 'assets/images/dummy_boy.jpg';

    Widget imageWidget;
    if (_avatarBytes != null) {
      imageWidget = Image.memory(
        _avatarBytes!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else if (avatarUrl.isNotEmpty &&
        (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'))) {
      imageWidget = Image.network(
        avatarUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          defaultAsset,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey.shade200,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
      );
    } else if (avatarUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        avatarUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else if (avatarUrl.isNotEmpty) {
      final resolved = AppUrl.resolveImageUrl(avatarUrl);
      if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
        imageWidget = Image.network(
          resolved,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            defaultAsset,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        );
      } else {
        imageWidget = Image.asset(
          defaultAsset,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        );
      }
    } else {
      imageWidget = Image.asset(
        defaultAsset,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: 124,
      height: 124,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(child: imageWidget),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = !widget.isCurrentUser || Navigator.canPop(context);

    final profileProvider = context.watch<ProfileProvider>();
    final authUser = widget.isCurrentUser
        ? (profileProvider.myProfile ?? context.watch<AuthProvider>().currentUser)
        : profileProvider.viewedProfile;
    final isLoading = profileProvider.isLoading;

    final displayName = authUser != null && authUser.fullName.isNotEmpty
        ? authUser.fullName
        : (_name.isNotEmpty
            ? _name
            : (widget.isCurrentUser ? CurrentUser.name : "Traveler"));

    final displayUsername = authUser != null && authUser.username.isNotEmpty
        ? '@${authUser.username.replaceAll('@', '')}'
        : (_username.isNotEmpty
            ? (_username.startsWith('@') ? _username : '@$_username')
            : (widget.isCurrentUser ? CurrentUser.username : "@traveler"));

    final displayAvatar = _avatarBytes != null
        ? ''
        : (authUser != null && authUser.avatarUrl.isNotEmpty
            ? authUser.avatarUrl
            : (_avatarUrl.isNotEmpty
                ? _avatarUrl
                : (widget.isCurrentUser ? CurrentUser.avatarUrl : 'assets/images/dummy_boy.jpg')));

    final displayGender = authUser?.gender;

    final tripProvider = context.watch<TripProvider>();
    final apiTrips = tripProvider.trips.map((m) => m.toTrip()).toList();

    final Set<String> seenIds = {};
    final List<Trip> allTrips = [];
    for (final t in apiTrips) {
      if (seenIds.add(t.id)) allTrips.add(t);
    }
    for (final t in TripStore.trips) {
      if (seenIds.add(t.id)) allTrips.add(t);
    }

    final targetUsername = widget.isCurrentUser
        ? (authUser?.username ?? CurrentUser.username)
        : widget.username;
    final targetName = widget.isCurrentUser
        ? (authUser?.fullName ?? CurrentUser.name)
        : widget.name;

    final hostedTrips = allTrips.where((t) {
      if (widget.isCurrentUser) {
        return CurrentUser.isCurrentUser(t.username, inputName: t.hostName);
      } else {
        final cleanTargetUser = targetUsername.replaceAll('@', '').trim().toLowerCase();
        final cleanTargetName = targetName.trim().toLowerCase();
        final cleanTripUser = t.username.replaceAll('@', '').trim().toLowerCase();
        final cleanTripHost = t.hostName.trim().toLowerCase();
        return cleanTripUser == cleanTargetUser ||
            cleanTripHost == cleanTargetName ||
            cleanTripHost == cleanTargetUser;
      }
    }).toList();

    final hostedCount = (authUser?.totalHostedTrips ?? 0) > 0
        ? authUser!.totalHostedTrips
        : hostedTrips.length;

    return Scaffold(
      endDrawer: widget.isCurrentUser ? const ApprovalsDrawer() : null,
      body: ScreenBackground(
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              if (widget.isCurrentUser) {
                await Future.wait([
                  context.read<ProfileProvider>().fetchMyProfile(silent: true),
                  context.read<TripProvider>().fetchAllTrips(),
                ]);
              } else if (widget.username.isNotEmpty) {
                await Future.wait([
                  context.read<ProfileProvider>().fetchUserProfile(widget.username),
                  context.read<TripProvider>().fetchAllTrips(),
                ]);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  if (canGoBack) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Color(0xFF1F2937)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Text(
                          widget.isCurrentUser ? "My Profile" : "User Profile",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.share_outlined,
                                color: Color(0xFF1F2937), size: 20),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Profile link copied to clipboard!"),
                                  duration: Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    const SizedBox(height: 20),
                  ],
                  if (isLoading && authUser == null && _name.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else ...[
                    Column(
                      children: [
                        _buildAvatarWidget(displayAvatar, displayGender),
                        const SizedBox(height: 16),
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$displayUsername • ${authUser?.level ?? widget.level}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem("${authUser?.totalJoinedTrips ?? 0}", "TRIPS JOINED"),
                          _buildDivider(),
                          _buildStatItem("$hostedCount", "HOSTED TRIPS"),
                          _buildDivider(),
                          _buildStatItem(authUser?.rating ?? "5.0", "AVG RATING"),
                        ],
                      ),
                    ),
                  ],
                const SizedBox(height: 20),
                _buildSection(
                  title: "TRAVEL INTERESTS",
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildInterestChip("Solo Travel"),
                      _buildInterestChip("Beach Volley"),
                      _buildInterestChip("Photography"),
                      _buildInterestChip("Backpacking"),
                      _buildInterestChip("Zen Temples"),
                      _buildInterestChip("Gourmet Eating"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: "ACHIEVEMENTS / BADGES",
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildBadgeItem("🏅", "Wanderlust"),
                      _buildBadgeItem("🔥", "5-Streak"),
                      _buildBadgeItem("🛡️", "ID Verified"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (widget.isCurrentUser)
                  _buildSection(
                    title: "QUICK ACTIONS",
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildQuickActionItem(
                          Icons.bookmark_border_rounded,
                          "Bookmark",
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BookmarksScreen(),
                            ),
                          ),
                        ),
                        ValueListenableBuilder<List<TripRequest>>(
                          valueListenable: TripRequestStore.requests,
                          builder: (context, requests, _) {
                            final localPending =
                                TripRequestStore.pendingCountForHost(
                                    authUser?.username ?? CurrentUser.username);
                            final pending = (authUser?.pendingRequestsCount ?? 0) > 0
                                ? authUser!.pendingRequestsCount
                                : localPending;
                            return _buildQuickActionItem(
                              Icons.fact_check_outlined,
                              "Trip Approvals",
                              onTap: () => Scaffold.of(context).openEndDrawer(),
                              badgeCount: pending,
                            );
                          },
                        ),
                        _buildQuickActionItem(
                          Icons.directions_walk_rounded,
                          "My Trips",
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MyTripScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                _buildHostedTripsSection(hostedTrips),
                const SizedBox(height: 30),
                if (widget.isCurrentUser) ...[
                  const SizedBox(height: 0),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ManageAccountSettingsScreen(
                              name: displayName,
                              username: displayUsername,
                              avatarUrl: displayAvatar,
                              avatarBytes: _avatarBytes,
                              onProfileUpdated: _updateProfile,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Manage Account Settings",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("Chat with $displayName coming soon!"),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline_rounded,
                                color: Colors.white, size: 18),
                            label: const Text(
                              "Message",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Followed $displayName!"),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.person_add_outlined,
                              size: 18, color: AppColors.primary),
                          label: const Text(
                            "Follow",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.primary, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildHostedTripsSection(List<Trip> trips) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.flight_takeoff_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.isCurrentUser ? "My Hosted Trips" : "Hosted Trips",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${trips.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.isCurrentUser && trips.isNotEmpty)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddNewTripScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add_circle_outline_rounded,
                            size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          "Host New",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (trips.isEmpty)
            _buildHostedTripsEmptyState()
          else
            ValueListenableBuilder<int>(
              valueListenable: TripStore.tripListNotifier,
              builder: (context, _, __) {
                return Column(
                  children: trips.asMap().entries.map((entry) {
                    final index = entry.key;
                    final trip = entry.value;
                    return _buildHostedTripCard(trip, index);
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHostedTripCard(Trip trip, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ViewScreen(
                  trip: trip,
                  heroTag: 'profile-hosted-${trip.id}-$index',
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Cover Image Stack
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildHostedCoverImage(trip),
                    // Gradient overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                    // Top Row: Category & Seats
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.explore_outlined,
                                    size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  trip.category.isNotEmpty
                                      ? trip.category
                                      : "Adventure",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: trip.seatsLeft > 0
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.people_alt_rounded,
                                    size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  trip.seatsLeft > 0
                                      ? '${trip.seatsLeft} spots left'
                                      : 'Fully Booked',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bottom Row on Image: Location & Price
                    Positioned(
                      bottom: 10,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    trip.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 6,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              trip.price.startsWith('৳') ||
                                      trip.price.toLowerCase().contains('tk')
                                  ? trip.price
                                  : '৳${trip.price}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Card Body
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      trip.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rating & Transport Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFFFDE68A), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 14, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 3),
                              Text(
                                trip.rating.isNotEmpty ? trip.rating : "5.0",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (trip.transportationMethods != null &&
                            trip.transportationMethods!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: Colors.grey.shade200, width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.commute_rounded,
                                    size: 12, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(
                                  trip.transportationMethods!.first,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (trip.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        trip.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade600,
                          height: 1.35,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey.shade100),
                    const SizedBox(height: 10),

                    // Actions Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // View Details Action
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewScreen(
                                  trip: trip,
                                  heroTag:
                                      'profile-hosted-btn-${trip.id}-$index',
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  "View Details",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Edit / Delete Actions (for host) or Bookmark (for viewer)
                        if (widget.isCurrentUser) ...[
                          Row(
                            children: [
                              // Edit Button
                              Tooltip(
                                message: "Edit Trip",
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditTripScreen(trip: trip),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Delete Button
                              Tooltip(
                                message: "Delete Trip",
                                child: InkWell(
                                  onTap: () => _handleDeleteTrip(trip),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      size: 16,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          ValueListenableBuilder<List<dynamic>>(
                            valueListenable: BookmarkStore.savedTrips,
                            builder: (context, savedTrips, _) {
                              final isBookmarked =
                                  savedTrips.any((item) => item.id == trip.id);
                              return InkWell(
                                onTap: () => BookmarkStore.toggle(trip),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isBookmarked
                                        ? AppColors.primary
                                            .withValues(alpha: 0.1)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isBookmarked
                                            ? Icons.bookmark_rounded
                                            : Icons.bookmark_border_rounded,
                                        size: 16,
                                        color: isBookmarked
                                            ? AppColors.primary
                                            : Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isBookmarked ? "Saved" : "Save",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isBookmarked
                                              ? AppColors.primary
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHostedCoverImage(Trip trip) {
    if (trip.imageBytes != null && trip.imageBytes!.isNotEmpty) {
      return Image.memory(
        trip.imageBytes!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildHostedImageFallback(trip.title),
      );
    }

    final url = trip.imageUrl.trim();
    if (url.startsWith('data:image')) {
      try {
        final base64String = url.split(',').last.trim();
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildHostedImageFallback(trip.title),
        );
      } catch (_) {
        return _buildHostedImageFallback(trip.title);
      }
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildHostedImageFallback(trip.title),
      );
    }

    if (url.isNotEmpty) {
      final resolved = AppUrl.resolveImageUrl(url);
      if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
        return Image.network(
          resolved,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _buildHostedImageFallback(trip.title),
        );
      }
    }

    return _buildHostedImageFallback(trip.title);
  }

  Widget _buildHostedImageFallback(String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            const Color(0xFF0F766E),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.landscape_rounded,
                color: Colors.white70, size: 36),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostedTripsEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.luggage_rounded,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.isCurrentUser
                ? "You haven't hosted any trips yet"
                : "No hosted trips published yet",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.isCurrentUser
                ? "Publish your travel plan, invite companions, and explore exciting destinations together!"
                : "Trips organized and published by this user will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
          if (widget.isCurrentUser) ...[
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddNewTripScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                "Host a New Trip",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleDeleteTrip(Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_forever_rounded,
                  color: Colors.red.shade600, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Delete Trip',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete "${trip.title}"?\nThis action cannot be undone.',
          style: TextStyle(
              color: Colors.grey.shade700, fontSize: 14, height: 1.4),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete Trip',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      TripStore.remove(trip.id);
      final intId = int.tryParse(trip.id);
      if (intId != null && intId > 0) {
        await context.read<TripProvider>().deleteTrip(intId);
      }
      if (!mounted) return;
      await context.read<TripProvider>().fetchAllTrips();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trip "${trip.title}" deleted successfully.'),
          backgroundColor: const Color(0xFF1F2937),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInterestChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBadgeItem(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label,
      {VoidCallback? onTap, int? badgeCount}) {
    final showBadge = badgeCount != null && badgeCount > 0;
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFF4B5563),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
            if (showBadge) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
