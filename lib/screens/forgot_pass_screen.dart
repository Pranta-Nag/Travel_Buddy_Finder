import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_buddy_finder/screens/main_nav_screen.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';
import 'package:travel_buddy_finder/utils/validators.dart';
import 'package:travel_buddy_finder/widgets/input_decoration.dart';
import 'package:travel_buddy_finder/widgets/screen_background.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool otpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        otpSent = true;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP sent successfully")),
      );
    }
  }

  void _verifyOtp() {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid 6 digit OTP")),
      );
      return;
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_reset,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Forgot Password",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!otpSent) ...[
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: AppValidators.email,
                        decoration: inputDecoration(
                          hint: "Enter your email",
                          suffixIcon: const Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              )),
                          onPressed: _sendOtp,
                          child: const Text(
                            "Send OTP",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                    if (otpSent) ...[
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        maxLength: 6,
                        decoration: inputDecoration(
                          hint: "Enter OTP",
                          suffixIcon: const Icon(Icons.password),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _verifyOtp,
                          child: const Text("Verify OTP"),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
