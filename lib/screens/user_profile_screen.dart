import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/screens/bookmarks_screen.dart';
import 'package:travel_buddy_finder/screens/manage_account_settings_screen.dart';
import 'package:travel_buddy_finder/screens/my_trip_screen.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';
import 'package:travel_buddy_finder/widgets/screen_background.dart';

class UserProfileScreen extends StatefulWidget {
  final String name;
  final String username;
  final String level;
  final String avatarUrl;
  final Uint8List? avatarBytes;
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    this.name = "Md Yeasin",
    this.username = "@yeasin",
    this.level = "Level 4 Travel Guru",
    this.avatarUrl =
        "https://i.postimg.cc/W4FfXNcG/profile.jpg",
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
  }

  void _updateProfile(Map<String, dynamic> data) {
    setState(() {
      _name = data['name'] as String;
      _username = data['username'] as String;
      _avatarUrl = data['avatarUrl'] as String;
      _avatarBytes = data['avatarBytes'] as Uint8List?;
    });
  }

  ImageProvider _getAvatarImage() {
    if (_avatarBytes != null) {
      return MemoryImage(_avatarBytes!);
    }
    return NetworkImage(_avatarUrl);
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = !widget.isCurrentUser || Navigator.canPop(context);

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
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
                          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F2937)),
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
                          icon: const Icon(Icons.share_outlined, color: Color(0xFF1F2937), size: 20),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Profile link copied to clipboard!"),
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

                Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _getAvatarImage(),
                      backgroundColor: Colors.grey.shade200,
                      onBackgroundImageError: (_, __) {},
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$_username • ${widget.level}",
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
                    _buildStatItem("12", "COMPLETED TRIPS"),
                    _buildDivider(),
                    _buildStatItem("342", "FOLLOWERS"),
                    _buildDivider(),
                    _buildStatItem("4.9", "AVG RATING"),
                  ],
                ),
              ),
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
                      _buildQuickActionItem(
                        Icons.fact_check_outlined,
                        "Trip Approvals",
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
                            name: _name,
                            username: _username,
                            avatarUrl: _avatarUrl,
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
                                content: Text("Chat with $_name coming soon!"),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
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
                              content: Text("Followed $_name!"),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_add_outlined, size: 18, color: AppColors.primary),
                        label: const Text(
                          "Follow",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
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
  );
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
      {VoidCallback? onTap}) {
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
          ],
        ),
      ),
    );
  }
}
