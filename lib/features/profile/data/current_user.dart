import 'package:travel_buddy_finder/api/models/user_model.dart';

class CurrentUser {
  CurrentUser._();

  static UserModel? activeUser;

  static String get username =>
      activeUser != null && activeUser!.username.isNotEmpty
          ? '@${activeUser!.username.replaceAll('@', '')}'
          : '@yeasin';

  static String get name =>
      activeUser != null && activeUser!.fullName.isNotEmpty
          ? activeUser!.fullName
          : 'Md Yeasin khan';

  static String get avatarUrl {
    if (activeUser != null && activeUser!.avatarUrl.isNotEmpty) {
      return activeUser!.avatarUrl;
    }
    final g = (activeUser?.gender ?? '').trim().toLowerCase();
    if (g == 'female' || g == 'woman' || g == 'girl') {
      return 'assets/images/dummy_girl.png';
    }
    return 'assets/images/dummy_boy.jpg';
  }

  static List<String> get usernames => [username, '@you'];

  static bool isCurrentUser(String? inputUsername) {
    if (inputUsername == null) return false;
    final cleanInput = inputUsername.replaceAll('@', '').trim().toLowerCase();
    final cleanCurrent = username.replaceAll('@', '').trim().toLowerCase();
    return cleanInput == cleanCurrent || cleanInput == 'you';
  }
}
