import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';
import 'package:travel_buddy_finder/config/validators.dart';
import 'package:travel_buddy_finder/widgets/input_decoration.dart';
import 'package:travel_buddy_finder/widgets/screen_background.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
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
                "Password changed successfully",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }
  }

  String? _passwordRequirementText() {
    final text = _newPasswordController.text;
    if (text.isEmpty) return "At least 6 characters";
    final List<String> hints = [];
    hints.add(
      text.length >= 6 ? "✓ Minimum 6 characters" : "At least 6 characters",
    );
    hints.add(
      RegExp(r'[A-Z]').hasMatch(text)
          ? "✓ 1 uppercase letter"
          : "1 uppercase letter",
    );
    hints.add(
      RegExp(r'[0-9]').hasMatch(text) ? "✓ 1 number" : "1 number",
    );
    return hints.join(" · ");
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    void Function(bool)? onVisibilityToggle,
    String? Function(String?)? validator,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: TextInputAction.next,
      decoration: inputDecoration(
        hint: hint,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          splashRadius: 22,
          tooltip: obscure ? "Show password" : "Hide password",
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFF6B7280),
            size: 21,
          ),
          onPressed: () => onVisibilityToggle?.call(!obscure),
        ),
        helperText: helperText,
      ),
      validator: validator,
      onChanged: (_) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Change Password',
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
                        const SizedBox(height: 8),
                        Center(
                          child: Container(
                            height: 64,
                            width: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              size: 32,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "Reset your password",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Enter your current password and choose a new secure password.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 26),
                        _fieldLabel("CURRENT PASSWORD"),
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          hint: "Enter current password",
                          obscure: _obscureCurrent,
                          onVisibilityToggle: (value) {
                            setState(() => _obscureCurrent = value);
                          },
                          validator: AppValidators.password,
                        ),
                        const SizedBox(height: 20),
                        _fieldLabel("NEW PASSWORD"),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          hint: "Enter new password",
                          obscure: _obscureNew,
                          onVisibilityToggle: (value) {
                            setState(() => _obscureNew = value);
                          },
                          validator: AppValidators.password,
                          helperText: _passwordRequirementText(),
                        ),
                        const SizedBox(height: 20),
                        _fieldLabel("CONFIRM NEW PASSWORD"),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hint: "Re-enter new password",
                          obscure: _obscureConfirm,
                          onVisibilityToggle: (value) {
                            setState(() => _obscureConfirm = value);
                          },
                          validator: (value) => AppValidators.confirmPassword(
                            value,
                            _newPasswordController.text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Make sure your new password is different from your previous password.",
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
                            onPressed: _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: AppColors.primary.withValues(alpha: 0.25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Save Changes",
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
