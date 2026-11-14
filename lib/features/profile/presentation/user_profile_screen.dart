import 'package:travel_buddy_finder/api/providers/chat_provider.dart';
import 'package:travel_buddy_finder/features/chat/presentation/screens/chat_room_screen.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/auth_provider.dart';
import 'package:travel_buddy_finder/api/providers/profile_provider.dart';
import 'package:travel_buddy_finder/api/providers/trip_provider.dart';
import 'package:travel_buddy_finder/api/providers/trip_request_provider.dart';
import 'package:travel_buddy_finder/features/bookmarks/data/bookmark_store.dart';
import 'package:travel_buddy_finder/features/profile/presentation/manage_account_settings_screen.dart';
import 'package:travel_buddy_finder/features/profile/presentation/edit_profile_screen.dart';
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
  final dynamic tripId;
  final String? tripTitle;

  const UserProfileScreen({
    super.key,
    this.name = "",
    this.username = "",
    this.level = "Traveler",
    this.avatarUrl = "",
    this.avatarBytes,
    this.isCurrentUser = true,
    this.tripId,
    this.tripTitle,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  Future<void> _openDirectChat({
    required String displayName,
    required String displayUsername,
    required String displayAvatar,
    required List<Trip> hostedTrips,
    required List<Trip> allTrips,
  }) async {
    final isMe = CurrentUser.isCurrentUser(
      displayUsername,
      inputName: displayName,
    );
    if (isMe) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You cannot message yourself."),
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

    // Determine target trip if available
    dynamic selectedTripId = widget.tripId;
    String? selectedTripTitle = widget.tripTitle;

    if (selectedTripId == null && hostedTrips.isNotEmpty) {
      selectedTripId = hostedTrips.first.id;
      selectedTripTitle ??= hostedTrips.first.title;
    }

    if (selectedTripId == null && allTrips.isNotEmpty) {
      final cleanTargetUser =
          displayUsername.replaceAll('@', '').trim().toLowerCase();
      final matchedTrip = allTrips.firstWhere(
        (t) =>
            t.username.replaceAll('@', '').trim().toLowerCase() ==
            cleanTargetUser,
        orElse: () => allTrips.first,
      );
      selectedTripId = matchedTrip.id;
      selectedTripTitle ??= matchedTrip.title;
    }

    final result = await context.read<ChatProvider>().startChat(
      selectedTripId,
      partnerUsername: displayUsername,
    );

    if (!mounted) return;
    Navigator.pop(context); // close loading

    if (result.success && result.roomId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            roomId: result.roomId!,
            partnerName: displayName,
            partnerAvatarUrl: displayAvatar,
            tripTitle: result.tripTitle ?? selectedTripTitle,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message.isNotEmpty
                ? result.message
                : "Could not initiate chat with $displayName.",
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildAvatarWidget(String avatarUrl, String? gender, {VoidCallback? onEdit}) {
    final defaultAsset = (gender ?? '').toLowerCase().contains('fem') ||
            (gender ?? '').toLowerCase().contains('girl')
        ? 'assets/images/dummy_girl.png'
        : 'assets/images/dummy_boy.jpg';

    Widget imageWidget;
    if (_avatarBytes != null) {
      imageWidget = Image.memory(
        _avatarBytes!,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      );
    } else if (avatarUrl.isNotEmpty &&
        (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'))) {
      imageWidget = Image.network(
        avatarUrl,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          defaultAsset,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 110,
            height: 110,
            color: const Color(0xFFF1F5F9),
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
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      );
    } else if (avatarUrl.isNotEmpty) {
      final resolved = AppUrl.resolveImageUrl(avatarUrl);
      if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
        imageWidget = Image.network(
          resolved,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            defaultAsset,
            width: 110,
            height: 110,
            fit: BoxFit.cover,
          ),
        );
      } else {
        imageWidget = Image.asset(
          defaultAsset,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
        );
      }
    } else {
      imageWidget = Image.asset(
        defaultAsset,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 114,
          height: 114,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(2.5),
            child: ClipOval(child: imageWidget),
          ),
        ),
        if (onEdit != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(7.5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        else if (!widget.isCurrentUser)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ),
      ],
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

    // Use API trips if available, otherwise fallback to local mock TripStore
    final List<Trip> allTrips = apiTrips.isNotEmpty
        ? apiTrips
        : TripStore.trips;

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

    final hostedCount = hostedTrips.isNotEmpty
        ? hostedTrips.length
        : ((authUser?.totalHostedTrips ?? 0) > 0 ? authUser!.totalHostedTrips : 0);

    return Scaffold(
      key: _scaffoldKey,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Navigation Bar
                  if (canGoBack) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.borderColor, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A)
                                    .withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            splashRadius: 22,
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Color(0xFF0F172A), size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Text(
                          widget.isCurrentUser ? "My Profile" : "Traveler Profile",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.borderColor, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A)
                                    .withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            splashRadius: 22,
                            icon: const Icon(Icons.share_outlined,
                                color: Color(0xFF0F172A), size: 18),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      "Profile link copied to clipboard!"),
                                  backgroundColor: const Color(0xFF0F172A),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "My Profile",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Manage your account & travel presence",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.borderColor, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A)
                                        .withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                splashRadius: 22,
                                icon: const Icon(Icons.share_outlined,
                                    color: Color(0xFF0F172A), size: 18),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          "Profile link copied to clipboard!"),
                                      backgroundColor: const Color(0xFF0F172A),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.borderColor, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A)
                                        .withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                splashRadius: 22,
                                icon: const Icon(Icons.tune_rounded,
                                    color: Color(0xFF0F172A), size: 18),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ManageAccountSettingsScreen(
                                        name: displayName,
                                        username: displayUsername,
                                        avatarUrl: displayAvatar,
                                        avatarBytes: _avatarBytes,
                                        onProfileUpdated: _updateProfile,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                    // Hero Profile Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: AppColors.borderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A)
                                .withValues(alpha: 0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildAvatarWidget(
                            displayAvatar,
                            displayGender,
                            onEdit: widget.isCurrentUser
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditProfileScreen(
                                          name: displayName,
                                          username: displayUsername,
                                          avatarUrl: displayAvatar,
                                          avatarBytes: _avatarBytes,
                                          onProfileUpdated: _updateProfile,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified_rounded,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                displayUsername,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (authUser?.country != null &&
                                  authUser!.country!.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                const Text("•",
                                    style:
                                        TextStyle(color: Color(0xFF94A3B8))),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 13,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  authUser.country!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.2),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.stars_rounded,
                                      size: 13,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      authUser?.level ?? widget.level,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFA7F3D0),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shield_outlined,
                                      size: 13,
                                      color: Color(0xFF059669),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Verified Member",
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Travel Statistics Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: AppColors.borderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A)
                                .withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              value: "${authUser?.totalJoinedTrips ?? 0}",
                              label: "TRIPS JOINED",
                              icon: Icons.luggage_outlined,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                          _buildDivider(),
                          Expanded(
                            child: _buildStatItem(
                              value: "$hostedCount",
                              label: "HOSTED TRIPS",
                              icon: Icons.flight_takeoff_rounded,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          _buildDivider(),
                          Expanded(
                            child: _buildStatItem(
                              value: authUser?.rating ?? "5.0",
                              label: "AVG RATING",
                              icon: Icons.star_rounded,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),

                  // Quick Actions Hub (for current user)
                  if (widget.isCurrentUser) ...[
                    _buildSection(
                      title: "QUICK ACTIONS",
                      icon: Icons.bolt_rounded,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.bookmark_rounded,
                              iconBg: const Color(0xFFEEF2FF),
                              iconColor: const Color(0xFF4F46E5),
                              title: "Bookmarks",
                              subtitle: "Saved Trips",
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const BookmarksScreen(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ValueListenableBuilder<List<TripRequest>>(
                              valueListenable: TripRequestStore.requests,
                              builder: (context, requests, _) {
                                final localPending =
                                    TripRequestStore.pendingCountForHost(
                                        authUser?.username ??
                                            CurrentUser.username);
                                final pending =
                                    (authUser?.pendingRequestsCount ?? 0) > 0
                                        ? authUser!.pendingRequestsCount
                                        : localPending;
                                return _buildQuickActionCard(
                                  icon: Icons.checklist_rtl_rounded,
                                  iconBg: pending > 0
                                      ? const Color(0xFFFEF2F2)
                                      : const Color(0xFFFFFBEB),
                                  iconColor: pending > 0
                                      ? AppColors.error
                                      : const Color(0xFFD97706),
                                  title: "Approvals",
                                  subtitle: pending > 0
                                      ? "$pending pending"
                                      : "Requests",
                                  badgeCount: pending,
                                  onTap: () => _scaffoldKey.currentState
                                      ?.openEndDrawer(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.hiking_rounded,
                              iconBg: const Color(0xFFECFDF5),
                              iconColor: const Color(0xFF059669),
                              title: "My Trips",
                              subtitle: "Created/Joined",
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const MyTripScreen(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Travel Interests
                  _buildSection(
                    title: "TRAVEL INTERESTS",
                    icon: Icons.interests_outlined,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                  const SizedBox(height: 18),

                  // Achievements & Badges
                  _buildSection(
                    title: "ACHIEVEMENTS & BADGES",
                    icon: Icons.military_tech_outlined,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildBadgeItem("🏅", "Wanderlust", "Top Explorer"),
                        _buildBadgeItem("🔥", "5-Streak", "Active Week"),
                        _buildBadgeItem("🛡️", "ID Verified", "Trusted Host"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Hosted Trips Section
                  _buildHostedTripsSection(hostedTrips),
                  const SizedBox(height: 24),
                  if (widget.isCurrentUser) ...[
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF0F172A).withValues(alpha: 0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
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
                        icon: const Icon(Icons.tune_rounded,
                            size: 20, color: Colors.white),
                        label: const Text(
                          "Manage Account Settings",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _openDirectChat(
                                displayName: displayName,
                                displayUsername: displayUsername,
                                displayAvatar: displayAvatar,
                                hostedTrips: hostedTrips,
                                allTrips: allTrips,
                              ),
                              icon: const Icon(Icons.chat_bubble_outline_rounded,
                                  color: Colors.white, size: 18),
                              label: const Text(
                                "Message",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
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
                                  backgroundColor: const Color(0xFF0F172A),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
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
        border: Border.all(color: AppColors.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
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
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
        border: Border.all(color: AppColors.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
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
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                        if (CurrentUser.isCurrentUser(trip.username,
                            inputName: trip.hostName)) ...[
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 1),
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

  Widget _buildStatItem({
    required String value,
    required String label,
    IconData icon = Icons.analytics_outlined,
    Color color = AppColors.primary,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 36,
      width: 1,
      color: AppColors.borderColor,
    );
  }

  Widget _buildSection({
    required String title,
    IconData? icon,
    Widget? action,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 14, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              if (action != null) action,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildInterestChip(String label, [IconData? icon]) {
    final IconData effectiveIcon = icon ?? _resolveInterestIcon(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(effectiveIcon, size: 13.5, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _resolveInterestIcon(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('beach') || lower.contains('sea')) {
      return Icons.beach_access_rounded;
    } else if (lower.contains('photo') || lower.contains('cam')) {
      return Icons.camera_alt_outlined;
    } else if (lower.contains('backpack') || lower.contains('hik')) {
      return Icons.hiking_rounded;
    } else if (lower.contains('temple') || lower.contains('zen')) {
      return Icons.temple_buddhist_outlined;
    } else if (lower.contains('food') || lower.contains('eat') || lower.contains('gourmet')) {
      return Icons.restaurant_rounded;
    } else if (lower.contains('solo')) {
      return Icons.person_pin_circle_outlined;
    }
    return Icons.explore_outlined;
  }

  Widget _buildBadgeItem(String icon, String label, [String? subtitle]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    final showBadge = badgeCount != null && badgeCount > 0;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  if (showBadge)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: showBadge ? AppColors.error : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
