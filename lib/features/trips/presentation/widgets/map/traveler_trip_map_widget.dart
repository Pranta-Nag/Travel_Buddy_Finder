import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_buddy_finder/api/models/trip_map_model.dart';

class TravelerTripMapWidget extends StatelessWidget {
  final TripMapData mapData;

  const TravelerTripMapWidget({super.key, required this.mapData});

  Color getMarkerColor(String label) {
    if (label == 'Trip Start') return Colors.green;
    if (label == 'Destination') return Colors.red;
    return Colors.amber.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter = mapData.waypoints.isNotEmpty
        ? mapData.waypoints.first.toLatLng
        : (mapData.routeCoordinates.isNotEmpty
            ? mapData.routeCoordinates.first
            : const LatLng(23.8103, 90.4125));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.directions_car_outlined, size: 18, color: Color(0xFF15803D)),
                const SizedBox(width: 4),
                Text(
                  '${mapData.distanceKm} km',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF15803D)),
                ),
              ]),
              Row(children: [
                const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF15803D)),
                const SizedBox(width: 4),
                Text(
                  '~${mapData.durationHours} hrs driving',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF15803D)),
                ),
              ]),
              Row(children: [
                const Icon(Icons.pin_drop_outlined, size: 18, color: Color(0xFF15803D)),
                const SizedBox(width: 4),
                Text(
                  '${mapData.waypoints.length} stops',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF15803D)),
                ),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Interactive Free OpenStreetMap
        SizedBox(
          height: 240,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 7.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.travelbuddy.app',
                ),
                if (mapData.routeCoordinates.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: mapData.routeCoordinates,
                        strokeWidth: 4.5,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: mapData.waypoints.map((w) {
                    return Marker(
                      point: w.toLatLng,
                      width: 90,
                      height: 50,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                          Icon(Icons.location_on, color: getMarkerColor(w.label), size: 26),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Stops Vertical Timeline
        if (mapData.waypoints.isNotEmpty) ...[
          const Text('Planned Stops Itinerary:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          ...mapData.waypoints.map((wp) {
            final isStart = wp.label == 'Trip Start';
            final isDest = wp.label == 'Destination';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isStart
                        ? Colors.green
                        : (isDest ? Colors.red : Colors.amber.shade700),
                    child: Text(
                      '${wp.order}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wp.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            wp.label,
                            style: TextStyle(color: Colors.grey.shade800, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
