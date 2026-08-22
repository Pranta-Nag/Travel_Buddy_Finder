import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/models/trip_data.dart';
import 'package:travel_buddy_finder/screens/view_screen.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  double _budgetCap = 2500;
  String _selectedGender = "Any (Everyone is welcome)";
  final List<String> _selectedTransportations = [];
  String _selectedCategory = "All";

  List<Trip> _filteredTrips = [];

  final List<String> _categories = [
    "All",
    "Adventure",
    "Beach",
    "Cultural",
    "Romantic",
  ];

  final List<String> _genders = [
    "Any (Everyone is welcome)",
    "Male Only",
    "Female Only",
  ];

  final List<String> _transportationMethods = [
    "Flight",
    "Bullet Train",
    "Road Trip / Carpool",
    "Public Bus",
    "Sailing Boat",
  ];

  @override
  void initState() {
    super.initState();
    _filteredTrips = tripList;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredTrips = tripList.where((trip) {
        final price = double.tryParse(trip.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
        final withinBudget = price <= _budgetCap;

        // Gender filter
        final matchesGender = _selectedGender == "Any (Everyone is welcome)" ||
            trip.genderPreference == _selectedGender;

        // Category filter
        final matchesCategory = _selectedCategory == "All" ||
            trip.category.toLowerCase() == _selectedCategory.toLowerCase();

        // Transportation filter
        final matchesTransport = _selectedTransportations.isEmpty ||
            (trip.transportationMethods != null &&
                _selectedTransportations.any((t) => trip.transportationMethods!.contains(t)));

        return matchesSearch && withinBudget && matchesGender && matchesCategory && matchesTransport;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _budgetCap = 5000;
      _selectedGender = "Any (Everyone is welcome)";
      _selectedCategory = "All";
      _selectedTransportations.clear();
      _filteredTrips = tripList;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("All filters have been reset"),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  IconData _getTransportIcon(String method) {
    final m = method.toLowerCase();
    if (m.contains('flight')) return Icons.flight_takeoff_rounded;
    if (m.contains('bullet') || m.contains('train')) return Icons.train_rounded;
    if (m.contains('car') || m.contains('road')) return Icons.directions_car_rounded;
    if (m.contains('bus')) return Icons.directions_bus_rounded;
    if (m.contains('boat') || m.contains('sail')) return Icons.directions_boat_rounded;
    return Icons.commute_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600
        ? 2
        : screenWidth < 1000
            ? 3
            : 4;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Advanced Search Filters",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Icon(Icons.tune, color: AppColors.buttonColor),
                ],
              ),
              const SizedBox(height: 20),
              
              // Budget Cap
              const Text(
                "BUDGET CAP RANGE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.disabled,
                ),
              ),
              Slider(
                value: _budgetCap,
                min: 200,
                max: 5000,
                divisions: 48,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withValues(alpha: 0.2),
                onChanged: (double value) {
                  setState(() {
                    _budgetCap = value;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('\$200', style: TextStyle(color: AppColors.greyText, fontSize: 12)),
                  Text('\$${_budgetCap.round().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}', 
                       style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                  const Text('\$5,000', style: TextStyle(color: AppColors.greyText, fontSize: 12)),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Gender Preference
              const Text(
                "GENDER PREFERENCE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.disabled,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.fieldColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    isExpanded: true,
                    items: _genders.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGender = newValue!;
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Transportation Method
              const Text(
                "TRANSPORTATION METHOD",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.disabled,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 0,
                children: _transportationMethods.map((method) {
                  final isSelected = _selectedTransportations.contains(method);
                  return FilterChip(
                    label: Text(
                      method,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : AppColors.greyText,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedTransportations.add(method);
                        } else {
                          _selectedTransportations.remove(method);
                        }
                      });
                    },
                    selectedColor: AppColors.buttonColor,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.transparent),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Apply Advanced Filters",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Search Results
              const Text(
                "SEARCH RESULTS",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.disabled,
                ),
              ),
              const SizedBox(height: 16),
              
              _filteredTrips.isEmpty
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No trips found matching your criteria."),
                    ))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 200,
                      ),
                      itemCount: _filteredTrips.length,
                      itemBuilder: (context, index) {
                        return _buildTripCard(_filteredTrips[index]);
                      },
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewScreen(
              trip: trip,
              heroTag: 'explore-trip-image-${trip.id}',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Category Badge & Rating
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: trip.imageBytes != null
                    ? Image.memory(trip.imageBytes!, fit: BoxFit.cover, width: double.infinity)
                    : Image.network(
                        trip.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey.shade400,
                                size: 30,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      trip.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            trip.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.greyText,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          trip.price,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${trip.seatsLeft} seats",
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
                            ),
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
      ),
    );
  }
}
