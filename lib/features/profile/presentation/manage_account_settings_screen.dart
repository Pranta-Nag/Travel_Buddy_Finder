import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/auth_provider.dart';
import 'package:travel_buddy_finder/api/providers/profile_provider.dart';
import 'package:travel_buddy_finder/features/profile/presentation/change_password_screen.dart';
import 'package:travel_buddy_finder/features/profile/presentation/edit_profile_screen.dart';
import 'package:travel_buddy_finder/features/auth/presentation/login_screen.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/core/widgets/screen_background.dart';

class ManageAccountSettingsScreen extends StatefulWidget {
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
  State<ManageAccountSettingsScreen> createState() =>
      _ManageAccountSettingsScreenState();
}

class _ManageAccountSettingsScreenState
    extends State<ManageAccountSettingsScreen> {
  // Local state for account settings features
  String _email = "yeasin@example.com";
  String _language = "English";
  String _currency = "USD (\$)";

  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _tripRequestAlerts = true;
  bool _promoAlerts = false;

  String _profileVisibility = "Public";
  bool _showLocation = true;
  bool _allowMessages = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = screenWidth >= 600;

    final authUser = context.watch<ProfileProvider>().myProfile ??
        context.watch<AuthProvider>().currentUser;
    final userEmail =
        authUser?.email.isNotEmpty == true ? authUser!.email : _email;
    final userName = authUser?.fullName.isNotEmpty == true
        ? authUser!.fullName
        : widget.name;
    final userHandle = authUser?.username.isNotEmpty == true
        ? authUser!.username
        : widget.username;
    final userAvatar = authUser?.avatarUrl.isNotEmpty == true
        ? authUser!.avatarUrl
        : widget.avatarUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Account Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          splashRadius: 22,
          icon: const Icon(Icons.arrow_back_rounded,
              color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.borderColor,
            height: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: ScreenBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isTabletOrDesktop ? 24 : 16,
                vertical: 16,
              ),
              children: [
                // User Profile Snapshot Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildMiniAvatar(userAvatar, widget.avatarBytes),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userHandle.startsWith('@')
                                  ? userHandle
                                  : '@$userHandle',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userEmail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                name: userName,
                                username: userHandle,
                                avatarUrl: userAvatar,
                                avatarBytes: widget.avatarBytes,
                                onProfileUpdated: widget.onProfileUpdated,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_outlined,
                                  size: 14, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                "Edit",
                                style: TextStyle(
                                  fontSize: 12,
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
                ),
                const SizedBox(height: 22),

                // Group 1: ACCOUNT & SECURITY
                _buildSectionTitle('ACCOUNT & SECURITY', Icons.security_rounded),
                const SizedBox(height: 8),
                _buildSettingsGroup(
                  items: [
                    _buildSettingsTile(
                      icon: Icons.person_outline_rounded,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: 'Edit Profile',
                      subtitle: 'Update your name, bio, and avatar',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(
                              name: userName,
                              username: userHandle,
                              avatarUrl: userAvatar,
                              avatarBytes: widget.avatarBytes,
                              onProfileUpdated: widget.onProfileUpdated,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.lock_outline_rounded,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      title: 'Change Password',
                      subtitle: 'Update your security credentials',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.mail_outline_rounded,
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: const Color(0xFF059669),
                      title: 'Email Address',
                      subtitle: userEmail,
                      onTap: () => _showEmailDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Group 2: PREFERENCES & PRIVACY
                _buildSectionTitle('PREFERENCES & PRIVACY', Icons.tune_rounded),
                const SizedBox(height: 8),
                _buildSettingsGroup(
                  items: [
                    _buildSettingsTile(
                      icon: Icons.notifications_none_rounded,
                      iconBg: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFF7C3AED),
                      title: 'Notification Settings',
                      subtitle: 'Manage push and email alerts',
                      onTap: () => _showNotificationSettingsSheet(context),
                    ),
                    _buildSettingsTile(
                      icon: Icons.visibility_outlined,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0284C7),
                      title: 'Privacy Settings',
                      subtitle:
                          'Control who sees your profile ($_profileVisibility)',
                      onTap: () => _showPrivacySettingsSheet(context),
                    ),
                    _buildSettingsTile(
                      icon: Icons.language_rounded,
                      iconBg: const Color(0xFFEEF2FF),
                      iconColor: const Color(0xFF4F46E5),
                      title: 'Language & Region',
                      subtitle: '$_language • $_currency',
                      onTap: () => _showLanguageRegionSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Group 3: SUPPORT & LEGAL
                _buildSectionTitle('SUPPORT & LEGAL', Icons.help_outline_rounded),
                const SizedBox(height: 8),
                _buildSettingsGroup(
                  items: [
                    _buildSettingsTile(
                      icon: Icons.support_agent_rounded,
                      iconBg: const Color(0xFFF0FDF4),
                      iconColor: const Color(0xFF16A34A),
                      title: 'Help & Support',
                      subtitle: 'FAQs and contact customer team',
                      onTap: () => _showHelpSupportSheet(context),
                    ),
                    _buildSettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconBg: const Color(0xFFF1F5F9),
                      iconColor: const Color(0xFF475569),
                      title: 'About App',
                      subtitle: 'Version 1.0.0 • Terms & Privacy',
                      onTap: () => _showAboutSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Logout Button
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFFCA5A5).withValues(alpha: 0.5),
                        width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => _handleLogout(context),
                      borderRadius: BorderRadius.circular(16),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded,
                              color: AppColors.error, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniAvatar(String avatarUrl, Uint8List? avatarBytes) {
    Widget imageWidget;
    if (avatarBytes != null) {
      imageWidget = Image.memory(
        avatarBytes,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      );
    } else if (avatarUrl.isNotEmpty &&
        (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'))) {
      imageWidget = Image.network(
        avatarUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/dummy_boy.jpg',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    } else if (avatarUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        avatarUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.asset(
        'assets/images/dummy_boy.jpg',
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(1.5),
        child: ClipOval(child: imageWidget),
      ),
    );
  }

  Widget _buildSectionTitle(String title, [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: const Color(0xFF64748B)),
            const SizedBox(width: 6),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              items[i],
              if (i < items.length - 1)
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 64,
                  endIndent: 16,
                  color: Color(0xFFF1F5F9),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
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
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Log Out',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of Travel Buddy Finder?',
          style: TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            style:
                TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
            child: const Text('Cancel',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (!context.mounted) return;
      context.read<ProfileProvider>().clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  void _showEmailDialog(BuildContext context) {
    final controller = TextEditingController(text: _email);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.mail_outline_rounded,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Update Email',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the email address you would like to use for notifications and sign-in.',
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'Enter new email',
                  hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: Color(0xFF64748B), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.error, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!val.contains('@') || !val.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
            ),
            child: const Text('Cancel',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() => _email = controller.text.trim());
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text('Email updated to $_email')),
                      ],
                    ),
                    backgroundColor: const Color(0xFF0F172A),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Changes',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showNotificationSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setModalState) {
          return _buildSheetWrapper(
            title: 'Notification Settings',
            icon: Icons.notifications_active_outlined,
            children: [
              _buildSwitchTile(
                title: 'Push Notifications',
                subtitle: 'Receive instant alerts on your device',
                value: _pushNotifications,
                onChanged: (val) {
                  setState(() => _pushNotifications = val);
                  setModalState(() {});
                },
              ),
              _buildSwitchTile(
                title: 'Email Alerts',
                subtitle: 'Get summary emails, digest, and platform updates',
                value: _emailAlerts,
                onChanged: (val) {
                  setState(() => _emailAlerts = val);
                  setModalState(() {});
                },
              ),
              _buildSwitchTile(
                title: 'Trip Request Alerts',
                subtitle: 'Notify immediately when someone requests your trip',
                value: _tripRequestAlerts,
                onChanged: (val) {
                  setState(() => _tripRequestAlerts = val);
                  setModalState(() {});
                },
              ),
              _buildSwitchTile(
                title: 'Promotions & Offers',
                subtitle: 'Receive curated deals, travel tips, and seasonal ideas',
                value: _promoAlerts,
                onChanged: (val) {
                  setState(() => _promoAlerts = val);
                  setModalState(() {});
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPrivacySettingsSheet(BuildContext context) {
    final visibilityOptions = [
      {'title': 'Public', 'desc': 'Anyone can see your profile and trips'},
      {'title': 'Friends Only', 'desc': 'Only approved buddies can view your profile'},
      {'title': 'Private', 'desc': 'Only you can see your profile activity'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setModalState) {
          return _buildSheetWrapper(
            title: 'Privacy Settings',
            icon: Icons.shield_outlined,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Profile Visibility',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              ...visibilityOptions.map((opt) {
                final isSelected = _profileVisibility == opt['title'];
                return InkWell(
                  onTap: () {
                    setState(() => _profileVisibility = opt['title']!);
                    setModalState(() {});
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.05)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFF1F5F9),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt['title']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                opt['desc']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : const Color(0xFFCBD5E1),
                              width: 2,
                            ),
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  size: 13, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10, top: 6),
                child: Text(
                  'Discovery & Interaction',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              _buildSwitchTile(
                title: 'Show Location',
                subtitle: 'Allow travelers to see your city on your profile',
                value: _showLocation,
                onChanged: (val) {
                  setState(() => _showLocation = val);
                  setModalState(() {});
                },
              ),
              _buildSwitchTile(
                title: 'Allow Direct Messages',
                subtitle:
                    'Receive direct messages from travelers who are not buddies',
                value: _allowMessages,
                onChanged: (val) {
                  setState(() => _allowMessages = val);
                  setModalState(() {});
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLanguageRegionSheet(BuildContext context) {
    final languages = [
      'English',
      'Bengali (বাংলা)',
      'Spanish (Español)',
      'French (Français)',
      'German (Deutsch)'
    ];
    final currencies = [
      'USD (\$)',
      'BDT (৳)',
      'EUR (€)',
      'GBP (£)',
      'INR (₹)'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setModalState) {
          return _buildSheetWrapper(
            title: 'Language & Region',
            icon: Icons.language_rounded,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'App Language',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B)),
                    value: languages.contains(_language)
                        ? _language
                        : languages.first,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    items: languages.map((l) {
                      return DropdownMenuItem(
                        value: l,
                        child: Row(
                          children: [
                            const Icon(Icons.translate_rounded,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(l),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _language = val);
                        setModalState(() {});
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Preferred Currency',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B)),
                    value: currencies.contains(_currency)
                        ? _currency
                        : currencies.first,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    items: currencies.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            const Icon(Icons.payments_outlined,
                                size: 18, color: Color(0xFF10B981)),
                            const SizedBox(width: 10),
                            Text(c),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _currency = val);
                        setModalState(() {});
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          );
        },
      ),
    );
  }

  void _showHelpSupportSheet(BuildContext context) {
    final faqs = [
      {
        'q': 'How do I create a new trip?',
        'a':
            'Tap the "+" icon in the bottom navigation bar or header. Fill in your destination, travel dates, estimated budget, description, and cover photo, then tap "Post Trip".',
      },
      {
        'q': 'How do trip join requests work?',
        'a':
            'When browsing trips, tap "Request to Join" on any trip you want to be a part of. The trip host will receive your request and can accept or decline. Once accepted, you can chat in the group!',
      },
      {
        'q': 'Is my personal data secure?',
        'a':
            'Yes, your sensitive information is encrypted. You can also customize your profile visibility and discovery permissions anytime from Privacy Settings.',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _buildSheetWrapper(
        title: 'Help & Support',
        icon: Icons.help_outline_rounded,
        children: [
          ...faqs.map((faq) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 2),
                  childrenPadding:
                      const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  leading: const Icon(Icons.help_center_outlined,
                      color: AppColors.primary, size: 20),
                  title: Text(
                    faq['q']!,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  children: [
                    Text(
                      faq['a']!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(sheetCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.support_agent_rounded,
                          color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                          child:
                              Text('Support team: support@travelbuddy.com')),
                    ],
                  ),
                  backgroundColor: const Color(0xFF0F172A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            icon: const Icon(Icons.mail_outline_rounded,
                color: Colors.white, size: 18),
            label: const Text(
              'Contact Support Team',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _buildSheetWrapper(
        title: 'About App',
        icon: Icons.info_outline_rounded,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.flight_takeoff_rounded,
                        size: 32, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Travel Buddy Finder',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Version 1.0.0 (Build 100)',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Connect with passionate travelers, find companion buddies for your next adventure, explore incredible destinations, and make unforgettable memories together.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              'Terms of Service',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            content: const SingleChildScrollView(
                              child: Text(
                                'By using Travel Buddy Finder, you agree to respect fellow travelers, maintain accurate profile details, adhere to local safety guidelines, and promote positive community standards.',
                                style: TextStyle(
                                    fontSize: 13.5,
                                    height: 1.5,
                                    color: Color(0xFF475569)),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                child: const Text('Close',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary),
                      child: const Text('Terms of Service',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    const Text('•',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              'Privacy Policy',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            content: const SingleChildScrollView(
                              child: Text(
                                'We respect your privacy. Your personal information, travel plans, and sensitive credentials are protected and never sold or shared with third parties without your explicit consent.',
                                style: TextStyle(
                                    fontSize: 13.5,
                                    height: 1.5,
                                    color: Color(0xFF475569)),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                child: const Text('Close',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary),
                      child: const Text('Privacy Policy',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
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

  Widget _buildSheetWrapper({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 24,
                offset: Offset(0, -4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(
                    height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
