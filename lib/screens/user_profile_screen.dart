import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/screens/bookmarks_screen.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';

class UserProfileScreen extends StatelessWidget {
  final String name;
  final String username;
  final String level;
  final String avatarUrl;

  const UserProfileScreen({
    super.key,
    this.name = "Md Yeasin",
    this.username = "@yeasin",
    this.level = "Level 4 Travel Guru",
    this.avatarUrl =
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            // Profile Info Section
            Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(avatarUrl),
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$username • $level",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Stats Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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

            // Travel Interests Section
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

            // Achievements Section
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

            // Quick Actions Section
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
                      Icons.fact_check_outlined, "Trip Approvals"),
                  _buildQuickActionItem(
                      Icons.directions_walk_rounded, "My Trips"),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Manage Account Settings Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
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
            const SizedBox(height: 20),
          ],
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
            color: Colors.black.withOpacity(0.05),
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
        color: AppColors.primary.withOpacity(0.1),
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

  static Widget _buildBadgeItem(String icon, String label) {
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
