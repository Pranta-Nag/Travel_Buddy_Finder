import 'dart:typed_data';
import 'package:travel_buddy_finder/core/constants/url.dart';
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

  Trip toTrip({Uint8List? localBytes}) {
    return Trip(
      id: id.toString(),
      title: title,
      location: location,
      price: '\$$price',
      rating: rating,
      hostName: hostName,
      username: '@${hostName.toLowerCase().replaceAll(' ', '')}',
      imageUrl: fullImageUrl,
      avatarUrl: fullHostAvatar,
      category: category,
      description: description,
      seatsLeft: seats,
      transportationMethods: transports,
      imageBytes: localBytes,
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
      imageUrl: json['cover_picture_url'] ?? json['cover_picture'] ?? json['cover_photo'] ?? json['image_url'] ?? '',
      hostName: json['host_username'] ?? json['host_name'] ?? json['user_name'] ?? 'Traveler Host',
      hostAvatar: json['host_avatar'] ?? json['user_avatar'] ?? '',
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
