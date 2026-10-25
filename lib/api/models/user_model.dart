import 'package:travel_buddy_finder/core/constants/url.dart';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String? gender;
  final String? country;
  final String? dob;
  final String? profilePic;
  final String? nidPic;
  final String level;
  final String rating;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.gender,
    this.country,
    this.dob,
    this.profilePic,
    this.nidPic,
    this.level = 'Traveler',
    this.rating = '5.0',
  });

  String get avatarUrl => AppUrl.resolveImageUrl(profilePic);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] != null
          ? (json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0)
          : 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? '',
      gender: json['gender'],
      country: json['country'],
      dob: json['dob'],
      profilePic: json['profile_pic_url'] ?? json['profile_pic'] ?? json['avatar_url'],
      nidPic: json['nid_pic_url'] ?? json['nid_pic'],
      level: json['level'] ?? 'Traveler',
      rating: json['rating']?.toString() ?? '5.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'gender': gender,
      'country': country,
      'dob': dob,
      'profile_pic': profilePic,
      'nid_pic': nidPic,
      'level': level,
      'rating': rating,
    };
  }
}
