import 'package:travel_buddy_finder/core/constants/url.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => AppUrl.baseUrl;

  static String get baseImageUrl => AppUrl.baseImageUrl;

  static String resolveImageUrl(String? path) => AppUrl.resolveImageUrl(path);
}
