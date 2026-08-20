import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/screens/edit_profile_screen.dart';
import 'package:travel_buddy_finder/screens/login_screen.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';
import 'package:travel_buddy_finder/widgets/screen_background.dart';

class ManageAccountSettingsScreen extends StatelessWidget {
  final String name;
  final String username;
  final String avatarUrl;
  final Uint8List? avatarBytes;
  final ValueChanged<Map<String, dynamic>> onProfileUpdated;

  const ManageAccountSettingsScreen({
    super.key,
    this.name = "Md Yeasin",
    this.username = "@yeasin",
    this.avatarUrl =
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80",
    this.avatarBytes,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Manage Account Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
      ),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            _buildSectionTitle('ACCOUNT'),
            const SizedBox(height: 10),
            _buildTile(
              context,
              icon: Icons.person_outline_rounded,
              title: 'Edit Profile',
              subtitle: 'Update your name, bio, and avatar',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      name: name,
                      username: username,
                      avatarUrl: avatarUrl,
                      avatarBytes: avatarBytes,
                      onProfileUpdated: onProfileUpdated,
                    ),
                  ),
                );
              },
            ),
            _buildTile(
              context,
              icon: Icons.lock_outline_rounded,
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: () {},
            ),
            _buildTile(
              context,
              icon: Icons.mail_outline_rounded,
              title: 'Email Address',
              subtitle: 'Change your registered email',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('PREFERENCES'),
            const SizedBox(height: 10),
            _buildTile(
              context,
              icon: Icons.notification_add_outlined,
              title: 'Notification Settings',
              subtitle: 'Manage push and email alerts',
              onTap: () {},
            ),
            _buildTile(
              context,
              icon: Icons.visibility_outlined,
              title: 'Privacy Settings',
              subtitle: 'Control who can see your profile',
              onTap: () {},
            ),
            _buildTile(
              context,
              icon: Icons.language_outlined,
              title: 'Language & Region',
              subtitle: 'App language and currency',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('SUPPORT'),
            const SizedBox(height: 10),
            _buildTile(
              context,
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              subtitle: 'FAQs and contact support',
              onTap: () {},
            ),
            _buildTile(
              context,
              icon: Icons.info_outline_rounded,
              title: 'About',
              subtitle: 'App version and terms',
              onTap: () {},
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Log Out'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey.shade400,
          size: 20,
        ),
      ),
    );
  }
}
