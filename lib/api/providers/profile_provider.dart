import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/api/controllers/profile_controller.dart';
import 'package:travel_buddy_finder/api/models/user_model.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileController _profileController = ProfileController();

  UserModel? _myProfile;
  UserModel? _viewedProfile;
  bool _isLoading = false;

  UserModel? get myProfile => _myProfile;
  UserModel? get viewedProfile => _viewedProfile;
  bool get isLoading => _isLoading;

  void _setMyProfile(UserModel? user) {
    if (user != null) {
      _myProfile = user;
      CurrentUser.activeUser = user;
    }
  }

  Future<void> fetchMyProfile() async {
    _isLoading = true;
    notifyListeners();

    final fetched = await _profileController.getMyProfile();
    if (fetched != null) {
      _setMyProfile(fetched);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<UserModel?> fetchUserProfile(String username) async {
    _isLoading = true;
    notifyListeners();

    _viewedProfile = await _profileController.getUserProfile(username);

    _isLoading = false;
    notifyListeners();

    return _viewedProfile;
  }

  Future<({bool success, String message})> updateProfile({
    required String fullName,
    required String gender,
    required String country,
    required String dob,
    List<int>? profilePicBytes,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _profileController.updateProfile(
      fullName: fullName,
      gender: gender,
      country: country,
      dob: dob,
      profilePicBytes: profilePicBytes,
    );

    _isLoading = false;
    if (result.success && result.user != null) {
      _setMyProfile(result.user);
    }
    notifyListeners();

    return (success: result.success, message: result.message);
  }
}
