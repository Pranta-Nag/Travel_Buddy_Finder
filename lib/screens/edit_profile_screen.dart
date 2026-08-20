import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';
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
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAvatarImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 58,
                      backgroundImage: _avatarBytes != null
                          ? MemoryImage(_avatarBytes!)
                          : NetworkImage(widget.avatarUrl) as ImageProvider,
                      backgroundColor: Colors.grey.shade200,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildLabel("FULL NAME"),
                TextFormField(
                  controller: _nameController,
                  decoration: inputDecoration(hint: "Enter your full name"),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter your name" : null,
                ),
                const SizedBox(height: 16),
                _buildLabel("USERNAME"),
                TextFormField(
                  controller: _usernameController,
                  decoration: inputDecoration(hint: "@username"),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter username" : null,
                ),
                const SizedBox(height: 16),
                _buildLabel("AVATAR URL"),
                TextFormField(
                  controller: _avatarUrlController,
                  decoration: inputDecoration(hint: "https://example.com/avatar.jpg"),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
