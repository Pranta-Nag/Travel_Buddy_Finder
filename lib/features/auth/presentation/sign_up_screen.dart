import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/auth_provider.dart';
import 'package:travel_buddy_finder/features/auth/presentation/login_screen.dart';
import 'package:travel_buddy_finder/features/navigation/presentation/main_nav_screen.dart';
import 'package:travel_buddy_finder/core/widgets/input_decoration.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/core/constants/app_lists.dart';
import 'package:travel_buddy_finder/core/utils/validators.dart';
import 'package:travel_buddy_finder/core/widgets/screen_background.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  Uint8List? _profileImageBytes;
  Uint8List? _nidImageBytes;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedGender = AppLists.genders.first;
  String? _selectedCountry = AppLists.countries.first;
  bool _agreeTerms = false;
  bool? _usernameAvailable;
  bool _obscurePassword = true;

  Future<({File? file, Uint8List? bytes})?> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return null;

      final bytes = await image.readAsBytes();
      final file = kIsWeb ? null : File(image.path);

      return (file: file, bytes: bytes);
    } catch (e) {
      _showMessage("Failed to select image from gallery.");
      return null;
    }
  }

  Future<void> _pickProfileImage() async {
    final result = await _pickImage();
    if (result == null || !mounted) return;

    setState(() {
      _profileImageBytes = result.bytes;
    });
  }

  Future<void> _pickNidImage() async {
    final result = await _pickImage();
    if (result == null || !mounted) return;

    setState(() {
      _nidImageBytes = result.bytes;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
    );

    if (pickedDate == null || !mounted) return;

    _dobController.text = DateFormat("yyyy-MM-dd").format(pickedDate);
    setState(() {});
  }

  void _checkUsername(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _usernameAvailable = null;
      });
      return;
    }

    setState(() {
      _usernameAvailable = value.trim().toLowerCase() != "taken";
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  bool _validateExtraFields() {
    if (_profileImageBytes == null) {
      _showMessage("Please upload profile picture.");
      return false;
    }

    if (_nidImageBytes == null) {
      _showMessage("Please upload your NID copy.");
      return false;
    }

    if (_usernameAvailable == false) {
      _showMessage("Username already exists.");
      return false;
    }

    if (!_agreeTerms) {
      _showMessage("Please agree to Terms & Conditions.");
      return false;
    }

    return true;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateExtraFields()) return;

    final authProvider = context.read<AuthProvider>();

    final result = await authProvider.register(
      fullName: _fullNameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      gender: _selectedGender ?? 'Other',
      country: _selectedCountry ?? 'Bangladesh',
      dob: _dobController.text.trim(),
      profilePicBytes: _profileImageBytes,
      nidPicBytes: _nidImageBytes,
    );

    if (!mounted) return;

    if (result.success) {
      _showMessage("Registration Successful 🎉");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavScreen()),
        (route) => false,
      );
    } else {
      _showMessage(result.message);
    }
  }

  Widget fieldLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Center(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: size.width > 600 ? 480 : size.width,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.borderColor.withValues(alpha: 0.8),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.07),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // App Branding Badge
                          Center(
                            child: Container(
                              height: 68,
                              width: 68,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryDark],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 34,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Title
                          const Text(
                            "Create Account",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "Join the Travel Buddy Finder community",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Profile Image Picker
                          Center(
                            child: GestureDetector(
                              onTap: _pickProfileImage,
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        height: 98,
                                        width: 98,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.fieldColor,
                                          border: Border.all(
                                            color: AppColors.primary.withValues(alpha: 0.25),
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: _profileImageBytes != null
                                            ? ClipOval(
                                                child: Image.memory(
                                                  _profileImageBytes!,
                                                  fit: BoxFit.cover,
                                                  width: 98,
                                                  height: 98,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.person_outline_rounded,
                                                size: 46,
                                                color: AppColors.greyText,
                                              ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [AppColors.primary, AppColors.primaryDark],
                                            ),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary.withValues(alpha: 0.35),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            size: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _profileImageBytes != null
                                        ? "Change profile photo"
                                        : "Upload profile photo",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Full Name
                          fieldLabel("Full Name"),
                          TextFormField(
                            controller: _fullNameController,
                            textInputAction: TextInputAction.next,
                            decoration: inputDecoration(
                              hint: "Enter your full name",
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                size: 20,
                              ),
                            ),
                            validator: (value) => AppValidators.required(
                              value,
                              "Full Name",
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Username
                          fieldLabel("Username"),
                          TextFormField(
                            controller: _usernameController,
                            onChanged: _checkUsername,
                            textInputAction: TextInputAction.next,
                            decoration: inputDecoration(
                              hint: "Choose a unique username",
                              prefixIcon: const Icon(
                                Icons.alternate_email_rounded,
                                size: 20,
                              ),
                              suffixIcon: _usernameAvailable == null
                                  ? null
                                  : Icon(
                                      _usernameAvailable!
                                          ? Icons.check_circle_rounded
                                          : Icons.cancel_rounded,
                                      color: _usernameAvailable!
                                          ? AppColors.success
                                          : AppColors.error,
                                      size: 20,
                                    ),
                            ),
                            validator: (value) {
                              final error = AppValidators.required(
                                value,
                                "Username",
                              );
                              if (error != null) return error;
                              if (_usernameAvailable == false) {
                                return "Username already taken";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              _usernameAvailable == null
                                  ? "Choose a unique handle without spaces"
                                  : _usernameAvailable!
                                      ? "✓ Username available"
                                      : "✕ Username already taken",
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: _usernameAvailable == null
                                    ? AppColors.textTertiary
                                    : _usernameAvailable!
                                        ? AppColors.success
                                        : AppColors.error,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Gender & Country in Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    fieldLabel("Gender"),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      dropdownColor: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      initialValue: _selectedGender,
                                      decoration: inputDecoration(
                                        prefixIcon: const Icon(
                                          Icons.wc_rounded,
                                          size: 20,
                                        ),
                                      ),
                                      items: AppLists.genders
                                          .map(
                                            (gender) => DropdownMenuItem(
                                              value: gender,
                                              child: Text(
                                                gender,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGender = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    fieldLabel("Country"),
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedCountry,
                                      isExpanded: true,
                                      dropdownColor: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      decoration: inputDecoration(
                                        prefixIcon: const Icon(
                                          Icons.public_rounded,
                                          size: 20,
                                        ),
                                      ),
                                      items: AppLists.countries
                                          .map(
                                            (country) => DropdownMenuItem(
                                              value: country,
                                              child: Text(
                                                country,
                                                style: const TextStyle(fontSize: 14),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCountry = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // NID Document Upload
                          fieldLabel("National ID / Passport Copy"),
                          GestureDetector(
                            onTap: _pickNidImage,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.fieldColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _nidImageBytes != null
                                      ? AppColors.success
                                      : AppColors.borderColor,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: _nidImageBytes != null
                                          ? AppColors.success.withValues(alpha: 0.12)
                                          : AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _nidImageBytes != null
                                          ? Icons.check_circle_rounded
                                          : Icons.badge_outlined,
                                      color: _nidImageBytes != null
                                          ? AppColors.success
                                          : AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _nidImageBytes == null
                                              ? "Upload NID Copy"
                                              : "NID Document Attached",
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: _nidImageBytes != null
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _nidImageBytes == null
                                              ? "JPG or PNG file for verification"
                                              : "Tap to change image",
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    _nidImageBytes == null
                                        ? Icons.file_upload_outlined
                                        : Icons.swap_horiz_rounded,
                                    color: _nidImageBytes != null
                                        ? AppColors.success
                                        : AppColors.primary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_nidImageBytes != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.borderColor),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.memory(
                                  _nidImageBytes!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text(
                                        "Error loading image preview",
                                        style: TextStyle(color: AppColors.error),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Date of Birth
                          fieldLabel("Date of Birth"),
                          TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            onTap: _selectDate,
                            textInputAction: TextInputAction.next,
                            decoration: inputDecoration(
                              hint: "Select your birth date",
                              prefixIcon: const Icon(
                                Icons.calendar_month_outlined,
                                size: 20,
                              ),
                            ),
                            validator: (value) => AppValidators.required(
                              value,
                              "Date of Birth",
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Email
                          fieldLabel("Email"),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: inputDecoration(
                              hint: "Enter your email",
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                size: 20,
                              ),
                            ),
                            validator: AppValidators.email,
                          ),

                          const SizedBox(height: 16),

                          // Password
                          fieldLabel("Password"),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            decoration: inputDecoration(
                              hint: "Enter your password",
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                splashRadius: 20,
                                tooltip: _obscurePassword
                                    ? "Show password"
                                    : "Hide password",
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.greyText,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: AppValidators.password,
                          ),

                          const SizedBox(height: 16),

                          // Terms Checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _agreeTerms,
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeTerms = value ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  "I agree to the Terms & Conditions and Travel Safety Guidelines.",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // Sign Up CTA Button
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                colors: isLoading
                                    ? [
                                        AppColors.primary.withValues(alpha: 0.65),
                                        AppColors.primaryDark.withValues(alpha: 0.65),
                                      ]
                                    : [
                                        AppColors.primary,
                                        AppColors.primaryDark,
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: isLoading
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.32),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                            ),
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                disabledBackgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Create Account",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.only(left: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
