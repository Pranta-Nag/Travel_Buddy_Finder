import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/profile_provider.dart';
import 'package:travel_buddy_finder/api/providers/trip_provider.dart';
import 'package:travel_buddy_finder/features/trips/data/stores/trip_store.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/explore/explore_filter.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/core/constants/app_lists.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/add_trip/trip_action_buttons.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/add_trip/trip_field_label.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/add_trip/trip_header.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/add_trip/trip_image_picker.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/add_trip/trip_section_title.dart';
import 'package:travel_buddy_finder/core/widgets/input_decoration.dart';
import 'package:travel_buddy_finder/core/widgets/screen_background.dart';

class AddNewTripScreen extends StatefulWidget {
  const AddNewTripScreen({super.key});

  @override
  State<AddNewTripScreen> createState() => _AddNewTripScreenState();
}

class _AddNewTripScreenState extends State<AddNewTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategory;
  Uint8List? _coverImageBytes;

  final _tripNameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _seatsController = TextEditingController(text: '4');

  final List<String> _selectedTransportations = [];

  @override
  void dispose() {
    _tripNameController.dispose();
    _destinationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    _seatsController.dispose();

    super.dispose();
  }

  IconData _transportIcon(String method) {
    final m = method.toLowerCase();
    if (m.contains('flight') || m.contains('air') || m.contains('plane')) {
      return Icons.flight_rounded;
    }
    if (m.contains('bus')) return Icons.directions_bus_rounded;
    if (m.contains('train') || m.contains('rail')) return Icons.train_rounded;
    if (m.contains('car') || m.contains('drive') || m.contains('road')) {
      return Icons.directions_car_rounded;
    }
    if (m.contains('boat') || m.contains('ferry') || m.contains('ship') || m.contains('cruise')) {
      return Icons.directions_boat_rounded;
    }
    if (m.contains('walk') || m.contains('trek') || m.contains('hike')) {
      return Icons.directions_walk_rounded;
    }
    if (m.contains('bike') || m.contains('cycle')) {
      return Icons.two_wheeler_rounded;
    }
    return Icons.commute_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLoading = context.watch<TripProvider>().isLoading;

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              TripHeader(
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: size.width > 600 ? 540 : size.width,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppColors.borderColor.withValues(alpha: 0.8),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTripDetailsSection(),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Divider(color: AppColors.borderColor, thickness: 1),
                                ),
                                _buildScheduleSection(),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Divider(color: AppColors.borderColor, thickness: 1),
                                ),
                                _buildMoreDetailsSection(),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Divider(color: AppColors.borderColor, thickness: 1),
                                ),
                                _buildTransportAndSeatsSection(),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Divider(color: AppColors.borderColor, thickness: 1),
                                ),
                                _buildCoverPhotoSection(),
                                const SizedBox(height: 28),
                                TripActionButtons(
                                  isLoading: isLoading,
                                  onCancel: () => Navigator.pop(context),
                                  onPublish: _submitTrip,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TripSectionTitle(
          title: 'Trip Details',
          icon: Icons.explore_outlined,
        ),
        const TripFieldLabel(text: 'Trip Title', isRequired: true),
        TextFormField(
          controller: _tripNameController,
          textInputAction: TextInputAction.next,
          decoration: inputDecoration(
            hint: 'e.g. Summer Kyoto Temples Discovery',
            prefixIcon: const Icon(
              Icons.flight_takeoff_rounded,
              size: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter trip title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        const TripFieldLabel(text: 'Destination City', isRequired: true),
        TextFormField(
          controller: _destinationController,
          textInputAction: TextInputAction.next,
          decoration: inputDecoration(
            hint: 'e.g. Bali, Indonesia',
            prefixIcon: const Icon(
              Icons.location_on_rounded,
              size: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter destination';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TripSectionTitle(
          title: 'Schedule & Budget',
          icon: Icons.calendar_month_outlined,
        ),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Start Date',
                controller: _startDateController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                label: 'End Date',
                controller: _endDateController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildBudgetField(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCategoryField(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TripFieldLabel(text: label, isRequired: true),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(controller),
          decoration: inputDecoration(
            hint: 'YYYY-MM-DD',
            prefixIcon: const Icon(
              Icons.calendar_today_rounded,
              size: 19,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Select date';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBudgetField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TripFieldLabel(text: 'Budget (৳)', isRequired: true),
        TextFormField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          decoration: inputDecoration(
            hint: 'e.g. 12000',
            prefixIcon: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter budget';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TripFieldLabel(text: 'Category', isRequired: true),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          decoration: inputDecoration(
            hint: 'Adventure',
            prefixIcon: const Icon(
              Icons.category_rounded,
              size: 20,
            ),
          ),
          items: AppLists.categories.map(
            (category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(
                  category,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            },
          ).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Select category';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMoreDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TripSectionTitle(
          title: 'Trip Itinerary & Story',
          icon: Icons.notes_outlined,
        ),
        const TripFieldLabel(text: 'Description & Pace', isRequired: true),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: inputDecoration(
            hint: 'Describe your route, travel pace, planned activities, and what kind of buddy you are looking for...',
            prefixIcon: const Icon(
              Icons.edit_note_rounded,
              size: 22,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTransportAndSeatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TripSectionTitle(
          title: 'Transport & Seats',
          icon: Icons.commute_outlined,
        ),
        const TripFieldLabel(text: 'Transportation Methods'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ExploreFilterData.transportationMethods.map((method) {
            final isSelected = _selectedTransportations.contains(method);
            final icon = _transportIcon(method);

            return FilterChip(
              avatar: Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
              label: Text(
                method,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedTransportations.add(method);
                  } else {
                    _selectedTransportations.remove(method);
                  }
                });
              },
              backgroundColor: AppColors.fieldColor,
              selectedColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.borderColor,
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        const TripFieldLabel(text: 'Available Seats', isRequired: true),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _seatsController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration(
                  hint: 'e.g. 4',
                  prefixIcon: const Icon(
                    Icons.group_outlined,
                    size: 20,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter number of seats';
                  }
                  final count = int.tryParse(value.trim());
                  if (count == null || count <= 0) {
                    return 'Enter a valid number of seats';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.fieldColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor, width: 1.2),
              ),
              child: Row(
                children: [
                  IconButton(
                    splashRadius: 18,
                    icon: const Icon(Icons.remove_rounded, size: 18, color: AppColors.primary),
                    onPressed: () {
                      final current = int.tryParse(_seatsController.text.trim()) ?? 1;
                      if (current > 1) {
                        _seatsController.text = '${current - 1}';
                        setState(() {});
                      }
                    },
                  ),
                  IconButton(
                    splashRadius: 18,
                    icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                    onPressed: () {
                      final current = int.tryParse(_seatsController.text.trim()) ?? 0;
                      _seatsController.text = '${current + 1}';
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoverPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TripSectionTitle(
          title: 'Cover Photo',
          icon: Icons.add_photo_alternate_outlined,
        ),
        const TripFieldLabel(text: 'Trip Cover Image', isRequired: true),
        TripImagePicker(
          imageBytes: _coverImageBytes,
          onTap: _pickCoverImage,
        ),
      ],
    );
  }

  Future<void> _selectDate(
    TextEditingController controller,
  ) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate == null) return;
    controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
  }

  Future<void> _pickCoverImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _coverImageBytes = bytes;
    });
  }

  bool _validateExtraFields() {
    if (_coverImageBytes == null) {
      _showMessage(
        'Please upload a cover picture.',
      );
      return false;
    }
    return true;
  }

  Future<void> _submitTrip() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;
    if (!_validateExtraFields()) return;

    final tripProvider = context.read<TripProvider>();
    final result = await tripProvider.createTrip(
      title: _tripNameController.text.trim(),
      location: _destinationController.text.trim(),
      price: double.tryParse(_budgetController.text.trim()) ?? 0.0,
      startDate: _startDateController.text.trim(),
      endDate: _endDateController.text.trim(),
      category: _selectedCategory ?? 'Adventure',
      description: _descriptionController.text.trim(),
      seats: int.tryParse(_seatsController.text.trim()) ?? 4,
      transports: _selectedTransportations,
      coverPhotoBytes: _coverImageBytes,
    );

    if (!mounted) return;

    if (result.success) {
      context.read<ProfileProvider>().fetchMyProfile(silent: true);
      TripStore.refresh();
      Navigator.pop(context);
      _showMessage(result.message);
    } else {
      _showMessage(result.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
