import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/models/trip_data.dart';
import 'package:travel_buddy_finder/utils/app_lists.dart';
import 'package:travel_buddy_finder/widgets/add_trip/trip_action_buttons.dart';
import 'package:travel_buddy_finder/widgets/add_trip/trip_field_label.dart';
import 'package:travel_buddy_finder/widgets/add_trip/trip_header.dart';
import 'package:travel_buddy_finder/widgets/add_trip/trip_image_picker.dart';
import 'package:travel_buddy_finder/widgets/add_trip/trip_section_title.dart';
import 'package:travel_buddy_finder/widgets/input_decoration.dart';
import 'package:travel_buddy_finder/widgets/screen_background.dart';

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

  @override
  void dispose() {
    _tripNameController.dispose();
    _destinationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              TripHeader(
                onBack: () => Navigator.pop(context),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTripDetailsSection(),
                        const SizedBox(height: 20),

                        _buildScheduleSection(),
                        const SizedBox(height: 20),

                        _buildMoreDetailsSection(),
                        const SizedBox(height: 20),

                        _buildCoverPhotoSection(),
                        const SizedBox(height: 28),

                        TripActionButtons(
                          onCancel: () => Navigator.pop(context),
                          onPublish: _submitTrip,
                        ),

                        const SizedBox(height: 16),
                      ],
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
        const TripSectionTitle(title: 'Trip Details'),
        const SizedBox(height: 16),
        const TripFieldLabel(text: 'Trip Title'),

        TextFormField(
          controller: _tripNameController,
          decoration: inputDecoration(
            hint: 'e.g. Summer Kyoto Temples Discovery',
            prefixIcon: const Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter trip title';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),
        const TripFieldLabel(text: 'Destination City'),

        TextFormField(
          controller: _destinationController,
          decoration: inputDecoration(
            hint: 'e.g. Bali, Indonesia',
            prefixIcon: const Icon(Icons.location_on_rounded),
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
        const TripSectionTitle(title: 'Schedule & Budget'),
        const SizedBox(height: 16),
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
        TripFieldLabel(text: label),

        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(controller),
          decoration: inputDecoration(
            hint: 'Select date',
            prefixIcon: const Icon(
              Icons.calendar_today_rounded,
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
        const TripFieldLabel(text: 'Budget'),
        TextFormField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          decoration: inputDecoration(
            hint: '\$1,200',
            prefixIcon: const Icon(
              Icons.account_balance_wallet_rounded,
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
        const TripFieldLabel(text: 'Category'),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          isExpanded: true,
          decoration: inputDecoration(
            hint: 'Adventure',
            prefixIcon: const Icon(
              Icons.category_rounded,
            ),
          ),
          items: AppLists.categories.map(
            (category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
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
        const TripSectionTitle(title: 'More Details'),
        const SizedBox(height: 16),
        const TripFieldLabel(text: 'Description & Pace'),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: inputDecoration(
            hint: 'Details about itinerary and partner expectations...',
            prefixIcon: const Icon(
              Icons.description_rounded,
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

  Widget _buildCoverPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TripFieldLabel(text: 'Cover Photo'),
        const SizedBox(height: 8),
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
    controller.text = DateFormat(
      'dd MMM yyyy',
    ).format(pickedDate);
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

  void _submitTrip() {
    final isFormValid =
        _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;
    if (!_validateExtraFields()) return;

    final newTrip = Trip(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),

      title: _tripNameController.text.trim(),
      location: _destinationController.text.trim(),
      price: '\$${_budgetController.text.trim()}',
      rating: '0.0',
      hostName: 'You',
      username: '@you',
      imageUrl:
          'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800',
      avatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      category:
          _selectedCategory ?? 'Adventure',
      description:
          _descriptionController.text.trim(),
      seatsLeft: 2,
      imageBytes: _coverImageBytes,
    );

    tripList.add(newTrip);
    Navigator.pop(context);
    _showMessage(
      'Trip published successfully!',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}