import 'dart:convert';
import 'package:travel_buddy_finder/core/network/api_client.dart';
import 'package:travel_buddy_finder/features/auth/data/models/user_model.dart';

class AuthService {
  Future<({bool success, String? token, UserModel? user, String message})> login({
    required String login,
    required String password,
  }) async {
    try {
      final body = {
        'login': login.trim(),
        'username': login.trim(),
        'email': login.trim(),
        'password': password,
      };

      // Try JSON POST first
      var response = await ApiClient.post('/login', body: body, isJson: true);

      // If PHP expects form-data/x-www-form-urlencoded and returned 400 Bad Request, fallback to form-data
      if (response.statusCode == 400) {
        final formResponse = await ApiClient.post('/login', body: body, isJson: false);
        if (formResponse.statusCode == 200 || formResponse.statusCode == 201) {
          response = formResponse;
        }
      }

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.body.isEmpty) {
        return (
          success: false,
          token: null,
          user: null,
          message: 'Server returned empty response (Status: ${response.statusCode}).',
        );
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return (
          success: false,
          token: null,
          user: null,
          message: 'Server returned non-JSON response (Status: ${response.statusCode}).',
        );
      }

      final String message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (data is Map && data['error'] != null)
              ? data['error'].toString()
              : 'Login failed (Status: ${response.statusCode})';

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          (data is Map && data['status'] == 'success')) {
        final token = data['token'] ?? data['data']?['token'];
        final userJson = data['user'] ?? data['data']?['user'];
        final user = userJson != null ? UserModel.fromJson(userJson) : null;
        if (token != null) {
          await ApiClient.saveToken(token.toString());
        }
        return (
          success: true,
          token: token?.toString(),
          user: user,
          message: message.isNotEmpty ? message : 'Login successful',
        );
      }

      return (
        success: false,
        token: null,
        user: null,
        message: message,
      );
    } catch (e) {
      print('Login Error: $e');
      return (
        success: false,
        token: null,
        user: null,
        message: 'Network error during login: $e',
      );
    }
  }

  Future<({bool success, String? token, UserModel? user, String message})> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String gender,
    required String country,
    required String dob,
    List<int>? profilePicBytes,
    List<int>? nidPicBytes,
  }) async {
    try {
      final fields = {
        'full_name': fullName,
        'username': username,
        'email': email,
        'password': password,
        'gender': gender,
        'country': country,
        'dob': dob,
      };

      final files = <String, List<int>>{};
      if (profilePicBytes != null) files['profile_pic'] = profilePicBytes;
      if (nidPicBytes != null) files['nid_pic'] = nidPicBytes;

      final response = await ApiClient.multipartPost(
        '/registration',
        fields: fields,
        filesBytes: files,
      );

      print('Registration Response Status: ${response.statusCode}');
      print('Registration Response Body: ${response.body}');

      if (response.body.isEmpty) {
        return (
          success: false,
          token: null,
          user: null,
          message: 'Server returned empty response (Status: ${response.statusCode}).',
        );
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return (
          success: false,
          token: null,
          user: null,
          message: 'Server returned non-JSON response (Status: ${response.statusCode}).',
        );
      }

      final String message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (data is Map && data['error'] != null)
              ? data['error'].toString()
              : 'Registration failed (Status: ${response.statusCode})';

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          (data is Map && data['status'] == 'success')) {
        final token = data['token'] ?? data['data']?['token'];
        final userJson = data['user'] ?? data['data']?['user'];
        final user = userJson != null ? UserModel.fromJson(userJson) : null;
        if (token != null) {
          await ApiClient.saveToken(token.toString());
        }
        return (
          success: true,
          token: token?.toString(),
          user: user,
          message: message.isNotEmpty ? message : 'Registration successful',
        );
      }

      return (
        success: false,
        token: null,
        user: null,
        message: message,
      );
    } catch (e, stack) {
      print('Registration Error: $e');
      print('Stacktrace: $stack');
      return (
        success: false,
        token: null,
        user: null,
        message: 'Network error during registration: $e',
      );
    }
  }

  Future<({bool success, String message})> forgotPassword(String email) async {
    try {
      final response = await ApiClient.post(
        '/forgot_password',
        body: {'email': email.trim()},
      );
      final data = jsonDecode(response.body);
      final message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'OTP sent to your email.';
      return (
        success: response.statusCode == 200 && data['status'] == 'success',
        message: message,
      );
    } catch (e) {
      return (success: false, message: 'Network error. Could not send OTP.');
    }
  }

  Future<({bool success, String message})> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await ApiClient.post(
        '/verify_otp',
        body: {
          'email': email.trim(),
          'otp': otp.trim(),
        },
      );
      final data = jsonDecode(response.body);
      final message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'OTP verified successfully.';
      return (
        success: response.statusCode == 200 && data['status'] == 'success',
        message: message,
      );
    } catch (e) {
      return (success: false, message: 'Network error verifying OTP.');
    }
  }

  Future<({bool success, String message})> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await ApiClient.post(
        '/reset_password',
        body: {
          'email': email.trim(),
          'otp': otp.trim(),
          'new_password': newPassword,
        },
      );
      final data = jsonDecode(response.body);
      final message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Password reset successfully.';
      return (
        success: response.statusCode == 200 && data['status'] == 'success',
        message: message,
      );
    } catch (e) {
      return (success: false, message: 'Network error resetting password.');
    }
  }

  Future<({bool success, String message})> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiClient.post(
        '/change_password',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      final data = jsonDecode(response.body);
      final message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Password changed successfully.';
      return (
        success: response.statusCode == 200 && data['status'] == 'success',
        message: message,
      );
    } catch (e) {
      return (success: false, message: 'Network error changing password.');
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.post('/logout');
    } catch (_) {}
    await ApiClient.removeToken();
  }
}
