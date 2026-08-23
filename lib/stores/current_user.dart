class CurrentUser {
  CurrentUser._();

  static const String username = '@yeasin';
  static const String name = 'Md Yeasin khan';
  static const String avatarUrl = 'https://i.postimg.cc/W4FfXNcG/profile.jpg';

  static const List<String> usernames = ['@yeasin', '@you'];

  static bool isCurrentUser(String? username) =>
      username != null && usernames.contains(username);
}
