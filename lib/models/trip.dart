import 'dart:typed_data';

class Trip {
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
    this.seatsLeft = 2,
    this.imageBytes,
  });

  final String id,
      title,
      location,
      price,
      hostName,
      username,
      imageUrl,
      avatarUrl,
      category;
  String rating;
  final int seatsLeft;
  final Uint8List? imageBytes;
}
