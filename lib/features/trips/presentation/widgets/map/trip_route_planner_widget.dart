import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_buddy_finder/api/models/trip_map_model.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/core/services/map_routing_service.dart';

class TripRoutePlannerWidget extends StatefulWidget {
  final Function(TripMapData) onRouteReady;
  final TripMapData? initialMapData;

  const TripRoutePlannerWidget({
    super.key,
    required this.onRouteReady,
    this.initialMapData,
  });

  @override
  State<TripRoutePlannerWidget> createState() => _TripRoutePlannerWidgetState();
}

class _TripRoutePlannerWidgetState extends State<TripRoutePlannerWidget> {
  final TextEditingController _destinationCtrl = TextEditingController();
  final TextEditingController _labelCtrl = TextEditingController(text: 'Start');
  final MapController _mapController = MapController();

  // Manual Coordinates Controllers
  final TextEditingController _manualLatCtrl = TextEditingController();
  final TextEditingController _manualLonCtrl = TextEditingController();
  final TextEditingController _manualNameCtrl = TextEditingController();
  bool _showManualCoordinates = false;

  Timer? _debounceTimer;
  final List<WaypointItem> _waypoints = [];
  List<LatLng> _routePolyline = [];
  double _distanceKm = 0.0;
  double _durationHours = 0.0;

  bool _isSearching = false;
  bool _isAddingStop = false;
  List<LocationSearchResult> _searchResults = [];
  LocationSearchResult? _selectedSuggestion;
  LatLng? _tappedLocation;

  final List<String> _quickLabelChips = [
    'Start',
    'Toilet break',
    'Breakfast break',
    'Lunch break',
    'Tea & Snack',
    'Scenic spot',
    'Destination',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialMapData != null) {
      _waypoints.addAll(widget.initialMapData!.waypoints);
      _routePolyline = List.from(widget.initialMapData!.routeCoordinates);
      _distanceKm = widget.initialMapData!.distanceKm;
      _durationHours = widget.initialMapData!.durationHours;
      if (_waypoints.isNotEmpty) {
        _labelCtrl.text = 'Toilet break';
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _destinationCtrl.dispose();
    _labelCtrl.dispose();
    _manualLatCtrl.dispose();
    _manualLonCtrl.dispose();
    _manualNameCtrl.dispose();
    super.dispose();
  }

  Color _resolveMarkerColor(String label, int order, int total) {
    final l = label.toLowerCase();
    if (l.contains('start') || order == 1) return const Color(0xFF10B981); // Green
    if (l.contains('dest') || l.contains('final') || (total > 1 && order == total)) {
      return const Color(0xFFEF4444); // Red
    }
    if (l.contains('toilet') || l.contains('washroom') || l.contains('rest')) {
      return const Color(0xFFF59E0B); // Amber
    }
    if (l.contains('breakfast') ||
        l.contains('lunch') ||
        l.contains('dinner') ||
        l.contains('food') ||
        l.contains('tea') ||
        l.contains('snack')) {
      return const Color(0xFFF97316); // Orange
    }
    if (l.contains('view') || l.contains('scenic') || l.contains('photo')) {
      return const Color(0xFF8B5CF6); // Purple
    }
    return const Color(0xFF3B82F6); // Blue
  }

  String _resolveColorName(String label, int order, int total) {
    final l = label.toLowerCase();
    if (l.contains('start') || order == 1) return 'green';
    if (l.contains('dest') || l.contains('final') || (total > 1 && order == total)) return 'red';
    if (l.contains('toilet') || l.contains('washroom') || l.contains('rest')) return 'amber';
    if (l.contains('breakfast') ||
        l.contains('lunch') ||
        l.contains('dinner') ||
        l.contains('food') ||
        l.contains('tea') ||
        l.contains('snack')) {
      return 'orange';
    }
    if (l.contains('view') || l.contains('scenic') || l.contains('photo')) return 'purple';
    return 'blue';
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _executeSearch(query);
    });
  }

  Future<void> _executeSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      if (mounted) {
        setState(() {
          _searchResults.clear();
          _isSearching = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _isSearching = true);
    final results = await MapRoutingService.searchLocation(trimmed);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _applyManualCoordinates() {
    final lat = double.tryParse(_manualLatCtrl.text.trim());
    final lon = double.tryParse(_manualLonCtrl.text.trim());
    final name = _manualNameCtrl.text.trim();

    if (lat == null || lon == null || lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      _showFeedbackSnackBar('Please enter valid Latitude (-90 to 90) and Longitude (-180 to 180)');
      return;
    }

    final placeName = name.isNotEmpty ? name : 'Location (${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)})';

    setState(() {
      _destinationCtrl.text = placeName;
      _selectedSuggestion = LocationSearchResult(
        displayName: placeName,
        lat: lat,
        lon: lon,
      );
      _showManualCoordinates = false;
    });

    _showFeedbackSnackBar('Coordinates applied for $placeName. Tap "Add Stop to Route" below!');
  }

  Future<void> _handleAddStop() async {
    final destinationText = _destinationCtrl.text.trim();
    if (destinationText.isEmpty) {
      _showFeedbackSnackBar('Please enter a destination or stop name');
      return;
    }

    String labelText = _labelCtrl.text.trim();
    if (labelText.isEmpty) {
      labelText = _waypoints.isEmpty
          ? 'Start'
          : (_waypoints.length == 1 ? 'Toilet break' : 'Stop ${_waypoints.length + 1}');
    }

    setState(() => _isAddingStop = true);

    double lat = 0.0;
    double lon = 0.0;
    String stopName = destinationText;

    try {
      // 1. Direct coordinate format in the destination text box (e.g. "23.4607, 91.1809")
      final parsedDirect = MapRoutingService.parseCoordinates(destinationText);

      if (parsedDirect != null) {
        lat = parsedDirect.lat;
        lon = parsedDirect.lon;
        stopName = destinationText;
      } else if (_selectedSuggestion != null &&
          _selectedSuggestion!.displayName.toLowerCase().contains(destinationText.toLowerCase())) {
        lat = _selectedSuggestion!.lat;
        lon = _selectedSuggestion!.lon;
        stopName = _selectedSuggestion!.displayName.split(',').first.trim();
      } else {
        // Query Nominatim on OpenStreetMap or local hub
        final searchResults = await MapRoutingService.searchLocation(destinationText);
        if (searchResults.isNotEmpty) {
          final top = searchResults.first;
          lat = top.lat;
          lon = top.lon;
          stopName = top.displayName.split(',').first.trim();
        } else {
          setState(() => _isAddingStop = false);
          _showFeedbackSnackBar(
            'Could not find "$destinationText" on map. You can also paste direct coordinates (e.g. 23.4607, 91.1809) or tap on the map.',
          );
          return;
        }
      }

      final int nextOrder = _waypoints.length + 1;
      final String colorName = _resolveColorName(labelText, nextOrder, nextOrder);

      final newWaypoint = WaypointItem(
        order: nextOrder,
        name: stopName,
        label: labelText,
        lat: lat,
        lon: lon,
        color: colorName,
      );

      setState(() {
        _waypoints.add(newWaypoint);
        _destinationCtrl.clear();
        _searchResults.clear();
        _selectedSuggestion = null;
        _tappedLocation = null;
      });

      // Recalculate highway route with OSRM
      await _recalculateHighwayRoute();

      // Suggest the next label intelligently
      if (mounted) {
        setState(() {
          if (_waypoints.length == 1) {
            _labelCtrl.text = 'Toilet break';
          } else if (_waypoints.length == 2) {
            _labelCtrl.text = 'Breakfast break';
          } else if (_waypoints.length == 3) {
            _labelCtrl.text = 'Destination';
          }
        });

        // Center map on the newly added waypoint
        try {
          _mapController.move(LatLng(lat, lon), 8.5);
        } catch (_) {}
      }
    } catch (e) {
      _showFeedbackSnackBar('Error adding stop: $e');
    } finally {
      if (mounted) {
        setState(() => _isAddingStop = false);
      }
    }
  }

  Future<void> _recalculateHighwayRoute() async {
    if (_waypoints.length >= 2) {
      final routeRes = await MapRoutingService.fetchHighwayRoute(
        _waypoints.map((w) => w.toLatLng).toList(),
      );

      if (routeRes != null && mounted) {
        setState(() {
          _distanceKm = routeRes['distance_km'];
          _durationHours = routeRes['duration_hours'];
          _routePolyline = routeRes['polyline'] as List<LatLng>;
        });
      }
    } else {
      setState(() {
        _distanceKm = 0.0;
        _durationHours = 0.0;
        _routePolyline.clear();
      });
    }

    _notifyParent();
  }

  void _notifyParent() {
    final mapData = TripMapData(
      startLocation: _waypoints.isNotEmpty ? _waypoints.first.name : 'Start',
      distanceKm: _distanceKm,
      durationHours: _durationHours,
      waypoints: List.from(_waypoints),
      routeCoordinates: List.from(_routePolyline),
    );
    widget.onRouteReady(mapData);
  }

  Future<void> _removeStop(int index) async {
    setState(() {
      _waypoints.removeAt(index);
      for (int i = 0; i < _waypoints.length; i++) {
        final current = _waypoints[i];
        final order = i + 1;
        _waypoints[i] = WaypointItem(
          order: order,
          name: current.name,
          label: current.label,
          lat: current.lat,
          lon: current.lon,
          color: _resolveColorName(current.label, order, _waypoints.length),
        );
      }
    });

    await _recalculateHighwayRoute();
  }

  void _showFeedbackSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng mapCenter = _waypoints.isNotEmpty
        ? _waypoints.last.toLatLng
        : (_tappedLocation ?? const LatLng(23.8103, 90.4125)); // Default Dhaka center

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Subtitle
          const Row(
            children: [
              Icon(Icons.alt_route_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Route Waypoints & Highway Planner',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Type a location (e.g. Cumilla, Dhaka), paste coordinates, or enter lat/lon manually.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          // TEXT BOX 1: Destination / Stop Place
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '1. Destination / Stop Place',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _showManualCoordinates = !_showManualCoordinates;
                  });
                },
                child: Text(
                  _showManualCoordinates ? 'Close Lat/Lon' : '📍 Enter Lat / Lon',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // MANUAL LAT/LON EXPANDABLE SECTION
          if (_showManualCoordinates) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manual Coordinate Input (e.g. Cumilla: 23.4607, 91.1809)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualLatCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: InputDecoration(
                            labelText: 'Latitude (Lat)',
                            hintText: 'e.g. 23.4607',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _manualLonCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: InputDecoration(
                            labelText: 'Longitude (Lon)',
                            hintText: 'e.g. 91.1809',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _manualNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Place Name (Optional)',
                      hintText: 'e.g. Cumilla Highway Rest Stop',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _applyManualCoordinates,
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Apply Custom Coordinates', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          TextField(
            controller: _destinationCtrl,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'e.g. Cumilla, Dhaka Arambagh, or 23.4607, 91.1809',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSearching)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  if (_destinationCtrl.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        _destinationCtrl.clear();
                        setState(() {
                          _searchResults.clear();
                          _selectedSuggestion = null;
                        });
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.search, size: 20, color: AppColors.primary),
                    tooltip: 'Search place',
                    onPressed: () => _executeSearch(_destinationCtrl.text),
                  ),
                ],
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),

          // Autocomplete suggestion dropdown
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(maxHeight: 190),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, idx) {
                  final item = _searchResults[idx];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.pin_drop_rounded, size: 18, color: AppColors.primary),
                    title: Text(
                      item.displayName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '(${item.lat.toStringAsFixed(4)}, ${item.lon.toStringAsFixed(4)})',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedSuggestion = item;
                        _destinationCtrl.text = item.displayName.split(',').first.trim();
                        _searchResults.clear();
                      });
                    },
                  );
                },
              ),
            ),

          const SizedBox(height: 14),

          // TEXT BOX 2: Stop Label
          const Text(
            '2. Stop Label',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _labelCtrl,
            decoration: InputDecoration(
              hintText: 'e.g. Start, Toilet break, Breakfast break, Destination...',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.label_outline_rounded, color: AppColors.primary, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),

          const SizedBox(height: 8),

          // Quick Preset Chips for common labels
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickLabelChips.map((chipText) {
                final isSelected = _labelCtrl.text.trim().toLowerCase() == chipText.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(chipText),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                    ),
                    backgroundColor: isSelected ? AppColors.primary : Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    onPressed: () {
                      setState(() {
                        _labelCtrl.text = chipText;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // ADD STOP BUTTON
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _isAddingStop ? null : _handleAddStop,
              icon: _isAddingStop
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add_location_alt_rounded, size: 18, color: Colors.white),
              label: Text(
                _isAddingStop ? 'Finding Location on Map...' : 'Add Stop to Route',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // STOPS LIST (Waypoints added so far)
          if (_waypoints.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Planned Stops (${_waypoints.length})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Route saved to waypoints',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: _waypoints.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, idx) {
                  final wp = _waypoints[idx];
                  final markerColor = _resolveMarkerColor(wp.label, wp.order, _waypoints.length);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: markerColor,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: markerColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      wp.label,
                                      style: TextStyle(
                                        color: markerColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '(${wp.lat.toStringAsFixed(3)}, ${wp.lon.toStringAsFixed(3)})',
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                          tooltip: 'Remove stop',
                          onPressed: () => _removeStop(idx),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ROUTE METRICS BADGE (Distance & Driving Time)
          if (_waypoints.length >= 2) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.straighten_rounded, size: 16, color: Color(0xFF1E3A8A)),
                      const SizedBox(width: 6),
                      Text(
                        '$_distanceKm km',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF1E3A8A)),
                      const SizedBox(width: 6),
                      Text(
                        '~$_durationHours hrs',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.pin_drop_rounded, size: 16, color: Color(0xFF1E3A8A)),
                      const SizedBox(width: 6),
                      Text(
                        '${_waypoints.length} stops',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Map tap hint
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Interactive OpenStreetMap',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Tip: Tap on map to pin coordinates',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // OPENSTREETMAP INTERACTIVE MAP CANVAS
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: _waypoints.isNotEmpty ? 8.0 : 7.0,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _tappedLocation = point;
                      _destinationCtrl.text = 'Map Pin (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})';
                      _selectedSuggestion = LocationSearchResult(
                        displayName: 'Map Pin Point',
                        lat: point.latitude,
                        lon: point.longitude,
                      );
                    });
                    _showFeedbackSnackBar(
                      'Pinned point (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}). Tap "Add Stop to Route" to add!',
                    );
                  },
                ),
                children: [
                  // Free OpenStreetMap Raster Tile Layer
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.travelbuddy.app',
                  ),

                  // Highway Driving Polyline
                  if (_routePolyline.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePolyline,
                          strokeWidth: 4.5,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ],
                    ),

                  // Waypoint Colored Pins & Labels
                  MarkerLayer(
                    markers: [
                      ..._waypoints.map((w) {
                        final markerColor = _resolveMarkerColor(w.label, w.order, _waypoints.length);
                        return Marker(
                          point: w.toLatLng,
                          width: 95,
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
                                  '${w.order}. ${w.label}',
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
                                size: 26,
                              ),
                            ],
                          ),
                        );
                      }),
                      // Temporary tapped marker pin
                      if (_tappedLocation != null)
                        Marker(
                          point: _tappedLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_searching_rounded,
                            color: Colors.deepPurpleAccent,
                            size: 32,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
