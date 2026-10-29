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
  static const String updateTrip = '/update_trip';
  static const String deleteTrip = '/delete_trip';
  static const String joinTrip = '/join_trip';
  static const String acceptRequest = '/accept_request';
  static const String rejectRequest = '/reject_request';
  static const String respondRequest = '/respond_request';
  static const String pendingRequests = '/pending_requests';

  // Bookmark API Endpoints
  static const String addBookmark = '/add_bookmark';
  static const String removeBookmark = '/remove_bookmark';
  static const String myBookmarks = '/my_bookmarks';

  // Comment & Reply API Endpoints
  static const String addComment = '/add_comment';
  static const String replyComment = '/reply_comment';
  static const String getComments = '/get_comments';

  // Image URL Resolver
  static String get baseImageUrl => baseUrl;

  static String resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    var trimmed = path.trim();

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      if (trimmed.contains('localhost/travel_buddy/uploads/')) {
        trimmed = trimmed.replaceFirst('localhost/travel_buddy/uploads/', 'localhost/travel_buddy/api/uploads/');
      }
      return trimmed;
    }
    if (trimmed.startsWith('assets/')) {
      return trimmed;
    }
    if (trimmed.startsWith('data:image/')) {
      return trimmed;
    }

    var cleanPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    if (cleanPath.isEmpty || cleanPath == 'uploads' || cleanPath == 'uploads/') {
      return '';
    }

    // If it's a bare uploaded filename (e.g. trip_user_123.jpg), ensure it has uploads/ prefix
    if (!cleanPath.startsWith('uploads/') &&
        (cleanPath.endsWith('.jpg') ||
            cleanPath.endsWith('.png') ||
            cleanPath.endsWith('.jpeg') ||
            cleanPath.endsWith('.webp'))) {
      cleanPath = 'uploads/$cleanPath';
    }

    var root = baseUrl;
    while (root.endsWith('/')) {
      root = root.substring(0, root.length - 1);
    }

    return '$root/$cleanPath';
  }
}
