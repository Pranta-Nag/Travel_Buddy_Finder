import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';
import 'package:travel_buddy_finder/widgets/input_decoration.dart';
import 'package:travel_buddy_finder/widgets/screen_background.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String username;
  final String avatarUrl;
  final Uint8List? avatarBytes;
  final ValueChanged<Map<String, dynamic>> onProfileUpdated;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.username,
    required this.avatarUrl,
    this.avatarBytes,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _avatarUrlController;
  Uint8List? _avatarBytes;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _usernameController = TextEditingController(text: widget.username);
    _avatarUrlController = TextEditingController(text: widget.avatarUrl);
    _avatarBytes = widget.avatarBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatarImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _avatarBytes = bytes;
        _avatarUrlController.clear();
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'avatarUrl': _avatarUrlController.text.trim(),
        'avatarBytes': _avatarBytes,
      };
      widget.onProfileUpdated(updatedData);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.green.shade600,
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Profile updated successfully",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF374151),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
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
        child: SafeArea(
          child: Center(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 460),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),
                        Center(
                          child: GestureDetector(
                            onTap: _pickAvatarImage,
                            child: Stack(
                              children: [
                                Container(
                                  height: 104,
                                  width: 104,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.fieldColor,
                                    border: Border.all(
                                      color: AppColors.borderColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage: _avatarBytes != null
                                        ? MemoryImage(_avatarBytes!)
                                        : NetworkImage(widget.avatarUrl)
                                            as ImageProvider,
                                    onBackgroundImageError: (_, __) {},
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    height: 34,
                                    width: 34,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.12),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _fieldLabel("FULL NAME"),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: inputDecoration(
                            hint: "Enter your full name",
                            prefixIcon:
                                const Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? "Enter your name"
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        _fieldLabel("USERNAME"),
                        TextFormField(
                          controller: _usernameController,
                          textInputAction: TextInputAction.next,
                          decoration: inputDecoration(
                            hint: "@username",
                            prefixIcon:
                                const Icon(Icons.alternate_email_rounded),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? "Enter username"
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        _fieldLabel("AVATAR URL"),
                        TextFormField(
                          controller: _avatarUrlController,
                          textInputAction: TextInputAction.done,
                          decoration: inputDecoration(
                            hint: "https://example.com/avatar.jpg",
                            prefixIcon: const Icon(Icons.link_outlined),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Paste an image URL or use the camera above to upload.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor:
                                  AppColors.primary.withValues(alpha: 0.25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
