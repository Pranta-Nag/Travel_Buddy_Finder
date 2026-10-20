class AppUrl {
  AppUrl._();

  static const String baseUrl = 'http://localhost/travel_buddy/api';

  static String get baseImageUrl => baseUrl;

  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleanPath';
  }
}
