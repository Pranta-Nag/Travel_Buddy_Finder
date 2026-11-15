import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationSearchResult {
  final String displayName;
  final double lat;
  final double lon;

  LocationSearchResult({
    required this.displayName,
    required this.lat,
    required this.lon,
  });
}

class MapRoutingService {
  MapRoutingService._();

  // Known preset hubs for instant search & offline / rate-limit resilience
  static final List<LocationSearchResult> _commonHubs = [
    LocationSearchResult(
      displayName: 'Dhaka, Bangladesh',
      lat: 23.8103,
      lon: 90.4125,
    ),
    LocationSearchResult(
      displayName: 'Dhaka Arambagh Bus Counter, Dhaka',
      lat: 23.7315,
      lon: 90.4182,
    ),
    LocationSearchResult(
      displayName: 'Dhaka Mohakhali Bus Terminal, Dhaka',
      lat: 23.7776,
      lon: 90.4035,
    ),
    LocationSearchResult(
      displayName: 'Dhaka Sayedabad Bus Terminal, Dhaka',
      lat: 23.7145,
      lon: 90.4285,
    ),
    LocationSearchResult(
      displayName: 'Cumilla (Comilla), Chittagong Division, Bangladesh',
      lat: 23.4609,
      lon: 91.1812,
    ),
    LocationSearchResult(
      displayName: 'Cumilla Shahjahan Hotel, Highway, Cumilla',
      lat: 23.4607,
      lon: 91.1809,
    ),
    LocationSearchResult(
      displayName: 'Feni Highway, Feni, Bangladesh',
      lat: 23.0159,
      lon: 91.3976,
    ),
    LocationSearchResult(
      displayName: 'Chittagong (Chattogram), Bangladesh',
      lat: 22.3569,
      lon: 91.7832,
    ),
    LocationSearchResult(
      displayName: 'Chittagong Dampara Bus Counter, Chattogram',
      lat: 22.3582,
      lon: 91.8217,
    ),
    LocationSearchResult(
      displayName: 'Cox\'s Bazar (Kolatoli Beach), Bangladesh',
      lat: 21.4272,
      lon: 91.9701,
    ),
    LocationSearchResult(
      displayName: 'Cox\'s Bazar Sugandha Beach Point, Cox\'s Bazar',
      lat: 21.4334,
      lon: 91.9723,
    ),
    LocationSearchResult(
      displayName: 'Sylhet City, Sylhet Division, Bangladesh',
      lat: 24.8949,
      lon: 91.8687,
    ),
    LocationSearchResult(
      displayName: 'Ratargul Swamp Forest, Sylhet',
      lat: 25.0062,
      lon: 91.9324,
    ),
    LocationSearchResult(
      displayName: 'Jaflong Zero Point, Sylhet',
      lat: 25.1634,
      lon: 92.0194,
    ),
    LocationSearchResult(
      displayName: 'Sreemangal Tea Gardens, Moulvibazar',
      lat: 24.3065,
      lon: 91.7296,
    ),
    LocationSearchResult(
      displayName: 'Brahmanbaria, Bangladesh',
      lat: 23.9608,
      lon: 91.1115,
    ),
    LocationSearchResult(
      displayName: 'Bogura (Bogra), Rajshahi Division',
      lat: 24.8465,
      lon: 89.3777,
    ),
    LocationSearchResult(
      displayName: 'Rajshahi City, Bangladesh',
      lat: 24.3745,
      lon: 88.6042,
    ),
    LocationSearchResult(
      displayName: 'Khulna City, Bangladesh',
      lat: 22.8456,
      lon: 89.5403,
    ),
    LocationSearchResult(
      displayName: 'Barishal (Barisal), Bangladesh',
      lat: 22.7010,
      lon: 90.3535,
    ),
    LocationSearchResult(
      displayName: 'Rangpur City, Bangladesh',
      lat: 25.7439,
      lon: 89.2752,
    ),
    LocationSearchResult(
      displayName: 'Mymensingh City, Bangladesh',
      lat: 24.7471,
      lon: 90.4203,
    ),
    LocationSearchResult(
      displayName: 'Gazipur Chourasta, Gazipur',
      lat: 23.9999,
      lon: 90.4203,
    ),
  ];

  /// Checks if a string contains explicit numeric coordinates like "23.4607, 91.1809"
  static ({double lat, double lon})? parseCoordinates(String input) {
    final cleaned = input.trim();
    final regExp = RegExp(r'(?:^|[^\d.-])([-+]?\d+(?:\.\d+)?)[,\s]+([-+]?\d+(?:\.\d+)?)(?:[^\d.-]|$)');
    final match = regExp.firstMatch(cleaned);
    if (match != null) {
      final lat = double.tryParse(match.group(1) ?? '');
      final lon = double.tryParse(match.group(2) ?? '');
      if (lat != null && lon != null && lat >= -90.0 && lat <= 90.0 && lon >= -180.0 && lon <= 180.0) {
        return (lat: lat, lon: lon);
      }
    }
    return null;
  }

  /// 1. Free OpenStreetMap Nominatim Search with Smart Hub Match & Coordinate Parsing
  static Future<List<LocationSearchResult>> searchLocation(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    // Check if input is directly latitude, longitude
    final directCoords = parseCoordinates(trimmed);
    if (directCoords != null) {
      return [
        LocationSearchResult(
          displayName: 'Coordinates: ${directCoords.lat.toStringAsFixed(4)}, ${directCoords.lon.toStringAsFixed(4)}',
          lat: directCoords.lat,
          lon: directCoords.lon,
        ),
      ];
    }

    final lower = trimmed.toLowerCase();
    final List<LocationSearchResult> results = [];

    // 1. Check local prominent hubs (handles Cumilla / Comilla, Chittagong / Chattogram immediately!)
    for (final hub in _commonHubs) {
      final hubLower = hub.displayName.toLowerCase();
      if (hubLower.contains(lower) ||
          (lower.contains('cumilla') && hubLower.contains('cumilla')) ||
          (lower.contains('comilla') && hubLower.contains('comilla')) ||
          (lower.contains('chittagong') && hubLower.contains('chittagong')) ||
          (lower.contains('chattogram') && hubLower.contains('chattogram')) ||
          (lower.contains('cox') && hubLower.contains('cox')) ||
          (lower.contains('sylhet') && hubLower.contains('sylhet'))) {
        results.add(hub);
      }
    }

    // 2. Query OpenStreetMap Nominatim API
    try {
      String queryParam = trimmed;
      // If query is just a single word without country, append Bangladesh for better relevance
      if (!lower.contains('bangladesh') && !trimmed.contains(',')) {
        queryParam = '$trimmed, Bangladesh';
      }

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(queryParam)}&format=json&limit=5&addressdetails=1',
      );

      final response = await http.get(url, headers: {
        'User-Agent': 'TravelBuddyApp/1.0 (contact: support@travelbuddy.local)',
        'Accept-Language': 'en,bn',
      }).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        for (var item in data) {
          final lat = double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0;
          final lon = double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0;
          final name = item['display_name']?.toString() ?? '';

          // Avoid duplicates with our local preset hubs
          final alreadyPresent = results.any(
            (r) => (r.lat - lat).abs() < 0.001 && (r.lon - lon).abs() < 0.001,
          );
          if (!alreadyPresent && name.isNotEmpty) {
            results.add(LocationSearchResult(
              displayName: name,
              lat: lat,
              lon: lon,
            ));
          }
        }
      } else if (response.statusCode == 429) {
        debugPrint('Nominatim 429 Rate Limit hit. Relying on local hubs.');
      }
    } catch (e) {
      debugPrint('Nominatim search network error: $e');
    }

    // If still empty and query was "Cumilla", fallback specifically to Comilla
    if (results.isEmpty && (lower.contains('cumilla') || lower.contains('comilla'))) {
      results.add(
        LocationSearchResult(
          displayName: 'Cumilla (Comilla), Bangladesh',
          lat: 23.4609,
          lon: 91.1812,
        ),
      );
    }

    return results;
  }

  /// 2. Free OSRM Driving Route Engine (No API Key Required!)
  /// Calculates real highway driving curve polyline, distance in km, and duration in hours
  static Future<Map<String, dynamic>?> fetchHighwayRoute(List<LatLng> stops) async {
    if (stops.length < 2) return null;

    try {
      // OSRM expects coordinates as: {lon1},{lat1};{lon2},{lat2};...
      final coordsParam = stops.map((p) => '${p.longitude},${p.latitude}').join(';');
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$coordsParam?overview=full&geometries=geojson',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final primary = routes[0];
          final distanceMeters = (primary['distance'] as num).toDouble();
          final durationSeconds = (primary['duration'] as num).toDouble();

          final geometry = primary['geometry'] as Map<String, dynamic>;
          final rawCoords = geometry['coordinates'] as List<dynamic>;

          // Convert GeoJSON [lon, lat] to LatLng(lat, lon)
          final polyline = rawCoords.map((c) {
            return LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble());
          }).toList();

          return {
            'distance_km': double.parse((distanceMeters / 1000.0).toStringAsFixed(1)),
            'duration_hours': double.parse((durationSeconds / 3600.0).toStringAsFixed(1)),
            'polyline': polyline,
          };
        }
      }
    } catch (e) {
      debugPrint('OSRM routing error: $e');
    }
    return null;
  }
}
