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
  final int totalHostedTrips;
  final int totalJoinedTrips;
  final int pendingRequestsCount;

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
    this.totalHostedTrips = 0,
    this.totalJoinedTrips = 0,
    this.pendingRequestsCount = 0,
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
      totalHostedTrips: json['total_hosted_trips'] != null
          ? (json['total_hosted_trips'] is int
              ? json['total_hosted_trips']
              : int.tryParse(json['total_hosted_trips'].toString()) ?? 0)
          : 0,
      totalJoinedTrips: json['total_joined_trips'] != null
          ? (json['total_joined_trips'] is int
              ? json['total_joined_trips']
              : int.tryParse(json['total_joined_trips'].toString()) ?? 0)
          : 0,
      pendingRequestsCount: json['pending_requests_count'] != null
          ? (json['pending_requests_count'] is int
              ? json['pending_requests_count']
              : int.tryParse(json['pending_requests_count'].toString()) ?? 0)
          : 0,
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
      'total_hosted_trips': totalHostedTrips,
      'total_joined_trips': totalJoinedTrips,
      'pending_requests_count': pendingRequestsCount,
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? gender,
    String? country,
    String? dob,
    String? profilePic,
    String? nidPic,
    String? level,
    String? rating,
    int? totalHostedTrips,
    int? totalJoinedTrips,
    int? pendingRequestsCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      dob: dob ?? this.dob,
      profilePic: profilePic ?? this.profilePic,
      nidPic: nidPic ?? this.nidPic,
      level: level ?? this.level,
      rating: rating ?? this.rating,
      totalHostedTrips: totalHostedTrips ?? this.totalHostedTrips,
      totalJoinedTrips: totalJoinedTrips ?? this.totalJoinedTrips,
      pendingRequestsCount: pendingRequestsCount ?? this.pendingRequestsCount,
    );
  }
}
