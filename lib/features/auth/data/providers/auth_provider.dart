import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/features/auth/data/models/user_model.dart';
import 'package:travel_buddy_finder/features/auth/data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;

  Future<({bool success, String message})> login({
    required String login,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(login: login, password: password);

    _isLoading = false;
    if (result.success) {
      _token = result.token;
      _currentUser = result.user;
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

    final result = await _authService.register(
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
      _currentUser = result.user;
    }
    notifyListeners();

    return (success: result.success, message: result.message);
  }

  Future<({bool success, String message})> sendOtp(String email) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.forgotPassword(email);

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

    final result = await _authService.verifyOtp(email: email, otp: otp);

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

    final result = await _authService.resetPassword(
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

    final result = await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    _currentUser = null;
    notifyListeners();
  }
}
