import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/api/controllers/auth_controller.dart';
import 'package:travel_buddy_finder/api/controllers/profile_controller.dart';
import 'package:travel_buddy_finder/api/models/user_model.dart';
import 'package:travel_buddy_finder/api/providers/bookmark_provider.dart';
import 'package:travel_buddy_finder/api/providers/comment_provider.dart';
import 'package:travel_buddy_finder/core/network/api_client.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';

class AuthProvider with ChangeNotifier {
  final AuthController _authController = AuthController();
  final ProfileController _profileController = ProfileController();

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;

  void _setCurrentUser(UserModel? user) {
    _currentUser = user;
    CurrentUser.activeUser = user;
  }

  void updateUser(UserModel user) {
    _currentUser = user;
    CurrentUser.activeUser = user;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final savedToken = await ApiClient.getToken();
    if (savedToken == null || savedToken.isEmpty) {
      return false;
    }

    _token = savedToken;
    _isLoading = true;
    notifyListeners();

    try {
      final profile = await _profileController.getMyProfile();
      _isLoading = false;

      if (profile != null) {
        _setCurrentUser(profile);
        notifyListeners();
        return true;
      } else {
        await ApiClient.removeToken();
        _token = null;
        _setCurrentUser(null);
        notifyListeners();
        return false;
      }
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<({bool success, String message})> login({
    required String login,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authController.login(login: login, password: password);

    _isLoading = false;
    if (result.success) {
      _token = result.token;
      _setCurrentUser(result.user);
    }
    notifyListeners();

    return (success: result.success, message: result.message);
  }

  Future<({bool success, String message})> register({
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
    _isLoading = true;
    notifyListeners();

    final result = await _authController.register(
      fullName: fullName,
      username: username,
      email: email,
      password: password,
      gender: gender,
      country: country,
      dob: dob,
      profilePicBytes: profilePicBytes,
      nidPicBytes: nidPicBytes,
    );

    _isLoading = false;
    if (result.success) {
      _token = result.token;
      _setCurrentUser(result.user);
    }
    notifyListeners();

    return (success: result.success, message: result.message);
  }

  Future<({bool success, String message})> sendOtp(String email) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authController.forgotPassword(email);

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<({bool success, String message})> verifyOtp({
    required String email,
    required String otp,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authController.verifyOtp(email: email, otp: otp);

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<({bool success, String message})> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authController.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<({bool success, String message})> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authController.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<void> logout() async {
    await _authController.logout();
    _token = null;
    _setCurrentUser(null);
    BookmarkProvider.instance?.clear();
    CommentProvider.instance?.clear();
    notifyListeners();
  }
}
