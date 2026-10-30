import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/auth_provider.dart';
import 'package:travel_buddy_finder/api/providers/profile_provider.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/core/widgets/input_decoration.dart';
import 'package:travel_buddy_finder/core/widgets/screen_background.dart';

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
  late TextEditingController _countryController;
  late TextEditingController _genderController;
  late TextEditingController _dobController;
  Uint8List? _avatarBytes;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final profileUser = context.read<ProfileProvider>().myProfile;
    final authUser = profileUser ?? context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(
        text: authUser?.fullName.isNotEmpty == true ? authUser!.fullName : widget.name);
    _usernameController = TextEditingController(
        text: authUser?.username.isNotEmpty == true ? authUser!.username : widget.username);
    _countryController = TextEditingController(
        text: authUser?.country?.isNotEmpty == true ? authUser!.country! : 'Bangladesh');
    _genderController = TextEditingController(
        text: authUser?.gender?.isNotEmpty == true ? authUser!.gender! : 'Male');
    _dobController = TextEditingController(
        text: authUser?.dob?.isNotEmpty == true ? authUser!.dob! : '2000-01-01');
    _avatarBytes = widget.avatarBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _countryController.dispose();
    _genderController.dispose();
    _dobController.dispose();
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
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileProvider = context.read<ProfileProvider>();
    final result = await profileProvider.updateProfile(
      fullName: _nameController.text.trim(),
      gender: _genderController.text.trim(),
      country: _countryController.text.trim(),
      dob: _dobController.text.trim(),
      profilePicBytes: _avatarBytes,
    );

    if (!mounted) return;

    if (result.success) {
      if (result.user != null) {
        context.read<AuthProvider>().updateUser(result.user!);
      }
      final updatedData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'avatarUrl': profileProvider.myProfile?.avatarUrl ?? widget.avatarUrl,
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
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                result.message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.redAccent,
          content: Text(result.message),
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

  ImageProvider _getAvatarImage(String url, String? gender) {
    if (_avatarBytes != null) {
      return MemoryImage(_avatarBytes!);
    }
    final resolved = AppUrl.resolveImageUrl(url);
    if (resolved.isNotEmpty) {
      if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
        return NetworkImage(resolved);
      }
      if (resolved.startsWith('assets/')) {
        return AssetImage(resolved);
      }
    }
    final g = (gender ?? '').trim().toLowerCase();
    if (g == 'female' || g == 'woman' || g == 'girl') {
      return const AssetImage('assets/images/dummy_girl.png');
    }
    return const AssetImage('assets/images/dummy_boy.jpg');
  }

  @override
  Widget build(BuildContext context) {
    final profileUser = context.watch<ProfileProvider>().myProfile;
    final isLoading = context.watch<ProfileProvider>().isLoading;

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
                                  child: Builder(
                                    builder: (context) {
                                      final editProv = _getAvatarImage(
                                        profileUser?.avatarUrl.isNotEmpty == true
                                            ? profileUser!.avatarUrl
                                            : widget.avatarUrl,
                                        _genderController.text,
                                      );
                                      return CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.grey.shade200,
                                        backgroundImage: editProv,
                                        onBackgroundImageError: (_, __) {},
                                      );
                                    },
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

                        // Full Name
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

                        // Country
                        _fieldLabel("COUNTRY"),
                        TextFormField(
                          controller: _countryController,
                          textInputAction: TextInputAction.next,
                          decoration: inputDecoration(
                            hint: "Country",
                            prefixIcon:
                                const Icon(Icons.public_rounded),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Gender
                        _fieldLabel("GENDER"),
                        DropdownButtonFormField<String>(
                          initialValue: ['Male', 'Female', 'Other'].contains(_genderController.text)
                              ? _genderController.text
                              : 'Male',
                          decoration: inputDecoration(
                            hint: "Select Gender",
                            prefixIcon: const Icon(Icons.wc_rounded),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _genderController.text = val;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 20),

                        // Date of Birth
                        _fieldLabel("DATE OF BIRTH"),
                        TextFormField(
                          controller: _dobController,
                          readOnly: true,
                          onTap: () async {
                            final parts = _dobController.text.trim().split('-');
                            DateTime initialDate = DateTime(2000, 1, 1);
                            if (parts.length == 3) {
                              final y = int.tryParse(parts[0]);
                              final m = int.tryParse(parts[1]);
                              final d = int.tryParse(parts[2]);
                              if (y != null && m != null && d != null) {
                                initialDate = DateTime(y, m, d);
                              }
                            }
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(1930),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _dobController.text =
                                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                          decoration: inputDecoration(
                            hint: "YYYY-MM-DD",
                            prefixIcon: const Icon(Icons.cake_outlined),
                          ),
                        ),

                        const SizedBox(height: 26),

                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _saveProfile,
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
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
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
