import 'dart:typed_data';

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
  final int seatsLeft;
  final Uint8List? imageBytes;
  final String? genderPreference;
  final List<String>? transportationMethods;

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
    this.seatsLeft = 2,
    this.imageBytes,
    this.genderPreference,
    this.transportationMethods,
  });

  Trip copyWith({
    String? id,
    String? title,
    String? location,
    String? price,
    String? rating,
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
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      price: price ?? this.price,
      rating: rating ?? this.rating,
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
    );
  }
}
