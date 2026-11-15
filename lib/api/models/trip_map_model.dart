import 'dart:convert';
import 'package:latlong2/latlong.dart';

class WaypointItem {
  final int order;
  final String name;
  final String label; // e.g. "Trip Start", "Toilet Break", "Breakfast Break", "Destination"
  final double lat;
  final double lon;
  final String color; // "green", "amber", "red", "blue"

  WaypointItem({
    required this.order,
    required this.name,
    required this.label,
    required this.lat,
    required this.lon,
    this.color = 'amber',
  });

  LatLng get toLatLng => LatLng(lat, lon);

  factory WaypointItem.fromJson(Map<String, dynamic> json) {
    return WaypointItem(
      order: (json['order'] as num?)?.toInt() ?? 1,
      name: json['name']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Stop',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      color: json['color']?.toString() ?? 'amber',
    );
  }

  Map<String, dynamic> toJson() => {
        'order': order,
        'name': name,
        'label': label,
        'lat': lat,
        'lon': lon,
        'color': color,
      };
}

class TripMapData {
  final String startLocation;
  final double distanceKm;
  final double durationHours;
  final List<WaypointItem> waypoints;
  final List<LatLng> routeCoordinates;

  TripMapData({
    required this.startLocation,
    required this.distanceKm,
    required this.durationHours,
    required this.waypoints,
    required this.routeCoordinates,
  });

  bool get hasRouteData =>
      waypoints.isNotEmpty ||
      routeCoordinates.isNotEmpty ||
      distanceKm > 0 ||
      durationHours > 0;

  factory TripMapData.fromJson(dynamic json) {
    if (json == null) {
      return TripMapData(
        startLocation: 'Start',
        distanceKm: 0.0,
        durationHours: 0.0,
        waypoints: [],
        routeCoordinates: [],
      );
    }

    Map<String, dynamic> mapObj;
    if (json is String) {
      try {
        final decoded = jsonDecode(json);
        if (decoded is Map<String, dynamic>) {
          mapObj = decoded;
        } else if (decoded is Map) {
          mapObj = Map<String, dynamic>.from(decoded);
        } else {
          return TripMapData(
            startLocation: 'Start',
            distanceKm: 0.0,
            durationHours: 0.0,
            waypoints: [],
            routeCoordinates: [],
          );
        }
      } catch (_) {
        return TripMapData(
          startLocation: 'Start',
          distanceKm: 0.0,
          durationHours: 0.0,
          waypoints: [],
          routeCoordinates: [],
        );
      }
    } else if (json is Map<String, dynamic>) {
      mapObj = json;
    } else if (json is Map) {
      mapObj = Map<String, dynamic>.from(json);
    } else {
      return TripMapData(
        startLocation: 'Start',
        distanceKm: 0.0,
        durationHours: 0.0,
        waypoints: [],
        routeCoordinates: [],
      );
    }

    // Parse waypoints safely
    final rawWps = mapObj['waypoints'] ?? mapObj['waypoints_json'];
    List listWps = [];
    if (rawWps is String) {
      try {
        final decoded = jsonDecode(rawWps);
        if (decoded is List) listWps = decoded;
      } catch (_) {}
    } else if (rawWps is List) {
      listWps = rawWps;
    }

    final wps = listWps
        .whereType<Map>()
        .map((w) => WaypointItem.fromJson(Map<String, dynamic>.from(w)))
        .toList();
    wps.sort((a, b) => a.order.compareTo(b.order));

    // Parse route coordinates: backend returns [[lon, lat], [lon, lat], ...]
    final rawCoords = mapObj['route_coordinates'];
    List listCoords = [];
    if (rawCoords is String) {
      try {
        final decoded = jsonDecode(rawCoords);
        if (decoded is List) listCoords = decoded;
      } catch (_) {}
    } else if (rawCoords is List) {
      listCoords = rawCoords;
    }

    final coords = <LatLng>[];
    for (var item in listCoords) {
      if (item is List && item.length >= 2) {
        final lon = (item[0] as num).toDouble();
        final lat = (item[1] as num).toDouble();
        coords.add(LatLng(lat, lon));
      } else if (item is LatLng) {
        coords.add(item);
      }
    }

    return TripMapData(
      startLocation: mapObj['start_location']?.toString() ?? 'Start',
      distanceKm: (mapObj['distance_km'] as num?)?.toDouble() ??
          (mapObj['distance'] as num?)?.toDouble() ??
          0.0,
      durationHours: (mapObj['duration_hours'] as num?)?.toDouble() ??
          (mapObj['duration'] as num?)?.toDouble() ??
          0.0,
      waypoints: wps,
      routeCoordinates: coords,
    );
  }

  Map<String, dynamic> toJson() => {
        'start_location': startLocation,
        'distance_km': distanceKm,
        'duration_hours': durationHours,
        'waypoints': waypoints.map((w) => w.toJson()).toList(),
        'route_coordinates':
            routeCoordinates.map((c) => [c.longitude, c.latitude]).toList(),
      };
}

// Aliases for complete backwards compatibility
typedef TripMapModel = TripMapData;
typedef WaypointModel = WaypointItem;
