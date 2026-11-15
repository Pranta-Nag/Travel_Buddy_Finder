import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:travel_buddy_finder/api/models/trip_map_model.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/core/services/location_service.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip.dart';

class TripRouteItineraryCard extends StatelessWidget {
  final Trip trip;

  const TripRouteItineraryCard({
    super.key,
    required this.trip,
  });

  Color _resolveWaypointColor(String colorStr, int index, int total) {
    final c = colorStr.toLowerCase();
    if (c == 'green' || index == 0) return const Color(0xFF10B981);
    if (c == 'red' || index == total - 1) return const Color(0xFFEF4444);
    if (c == 'amber' || c == 'yellow' || c == 'orange') return const Color(0xFFF59E0B);
    if (c == 'blue') return const Color(0xFF3B82F6);
    if (c == 'purple') return const Color(0xFF8B5CF6);
    return const Color(0xFF64748B);
  }

  Future<void> _openFullHighwayRoute(TripMapModel map) async {
    try {
      final start = Uri.encodeComponent(map.startLocation.isNotEmpty ? map.startLocation : 'Dhaka');
      final dest = Uri.encodeComponent(trip.location);

      String urlStr;
      if (map.waypoints.isNotEmpty) {
        // Collect intermediate waypoints (excluding start and end)
        final intermediate = map.waypoints
            .where((w) => w.order > 1 && w.order < map.waypoints.length)
            .map((w) => '${w.lat},${w.lon}')
            .join('|');

        if (intermediate.isNotEmpty) {
          urlStr = 'https://www.google.com/maps/dir/?api=1&origin=$start&destination=$dest&waypoints=${Uri.encodeComponent(intermediate)}&travelmode=driving';
        } else {
          urlStr = 'https://www.google.com/maps/dir/?api=1&origin=$start&destination=$dest&travelmode=driving';
        }
      } else {
        urlStr = 'https://www.google.com/maps/dir/?api=1&origin=$start&destination=$dest&travelmode=driving';
      }

      final uri = Uri.parse(urlStr);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Failed to open highway route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final map = trip.tripMap;
    final hasRoute = map != null && map.hasRouteData;
    final waypoints = map?.waypoints ?? [];
    final startLocation = map?.startLocation ?? 'Dhaka';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.alt_route_rounded, color: AppColors.primary, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Highway Itinerary & Route",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              if (map?.distanceKm != null || map?.durationHours != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    [
                      if (map?.distanceKm != null) '${map!.distanceKm.toStringAsFixed(0)} km',
                      if (map?.durationHours != null) '~${map!.durationHours.toStringAsFixed(1)} hrs',
                    ].join(' • '),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Route overview badge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.trip_origin_rounded, size: 16, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "From $startLocation",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF334155),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 8),
                const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFEF4444)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    trip.location,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Live OpenStreetMap Interactive Map
          if (hasRoute) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: waypoints.isNotEmpty
                        ? waypoints.first.toLatLng
                        : (map.routeCoordinates.isNotEmpty
                            ? map.routeCoordinates.first
                            : const LatLng(23.8103, 90.4125)),
                    initialZoom: 7.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.travelbuddy.app',
                    ),
                    if (map.routeCoordinates.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: map.routeCoordinates,
                            strokeWidth: 4.5,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: waypoints.map((w) {
                        final markerColor = _resolveWaypointColor(w.color, w.order - 1, waypoints.length);
                        return Marker(
                          point: w.toLatLng,
                          width: 80,
                          height: 52,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  w.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.location_on,
                                color: markerColor,
                                size: 24,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Waypoints Stepper / Timeline
          if (waypoints.isNotEmpty) ...[
            const Text(
              "Planned Highway Stops & Checkpoints",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: waypoints.length,
              itemBuilder: (context, index) {
                final wp = waypoints[index];
                final isLast = index == waypoints.length - 1;
                final dotColor = _resolveWaypointColor(wp.color, index, waypoints.length);

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline indicator
                      SizedBox(
                        width: 32,
                        child: Column(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: dotColor.withValues(alpha: 0.35),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: const Color(0xFFCBD5E1),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Waypoint info
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 4 : 16),
                          child: InkWell(
                            onTap: () {
                              LocationService.openMapForLocation(
                                context,
                                location: '${wp.lat},${wp.lon}',
                                tripTitle: '${wp.name} (${wp.label})',
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          wp.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: dotColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          wp.label,
                                          style: TextStyle(
                                            color: dotColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Tap to view point (${wp.lat.toStringAsFixed(4)}, ${wp.lon.toStringAsFixed(4)})",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (map != null && hasRoute) {
                      _openFullHighwayRoute(map);
                    } else {
                      LocationService.openDirectionsFromCurrentLocation(
                        context,
                        destination: trip.location,
                      );
                    }
                  },
                  icon: const Icon(Icons.navigation_rounded, size: 16, color: Colors.white),
                  label: Text(
                    hasRoute ? "Full Highway Route" : "Get Directions",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  LocationService.showLocationOptionsSheet(
                    context,
                    location: trip.location,
                    tripTitle: trip.title,
                  );
                },
                icon: const Icon(Icons.map_outlined, size: 16, color: AppColors.primary),
                label: const Text(
                  "Map Options",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
