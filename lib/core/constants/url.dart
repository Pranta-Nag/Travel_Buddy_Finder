class AppUrl {
  AppUrl._();

  // Base API URL
  static const String baseUrl = 'http://localhost/travel_buddy/api';

  // Auth API Endpoints
  static const String login = '/login';
  static const String registration = '/registration';
  static const String forgotPassword = '/forgot_password';
  static const String verifyOtp = '/verify_otp';
  static const String resetPassword = '/reset_password';
  static const String changePassword = '/change_password';
  static const String logout = '/logout';

  // Profile API Endpoints
  static const String profile = '/profile';
  static const String updateProfile = '/update_profile';

  // Chat API Endpoints
  static const String chatRooms = '/chat_rooms';
  static const String startChat = '/start_chat';
  static const String getMessages = '/get_messages';
  static const String sendMessage = '/send_message';

  // Trip API Endpoints
  static const String allTrips = '/all_trips';
  static const String categoryTrips = '/category_trips';
  static const String createTrip = '/create_trip';

  // Image URL Resolver
  static String get baseImageUrl => baseUrl;

  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    // Handle uploads folder location in XAMPP (e.g. htdocs/travel_buddy/uploads vs htdocs/travel_buddy/api/uploads)
    if (cleanPath.startsWith('uploads/') && baseUrl.endsWith('/api')) {
      final parentUrl = baseUrl.substring(0, baseUrl.length - 4);
      return '$parentUrl/$cleanPath';
    }

    return '$baseUrl/$cleanPath';
  }
}
