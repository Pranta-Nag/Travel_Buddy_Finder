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

  static bool isCurrentUser(String? inputUsername, {String? inputName}) {
    if (inputUsername == null && inputName == null) return false;
    final cleanCurrent = username.replaceAll('@', '').trim().toLowerCase();
    final cleanName = name.trim().toLowerCase();
    final cleanActiveUser = (activeUser?.username ?? '').replaceAll('@', '').trim().toLowerCase();
    final cleanActiveFullName = (activeUser?.fullName ?? '').trim().toLowerCase();

    if (inputUsername != null && inputUsername.trim().isNotEmpty) {
      final cleanInput = inputUsername.replaceAll('@', '').trim().toLowerCase();
      if (cleanInput == cleanCurrent ||
          cleanInput == 'you' ||
          (cleanActiveUser.isNotEmpty && cleanInput == cleanActiveUser) ||
          (cleanName.isNotEmpty && cleanInput == cleanName.replaceAll(' ', '')) ||
          (cleanActiveFullName.isNotEmpty && cleanInput == cleanActiveFullName.replaceAll(' ', ''))) {
        return true;
      }
    }

    if (inputName != null && inputName.trim().isNotEmpty) {
      final cleanInputName = inputName.trim().toLowerCase();
      if (cleanInputName == cleanName ||
          cleanInputName == cleanCurrent ||
          (cleanActiveFullName.isNotEmpty && cleanInputName == cleanActiveFullName) ||
          (cleanActiveUser.isNotEmpty && cleanInputName == cleanActiveUser)) {
        return true;
      }
    }

    return false;
  }
}
