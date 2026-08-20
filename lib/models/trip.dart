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
}
