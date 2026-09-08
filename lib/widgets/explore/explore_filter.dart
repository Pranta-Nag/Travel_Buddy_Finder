import 'package:flutter/material.dart';

enum SortOption {
  recommended,
  priceLowToHigh,
  priceHighToLow,
  highestRated,
}

class ExploreFilterData {
  static const String allCategory = "All";

  static const String anyGender = "Any (Everyone is welcome)";

  static const double minBudget = 200;
  static const double maxBudget = 5000;

  static const List<String> categories = [
    "All",
    "Adventure",
    "Beach",
    "Cultural",
    "Romantic",
    "Family",
    "Wildlife",
  ];

  static const List<String> genders = [
    "Any (Everyone is welcome)",
    "Male Only",
    "Female Only",
  ];

  static const List<String> transportationMethods = [
    "Flight",
    "Bullet Train",
    "Road Trip / Carpool",
    "Public Bus",
    "Sailing Boat",
  ];

  static IconData categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'adventure':
        return Icons.hiking_rounded;
      case 'beach':
        return Icons.beach_access_rounded;
      case 'cultural':
        return Icons.museum_rounded;
      case 'romantic':
        return Icons.favorite_rounded;
      case 'family':
        return Icons.family_restroom_rounded;
      case 'wildlife':
        return Icons.pets_rounded;
      default:
        return Icons.explore_rounded;
    }
  }

  static IconData transportIcon(String method) {
    final value = method.toLowerCase();

    if (value.contains('flight')) {
      return Icons.flight_takeoff_rounded;
    }

    if (value.contains('bullet') || value.contains('train')) {
      return Icons.train_rounded;
    }

    if (value.contains('car') || value.contains('road')) {
      return Icons.directions_car_rounded;
    }

    if (value.contains('bus')) {
      return Icons.directions_bus_rounded;
    }

    if (value.contains('boat') || value.contains('sail')) {
      return Icons.directions_boat_rounded;
    }

    return Icons.commute_rounded;
  }
}