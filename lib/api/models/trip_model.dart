import 'dart:typed_data';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip.dart';

class TripModel {
  final int id;
  final String title;
  final String location;
  final double price;
  final String startDate;
  final String endDate;
  final String category;
  final String description;
  final String imageUrl;
  final String hostName;
  final String hostAvatar;
  final String hostGender;
  final int seats;
  final String rating;
  final List<String> transports;

  TripModel({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.hostName,
    required this.hostAvatar,
    this.hostGender = 'Male',
    required this.seats,
    this.rating = '4.9',
    this.transports = const ['Flight', 'Bus'],
  });

  String get fullImageUrl => AppUrl.resolveImageUrl(imageUrl);
  String get fullHostAvatar => AppUrl.resolveImageUrl(hostAvatar);

  Trip toTrip({Uint8List? localImageBytes}) {
    final bool isMine = CurrentUser.isCurrentUser(hostName, inputName: hostName) ||
        hostName.trim().isEmpty ||
        hostName == 'Traveler Host';

    String resolvedAvatar = fullHostAvatar;
    if (isMine) {
      if (resolvedAvatar.isEmpty) {
        resolvedAvatar = CurrentUser.avatarUrl;
      }
    } else if (resolvedAvatar.isEmpty) {
      final g = hostGender.toLowerCase();
      resolvedAvatar = (g.contains('fem') || g.contains('girl') || g.contains('woman'))
          ? 'assets/images/dummy_girl.png'
          : 'assets/images/dummy_boy.jpg';
    }

    final String resolvedImage = fullImageUrl.isNotEmpty
        ? fullImageUrl
        : (imageUrl.isNotEmpty
            ? imageUrl
            : 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800');

    return Trip(
      id: id.toString(),
      title: title,
      location: location,
      price: '\$$price',
      rating: rating,
      hostName: hostName,
      username: hostName.startsWith('@')
          ? hostName
          : '@${hostName.toLowerCase().replaceAll(' ', '')}',
      imageUrl: resolvedImage,
      avatarUrl: resolvedAvatar.isNotEmpty
          ? resolvedAvatar
          : (isMine ? CurrentUser.avatarUrl : 'assets/images/dummy_boy.jpg'),
      category: category,
      description: description,
      seatsLeft: seats,
      imageBytes: localImageBytes,
      transportationMethods: transports,
    );
  }

  factory TripModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedTransports = ['Flight', 'Bus'];
    final transportData = json['transport_method'] ?? json['transports'] ?? json['transportation'];
    if (transportData != null) {
      if (transportData is List) {
        parsedTransports = transportData.map((e) => e.toString()).toList();
      } else if (transportData is String) {
        parsedTransports = transportData
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    final rawPrice = json['budget'] ?? json['price'] ?? json['cost'];
    final double parsedPrice = rawPrice != null
        ? (rawPrice is num
            ? rawPrice.toDouble()
            : double.tryParse(rawPrice.toString()) ?? 0.0)
        : 0.0;

    final rawSeats = json['available_seats'] ?? json['total_seats'] ?? json['seats'];
    final int parsedSeats = rawSeats != null
        ? (rawSeats is int
            ? rawSeats
            : int.tryParse(rawSeats.toString()) ?? 4)
        : 4;

    final rawImageUrl = json['cover_picture_url'] ??
        json['cover_picture'] ??
        json['cover_photo'] ??
        json['cover_image'] ??
        json['cover_image_url'] ??
        json['cover_img'] ??
        json['cover'] ??
        json['image_url'] ??
        json['image'] ??
        json['picture_url'] ??
        json['picture'] ??
        json['photo_url'] ??
        json['photo'] ??
        json['trip_image'] ??
        json['trip_picture'] ??
        json['trip_photo'] ??
        json['img'] ??
        json['thumbnail'] ??
        json['file'] ??
        json['media'] ??
        '';

    final rawAvatar = json['host_avatar'] ??
        json['user_avatar'] ??
        json['avatar_url'] ??
        json['avatar'] ??
        json['profile_pic_url'] ??
        json['profile_pic'] ??
        json['profile_image_url'] ??
        json['profile_image'] ??
        json['host_profile_pic'] ??
        json['host_profile_pic_url'] ??
        json['user_profile_pic'] ??
        json['user_profile_pic_url'] ??
        '';

    return TripModel(
      id: json['id'] != null
          ? (json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0)
          : 0,
      title: json['title'] ?? json['trip_title'] ?? 'Trip',
      location: json['destination'] ?? json['location'] ?? json['city'] ?? 'Destination',
      price: parsedPrice,
      startDate: json['start_day'] ?? json['start_date'] ?? json['date'] ?? '',
      endDate: json['end_day'] ?? json['end_date'] ?? '',
      category: json['category'] ?? 'Adventure',
      description: json['description'] ?? '',
      imageUrl: rawImageUrl.toString(),
      hostName: json['host_username'] ?? json['host_name'] ?? json['user_name'] ?? 'Traveler Host',
      hostAvatar: rawAvatar.toString(),
      hostGender: json['host_gender'] ?? json['gender'] ?? 'Male',
      seats: parsedSeats,
      rating: json['rating']?.toString() ?? '4.9',
      transports: parsedTransports.isNotEmpty ? parsedTransports : ['Flight', 'Bus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'destination': location,
      'budget': price,
      'start_day': startDate,
      'end_day': endDate,
      'category': category,
      'description': description,
      'cover_picture_url': imageUrl,
      'host_username': hostName,
      'host_gender': hostGender,
      'available_seats': seats,
      'rating': rating,
      'transport_method': transports.join(','),
    };
  }
}
