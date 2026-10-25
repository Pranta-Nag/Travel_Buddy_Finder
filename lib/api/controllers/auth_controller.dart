import 'dart:convert';
import 'package:travel_buddy_finder/api/models/user_model.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/core/network/api_client.dart';

class AuthController {
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

      var response = await ApiClient.post(AppUrl.login, body: body, isJson: true);

      if (response.statusCode == 400) {
        final formResponse = await ApiClient.post(AppUrl.login, body: body, isJson: false);
        if (formResponse.statusCode == 200 || formResponse.statusCode == 201) {
          response = formResponse;
        }
      }

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
      final Map<String, dynamic> fields = {
        'full_name': fullName,
        'username': username,
        'email': email,
        'password': password,
        'gender': gender,
        'country': country,
        'dob': dob,
      };

      if (profilePicBytes != null && profilePicBytes.isNotEmpty) {
        final rawBase64 = base64Encode(profilePicBytes);
        fields['profile_pic'] = 'data:image/jpeg;base64,$rawBase64';
        fields['profile_pic_base64'] = rawBase64;
      }

      if (nidPicBytes != null && nidPicBytes.isNotEmpty) {
        final rawBase64 = base64Encode(nidPicBytes);
        fields['nid_pic'] = 'data:image/jpeg;base64,$rawBase64';
        fields['nid_pic_base64'] = rawBase64;
      }

      var response = await ApiClient.post(
        AppUrl.registration,
        body: fields,
        isJson: true,
      );

      // Fallback to multipart post if 400 or 404 is returned
      if ((response.statusCode == 400 || response.statusCode == 404) &&
          (profilePicBytes != null || nidPicBytes != null)) {
        final files = <String, List<int>>{};
        if (profilePicBytes != null) files['profile_pic'] = profilePicBytes;
        if (nidPicBytes != null) files['nid_pic'] = nidPicBytes;

        final stringMapFields = fields.map((k, v) => MapEntry(k, v.toString()));
        final multiResponse = await ApiClient.multipartPost(
          AppUrl.registration,
          fields: stringMapFields,
          filesBytes: files,
        );
        if (multiResponse.statusCode == 200 || multiResponse.statusCode == 201) {
          response = multiResponse;
        }
      }

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
    } catch (e) {
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
        AppUrl.forgotPassword,
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
        AppUrl.verifyOtp,
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
      final body = {
        'email': email.trim(),
        'otp': otp.trim(),
        'code': otp.trim(),
        'token': otp.trim(),
        'new_password': newPassword,
        'password': newPassword,
      };

      var response = await ApiClient.post(
        AppUrl.resetPassword,
        body: body,
        isJson: true,
      );

      if (response.statusCode == 400) {
        final formResponse = await ApiClient.post(
          AppUrl.resetPassword,
          body: body,
          isJson: false,
        );
        if (formResponse.statusCode == 200 || formResponse.statusCode == 201) {
          response = formResponse;
        }
      }

      final data = jsonDecode(response.body);
      final message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (data is Map && data['error'] != null)
              ? data['error'].toString()
              : 'Password reset result (${response.statusCode})';

      return (
        success: (response.statusCode == 200 || response.statusCode == 201) &&
            (data is Map && data['status'] == 'success'),
        message: message,
      );
    } catch (e) {
      return (success: false, message: 'Network error resetting password: $e');
    }
  }

  Future<({bool success, String message})> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiClient.post(
        AppUrl.changePassword,
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
      await ApiClient.post(AppUrl.logout);
    } catch (_) {}
    await ApiClient.removeToken();
  }
}
