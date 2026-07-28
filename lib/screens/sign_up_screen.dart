import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy_finder/screens/add_new_trip_screen.dart';
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

  String? _selectedGender = AppLists.genders.first;
  String? _selectedCountry = AppLists.countries.first;
  bool _agreeTerms = false;
  bool? _usernameAvailable;

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
      SnackBar(content: Text(message)),
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
  }

  Widget fieldLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: AppColors.greyText,
          letterSpacing: .5,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      "Join our Travel Buddy Finder community.",
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Profile Image Picker
                  Center(
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.lightBlue.shade100,
                            backgroundImage: _profileImageBytes != null
                                ? MemoryImage(_profileImageBytes!)
                                : null,
                            child: _profileImageBytes == null
                                ? const Icon(
                                    Icons.person,
                                    size: 45,
                                    color: Colors.grey,
                                  )
                                : null,
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
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  fieldLabel("Full Name"),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: inputDecoration(
                      hint: "Enter your full name",
                    ),
                    validator: (value) => AppValidators.required(
                      value,
                      "Full Name",
                    ),
                  ),
                  const SizedBox(height: 20),
                  fieldLabel("Username"),
                  TextFormField(
                    controller: _usernameController,
                    onChanged: _checkUsername,
                    decoration: inputDecoration(
                      hint: "Choose a unique username",
                      suffixIcon: _usernameAvailable == null
                          ? null
                          : Icon(
                              _usernameAvailable!
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: _usernameAvailable!
                                  ? Colors.green
                                  : Colors.red,
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
                          ? Colors.grey
                          : _usernameAvailable!
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                              decoration: inputDecoration(),
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
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            fieldLabel("Country"),
                            DropdownButtonFormField<String>(
                              value: _selectedCountry,
                              isExpanded: true,
                              decoration: inputDecoration(),
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
                  const SizedBox(height: 20),
                  fieldLabel("NID Card"),
                  OutlinedButton.icon(
                    onPressed: _pickNidImage,
                    icon: const Icon(Icons.badge_outlined),
                    label: Text(
                      _nidImageBytes == null
                          ? "Upload NID Copy"
                          : "Change NID Copy",
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  if (_nidImageBytes != null) ...[
                    const SizedBox(height: 15),
                    Container(
                      height: 180,
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
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  fieldLabel("Date of Birth"),
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: inputDecoration(
                      hint: "Select your birth date",
                      suffixIcon: const Icon(Icons.calendar_month),
                    ),
                    validator: (value) => AppValidators.required(
                      value,
                      "Date of Birth",
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeTerms,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _agreeTerms = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 11),
                          child: Text(
                            "I agree to the Terms & Conditions and Travel Safety Guidelines.",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainNavScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Continue Registration",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}
