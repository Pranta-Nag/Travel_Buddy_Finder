import 'dart:convert';
import 'package:travel_buddy_finder/api/models/user_model.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/core/network/api_client.dart';

class ProfileController {
  // 1. GET Logged-in User Profile
  Future<UserModel?> getMyProfile() async {
    try {
      final response = await ApiClient.get(AppUrl.profile);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userJson = data['user'] ?? data['data'];
        if (userJson != null) {
          return UserModel.fromJson(userJson);
        }
      }
    } catch (e) {
      print('Get My Profile Error: $e');
    }
    return null;
  }

  // 2. GET Specific Traveler Profile by Username
  Future<UserModel?> getUserProfile(String username) async {
    try {
      final response = await ApiClient.get('${AppUrl.profile}?username=$username');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userJson = data['user'] ?? data['data'];
        if (userJson != null) {
          return UserModel.fromJson(userJson);
        }
      }
    } catch (e) {
      print('Get User Profile Error: $e');
    }
    return null;
  }

  // 3 & 4. POST Update Profile (Text fields & Base64 / Multipart Profile Pic)
  Future<({bool success, UserModel? user, String message})> updateProfile({
    required String fullName,
    required String gender,
    required String country,
    required String dob,
    List<int>? profilePicBytes,
  }) async {
    try {
      final Map<String, String> fields = {
        'full_name': fullName.trim(),
        'gender': gender.trim(),
        'country': country.trim(),
        'dob': dob.trim(),
      };

      var response = profilePicBytes != null && profilePicBytes.isNotEmpty
          ? await ApiClient.multipartPost(
              AppUrl.updateProfile,
              fields: fields,
              filesBytes: {'profile_pic': profilePicBytes},
            )
          : await ApiClient.post(
              AppUrl.updateProfile,
              body: fields,
              isJson: true,
            );

      final data = jsonDecode(response.body);
      final String message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Profile update completed';

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          (data is Map && data['status'] == 'success')) {
        final userJson = data['user'] ?? data['data'];
        final user = userJson != null ? UserModel.fromJson(userJson) : null;
        return (success: true, user: user, message: message);
      }

      return (success: false, user: null, message: message);
    } catch (e) {
      return (success: false, user: null, message: 'Network error updating profile: $e');
    }
  }
}
