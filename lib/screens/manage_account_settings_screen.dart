import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/screens/change_password_screen.dart';
import 'package:travel_buddy_finder/screens/edit_profile_screen.dart';
import 'package:travel_buddy_finder/screens/login_screen.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';
import 'package:travel_buddy_finder/widgets/screen_background.dart';

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
        centerTitle: true,
      ),
      body: ScreenBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isTabletOrDesktop ? 24 : 16,
                vertical: 12,
              ),
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
                          name: widget.name,
                          username: widget.username,
                          avatarUrl: widget.avatarUrl,
                          avatarBytes: widget.avatarBytes,
                          onProfileUpdated: widget.onProfileUpdated,
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                _buildTile(
                  context,
                  icon: Icons.mail_outline_rounded,
                  title: 'Email Address',
                  subtitle: _email,
                  onTap: () => _showEmailDialog(context),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('PREFERENCES'),
                const SizedBox(height: 10),
                _buildTile(
                  context,
                  icon: Icons.notification_add_outlined,
                  title: 'Notification Settings',
                  subtitle: 'Manage push and email alerts',
                  onTap: () => _showNotificationSettingsSheet(context),
                ),
                _buildTile(
                  context,
                  icon: Icons.visibility_outlined,
                  title: 'Privacy Settings',
                  subtitle:
                      'Control who can see your profile ($_profileVisibility)',
                  onTap: () => _showPrivacySettingsSheet(context),
                ),
                _buildTile(
                  context,
                  icon: Icons.language_outlined,
                  title: 'Language & Region',
                  subtitle: '$_language • $_currency',
                  onTap: () => _showLanguageRegionSheet(context),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('SUPPORT'),
                const SizedBox(height: 10),
                _buildTile(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'FAQs and contact support',
                  onTap: () => _showHelpSupportSheet(context),
                ),
                _buildTile(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  subtitle: 'App version and terms',
                  onTap: () => _showAboutSheet(context),
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
                          content:
                              const Text('Are you sure you want to log out?'),
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
                const SizedBox(height: 24),
              ],
            ),
          ),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
      ),
    );
  }

  void _showEmailDialog(BuildContext context) {
    final controller = TextEditingController(text: _email);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.mail_outline_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Update Email Address', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter new email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Enter email';
              if (!val.contains('@')) return 'Enter valid email';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() => _email = controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Email updated to $_email')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
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
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return _buildSheetWrapper(
            title: 'Notification Settings',
            icon: Icons.notification_add_outlined,
            children: [
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive alerts on your device'),
                value: _pushNotifications,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _pushNotifications = val);
                  setModalState(() {});
                },
              ),
              SwitchListTile(
                title: const Text('Email Alerts'),
                subtitle: const Text('Get summary emails and updates'),
                value: _emailAlerts,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _emailAlerts = val);
                  setModalState(() {});
                },
              ),
              SwitchListTile(
                title: const Text('Trip Request Alerts'),
                subtitle:
                    const Text('Notifications when someone requests your trip'),
                value: _tripRequestAlerts,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _tripRequestAlerts = val);
                  setModalState(() {});
                },
              ),
              SwitchListTile(
                title: const Text('Promotions & Offers'),
                subtitle: const Text('Receive special deals and trip ideas'),
                value: _promoAlerts,
                activeColor: AppColors.primary,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return _buildSheetWrapper(
            title: 'Privacy Settings',
            icon: Icons.visibility_outlined,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Profile Visibility',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              ...['Public', 'Friends Only', 'Private'].map((opt) {
                return RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  groupValue: _profileVisibility,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _profileVisibility = val);
                      setModalState(() {});
                    }
                  },
                );
              }),
              const Divider(),
              SwitchListTile(
                title: const Text('Show Location'),
                subtitle: const Text('Allow travelers to see your city'),
                value: _showLocation,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _showLocation = val);
                  setModalState(() {});
                },
              ),
              SwitchListTile(
                title: const Text('Allow Direct Messages'),
                subtitle: const Text('Receive messages from non-buddies'),
                value: _allowMessages,
                activeColor: AppColors.primary,
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
    final currencies = ['USD (\$)', 'BDT (৳)', 'EUR (€)', 'GBP (£)', 'INR (₹)'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return _buildSheetWrapper(
            title: 'Language & Region',
            icon: Icons.language_outlined,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('App Language',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: languages.contains(_language)
                          ? _language
                          : languages.first,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      items: languages
                          .map((l) =>
                              DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _language = val);
                          setModalState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Preferred Currency',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: currencies.contains(_currency)
                          ? _currency
                          : currencies.first,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      items: currencies
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _currency = val);
                          setModalState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showHelpSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSheetWrapper(
        title: 'Help & Support',
        icon: Icons.help_outline_rounded,
        children: [
          const ExpansionTile(
            title: Text('How do I create a trip?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                    'Tap the "+" FAB button on the bottom bar, fill in trip details such as destination, dates, budget, and cover photo, then tap "Post Trip".'),
              ),
            ],
          ),
          const ExpansionTile(
            title: Text('How do trip requests work?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                    'When you find a trip you like, tap "Request to Join". The trip host will receive your request and can accept or decline it.'),
              ),
            ],
          ),
          const ExpansionTile(
            title: Text('Is my personal data safe?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                    'Yes, we encrypt user credentials and you can customize your privacy settings anytime in Account Settings.'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Contact support: support@travelbuddy.com')),
                  );
                },
                icon: const Icon(Icons.email_outlined, color: Colors.white),
                label: const Text('Contact Support Team',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSheetWrapper(
        title: 'About App',
        icon: Icons.info_outline_rounded,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flight_takeoff_rounded,
                      size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                const Text('Travel Buddy Finder',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Text('Version 1.0.0 (Build 100)',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 16),
                Text(
                  'Connect with passionate travelers, find companion buddies for your next adventure, and explore the world together.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Terms of Service'),
                            content: const SingleChildScrollView(
                              child: Text(
                                  'By using Travel Buddy Finder, you agree to respect fellow travelers, maintain accurate profile details, and adhere to local guidelines during trips.'),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close')),
                            ],
                          ),
                        );
                      },
                      child: const Text('Terms of Service'),
                    ),
                    const Text('•', style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Privacy Policy'),
                            content: const SingleChildScrollView(
                              child: Text(
                                  'We respect your privacy. Your contact details are never shared with third parties without your explicit consent.'),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close')),
                            ],
                          ),
                        );
                      },
                      child: const Text('Privacy Policy'),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(icon, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: children,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
