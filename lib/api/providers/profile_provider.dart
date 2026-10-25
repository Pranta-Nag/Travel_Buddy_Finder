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
      if (_myProfile != null) {
        _myProfile = _myProfile!.copyWith(
          id: user.id != 0 ? user.id : _myProfile!.id,
          username: user.username.isNotEmpty ? user.username : _myProfile!.username,
          email: user.email.isNotEmpty ? user.email : _myProfile!.email,
          fullName: user.fullName.isNotEmpty ? user.fullName : _myProfile!.fullName,
          gender: user.gender ?? _myProfile!.gender,
          country: user.country ?? _myProfile!.country,
          dob: user.dob ?? _myProfile!.dob,
          profilePic: user.profilePic ?? _myProfile!.profilePic,
          nidPic: user.nidPic ?? _myProfile!.nidPic,
          level: user.level.isNotEmpty ? user.level : _myProfile!.level,
          rating: user.rating.isNotEmpty ? user.rating : _myProfile!.rating,
          totalHostedTrips: user.totalHostedTrips > 0
              ? user.totalHostedTrips
              : _myProfile!.totalHostedTrips,
          totalJoinedTrips: user.totalJoinedTrips > 0
              ? user.totalJoinedTrips
              : _myProfile!.totalJoinedTrips,
          pendingRequestsCount: user.pendingRequestsCount > 0
              ? user.pendingRequestsCount
              : _myProfile!.pendingRequestsCount,
        );
      } else {
        _myProfile = user;
      }
      CurrentUser.activeUser = _myProfile;
    }
  }

  void clear() {
    _myProfile = null;
    _viewedProfile = null;
    CurrentUser.activeUser = null;
    notifyListeners();
  }

  Future<void> fetchMyProfile({bool silent = false}) async {
    if (!silent && _myProfile == null) {
      _isLoading = true;
      notifyListeners();
    }

    final fetched = await _profileController.getMyProfile();
    if (fetched != null) {
      _setMyProfile(fetched);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<UserModel?> fetchUserProfile(String username) async {
    final cleanUsername = username.replaceAll('@', '').trim();
    if (_viewedProfile?.username != cleanUsername) {
      _viewedProfile = null;
    }
    _isLoading = true;
    notifyListeners();

    _viewedProfile = await _profileController.getUserProfile(cleanUsername);

    _isLoading = false;
    notifyListeners();

    return _viewedProfile;
  }

  Future<({bool success, UserModel? user, String message})> updateProfile({
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

    return (success: result.success, user: _myProfile, message: result.message);
  }
}
