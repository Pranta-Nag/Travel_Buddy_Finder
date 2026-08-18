import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy_finder/screens/login_screen.dart';
import 'package:travel_buddy_finder/screens/main_nav_screen.dart';
import 'package:travel_buddy_finder/widgets/input_decoration.dart';
import '../utils/app_colors.dart';
import '../utils/app_lists.dart';
import '../utils/validators.dart';
import '../widgets/screen_background.dart';

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

    _dobController.text = DateFormat("dd MMM yyyy").format(pickedDate);
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
          style: const TextStyle(color: AppColors.success),
        ),
        duration: const Duration(seconds: 5),
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

  void _signUp() {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateExtraFields()) return;

    _showMessage("Registration Successful 🎉");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainNavScreen()),
      (route) => false,
    );
  }

  Widget fieldLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
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
                  vertical: 30,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: size.width > 600 ? 480 : size.width,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      28,
                      24,
                      28,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // // Logo
                          // Center(
                          //   child: Container(
                          //     height: 78,
                          //     width: 78,
                          //     decoration: BoxDecoration(
                          //       color: AppColors.primary.withOpacity(0.10),
                          //       shape: BoxShape.circle,
                          //     ),
                          //     child: Icon(
                          //       Icons.account_tree,
                          //       size: 42,
                          //       color: AppColors.primary
                          //     ),
                          //   ),
                          // ),

                          const SizedBox(height: 22),

                          // Title
                          const Text(
                            "Create Account",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            "Join our Travel Buddy Finder community",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Profile Image
                          Center(
                            child: GestureDetector(
                              onTap: _pickProfileImage,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 96,
                                    width: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.fieldColor,
                                      border: Border.all(
                                        color: AppColors.borderColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: _profileImageBytes != null
                                        ? ClipOval(
                                            child: Image.memory(
                                              _profileImageBytes!,
                                              fit: BoxFit.cover,
                                              width: 96,
                                              height: 96,
                                            ),
                                          )
                                        : Icon(
                                            Icons.person_outlined,
                                            size: 44,
                                            color: AppColors.greyText,
                                          ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
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
                          fieldLabel("Full Name"),
                          TextFormField(
                            controller: _fullNameController,
                            textInputAction: TextInputAction.next,
                            decoration: inputDecoration(
                              hint: "Enter your full name",
                              prefixIcon: const Icon(Icons.person_outline_rounded),
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
                              prefixIcon: const Icon(Icons.alternate_email_rounded),
                              suffixIcon: _usernameAvailable == null
                                  ? null
                                  : Icon(
                                      _usernameAvailable!
                                          ? Icons.check_circle_rounded
                                          : Icons.cancel_rounded,
                                      color: _usernameAvailable!
                                          ? Colors.green
                                          : Colors.redAccent,
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
                          Text(
                            _usernameAvailable == null
                                ? "Choose a unique username"
                                : _usernameAvailable!
                                    ? "Username available"
                                    : "Username already exists",
                            style: TextStyle(
                              fontSize: 12,
                              color: _usernameAvailable == null
                                  ? AppColors.greyText
                                  : _usernameAvailable!
                                      ? Colors.green
                                      : Colors.redAccent,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Gender & Country
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    fieldLabel("Gender"),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value: _selectedGender,
                                      decoration: inputDecoration(
                                        prefixIcon: const Icon(Icons.wc_rounded),
                                      ),
                                      items: AppLists.genders
                                          .map(
                                            (gender) => DropdownMenuItem(
                                              value: gender,
                                              child: Text(gender),
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
                                      value: _selectedCountry,
                                      isExpanded: true,
                                      decoration: inputDecoration(
                                        prefixIcon: const Icon(Icons.public_rounded),
                                      ),
                                      items: AppLists.countries
                                          .map(
                                            (country) => DropdownMenuItem(
                                              value: country,
                                              child: Text(country),
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

                          // NID Card
                          fieldLabel("NID Card"),
                          OutlinedButton.icon(
                            onPressed: _pickNidImage,
                            icon: const Icon(
                              Icons.badge_outlined,
                            ),
                            label: Text(
                              _nidImageBytes == null
                                  ? "Upload NID Copy"
                                  : "Change NID Copy",
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          if (_nidImageBytes != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.memory(
                                  _nidImageBytes!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text(
                                        "Error loading image preview",
                                        style: TextStyle(color: Colors.redAccent),
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
                              prefixIcon: const Icon(Icons.calendar_month_outlined),
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
                              prefixIcon: const Icon(Icons.email_outlined),
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
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                splashRadius: 22,
                                tooltip: _obscurePassword
                                    ? "Show password"
                                    : "Hide password",
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF6B7280),
                                  size: 21,
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

                          const SizedBox(height: 20),

                          // Terms Checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _agreeTerms,
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _agreeTerms = value ?? false;
                                  });
                                },
                              ),
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    "I agree to the Terms & Conditions and Travel Safety Guidelines.",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Sign Up Button
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shadowColor:
                                    AppColors.primary.withOpacity(0.25),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "Continue Registration",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13,
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
                                  padding: const EdgeInsets.only(
                                    left: 5,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
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
