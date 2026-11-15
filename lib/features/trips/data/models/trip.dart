import 'dart:typed_data';
import 'package:travel_buddy_finder/api/models/trip_map_model.dart';

class Trip {
  final String id,
      title,
      location,
      price,
      hostName,
      username,
      imageUrl,
      avatarUrl,
      category,
      description;
  String rating;
  final int ratingCount;
  final int seatsLeft;
  final Uint8List? imageBytes;
  final String? genderPreference;
  final List<String>? transportationMethods;
  final TripMapModel? tripMap;

  Trip({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.rating,
    required this.hostName,
    required this.username,
    required this.imageUrl,
    required this.avatarUrl,
    required this.category,
    required this.description,
    this.ratingCount = 0,
    this.seatsLeft = 2,
    this.imageBytes,
    this.genderPreference,
    this.transportationMethods,
    this.tripMap,
  });

  Trip copyWith({
    String? id,
    String? title,
    String? location,
    String? price,
    String? rating,
    int? ratingCount,
    String? hostName,
    String? username,
    String? imageUrl,
    String? avatarUrl,
    String? category,
    String? description,
    int? seatsLeft,
    Uint8List? imageBytes,
    String? genderPreference,
    List<String>? transportationMethods,
    TripMapModel? tripMap,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      hostName: hostName ?? this.hostName,
      username: username ?? this.username,
      imageUrl: imageUrl ?? this.imageUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      category: category ?? this.category,
      description: description ?? this.description,
      seatsLeft: seatsLeft ?? this.seatsLeft,
      imageBytes: imageBytes ?? this.imageBytes,
      genderPreference: genderPreference ?? this.genderPreference,
      transportationMethods:
          transportationMethods ?? this.transportationMethods,
      tripMap: tripMap ?? this.tripMap,
    );
  }
}
