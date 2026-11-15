import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';

class LocationService {
  LocationService._();

  /// Gets the current user GPS location using [Geolocator].
  /// Requests permissions if needed. Returns null if permission is denied
  /// or if location service is disabled.
  static Future<Position?> getCurrentLocation({
    BuildContext? context,
    bool showPermissionAlert = false,
  }) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context != null && context.mounted && showPermissionAlert) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable device location services (GPS).'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context != null && context.mounted && showPermissionAlert) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context != null && context.mounted && showPermissionAlert) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Location permissions are permanently denied. Please enable them in device settings.',
              ),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => Geolocator.openAppSettings(),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      debugPrint('LocationService.getCurrentLocation error: $e');
      return null;
    }
  }

  /// Helper to safely attempt launching a [uri] across different [LaunchMode]s.
  static Future<bool> _safeLaunch(Uri uri) async {
    // 1. Try external application (native Google Maps app or external browser)
    try {
      if (await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      )) {
        return true;
      }
    } catch (e) {
      debugPrint('_safeLaunch externalApplication failed for $uri: $e');
    }

    // 2. Try platform default
    try {
      if (await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_blank',
      )) {
        return true;
      }
    } catch (e) {
      debugPrint('_safeLaunch platformDefault failed for $uri: $e');
    }

    // 3. Try inAppBrowserView (fallback)
    try {
      if (await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      )) {
        return true;
      }
    } catch (e) {
      debugPrint('_safeLaunch inAppBrowserView failed for $uri: $e');
    }

    return false;
  }

  /// Opens Google Maps / Native Maps for a given [location].
  /// Uses [Geolocator] to query GPS coordinates when available.
  static Future<void> openMapForLocation(
    BuildContext context, {
    required String location,
    String? tripTitle,
    bool preferDirections = false,
  }) async {
    final cleanLocation = location.trim();
    if (cleanLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No location specified for this trip')),
      );
      return;
    }

    // Show immediate friendly feedback
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Opening map for "$cleanLocation"...',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Fetch GPS coordinates via Geolocator
    // (with a short 1.5s timeout on web so browser gesture tokens don't expire)
    Position? position;
    try {
      if (!kIsWeb) {
        position = await getCurrentLocation(context: context);
      }
    } catch (e) {
      debugPrint('Geolocator fetch error: $e');
    }

    final encoded = Uri.encodeComponent(cleanLocation);

    // List of candidate URIs in priority order
    final List<Uri> candidateUris = [];

    if (preferDirections) {
      if (position != null) {
        candidateUris.add(
          Uri.parse(
            'https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=$encoded',
          ),
        );
      }
      candidateUris.add(
        Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$encoded'),
      );
    } else {
      // 1. Universal Google Maps web & app search
      candidateUris.add(
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded'),
      );

      // 2. Maps.google.com universal shortcut
      candidateUris.add(
        Uri.parse('https://maps.google.com/?q=$encoded'),
      );

      // 3. Android geo intent (only on mobile)
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        if (position != null) {
          candidateUris.add(
            Uri.parse('geo:${position.latitude},${position.longitude}?q=$encoded'),
          );
        } else {
          candidateUris.add(Uri.parse('geo:0,0?q=$encoded'));
        }
      }

      // 4. Apple Maps (on iOS / macOS)
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        candidateUris.add(Uri.parse('https://maps.apple.com/?q=$encoded'));
      }
    }

    bool success = false;
    String lastError = '';

    for (final uri in candidateUris) {
      try {
        if (await _safeLaunch(uri)) {
          success = true;
          break;
        }
      } catch (e) {
        lastError = e.toString();
        debugPrint('Failed to launch candidate uri $uri: $e');
      }
    }

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Check if it's a MissingPluginException (occurs when app was not rebuilt after pub add)
      final isMissingPlugin = lastError.contains('MissingPluginException') ||
          lastError.contains('No implementation found');

      if (isMissingPlugin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please stop and restart the app (run "flutter run") to load new plugins.',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        // Show fallback modal with copyable link so the user is never stuck
        final fallbackWebUrl =
            'https://www.google.com/maps/search/?api=1&query=$encoded';
        _showFallbackDialog(context, cleanLocation, fallbackWebUrl);
      }
    }
  }

  /// Opens directions directly from the user's current GPS location
  /// (obtained via [Geolocator]) to the [destination].
  static Future<void> openDirectionsFromCurrentLocation(
    BuildContext context, {
    required String destination,
  }) async {
    return openMapForLocation(
      context,
      location: destination,
      preferDirections: true,
    );
  }

  /// Shows an interactive bottom sheet displaying trip destination info,
  /// live GPS location from [Geolocator], and quick actions to open Google Maps
  /// or get turn-by-turn directions.
  static void showLocationOptionsSheet(
    BuildContext context, {
    required String location,
    String? tripTitle,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _LocationOptionsSheet(
        location: location,
        tripTitle: tripTitle,
      ),
    );
  }

  static void _showFallbackDialog(
    BuildContext context,
    String location,
    String mapUrl,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.location_on_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Open Map'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location: $location',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            const Text(
              'Could not launch external map automatically. You can copy the link below or restart your app if you recently added packages.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                mapUrl,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: mapUrl));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Map URL copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy Link'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationOptionsSheet extends StatefulWidget {
  final String location;
  final String? tripTitle;

  const _LocationOptionsSheet({
    required this.location,
    this.tripTitle,
  });

  @override
  State<_LocationOptionsSheet> createState() => _LocationOptionsSheetState();
}

class _LocationOptionsSheetState extends State<_LocationOptionsSheet> {
  Position? _currentPosition;
  bool _isLoadingGps = true;
  String? _gpsError;

  @override
  void initState() {
    super.initState();
    _fetchGpsLocation();
  }

  Future<void> _fetchGpsLocation() async {
    setState(() {
      _isLoadingGps = true;
      _gpsError = null;
    });

    try {
      final pos = await LocationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _currentPosition = pos;
        _isLoadingGps = false;
        if (pos == null) {
          _gpsError = 'GPS permission not granted or location disabled';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingGps = false;
        _gpsError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 24,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.map_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Trip Location & Maps',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          iconSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Destination Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Destination',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.location,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              if (widget.tripTitle != null &&
                                  widget.tripTitle!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.tripTitle!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Geolocator GPS Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: Color(0xFF10B981),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Your Current GPS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Geolocator',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              if (_isLoadingGps)
                                const Row(
                                  children: [
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Detecting GPS location...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                )
                              else if (_currentPosition != null)
                                Text(
                                  '${_currentPosition!.latitude.toStringAsFixed(4)}°, ${_currentPosition!.longitude.toStringAsFixed(4)}°',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                )
                              else
                                Text(
                                  _gpsError ?? 'Location unavailable',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          onPressed: _fetchGpsLocation,
                          tooltip: 'Refresh GPS',
                          style: IconButton.styleFrom(
                            foregroundColor: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      LocationService.openMapForLocation(
                        context,
                        location: widget.location,
                        tripTitle: widget.tripTitle,
                      );
                    },
                    icon: const Icon(Icons.map_rounded,
                        color: Colors.white, size: 18),
                    label: const Text(
                      'Open in Google Maps',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      LocationService.openDirectionsFromCurrentLocation(
                        context,
                        destination: widget.location,
                      );
                    },
                    icon: const Icon(Icons.directions_rounded,
                        color: AppColors.primary, size: 18),
                    label: const Text(
                      'Get Directions from My Location',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.location));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Copied "${widget.location}" to clipboard',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded,
                        size: 16, color: Color(0xFF64748B)),
                    label: const Text(
                      'Copy Location Name',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
