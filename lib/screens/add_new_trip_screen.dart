import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';
import 'package:travel_buddy_finder/utils/app_lists.dart';
import 'package:travel_buddy_finder/widgets/input_decoration.dart';
import 'package:travel_buddy_finder/widgets/screen_background.dart';
import 'package:travel_buddy_finder/models/trip_data.dart';

class AddNewTripScreen extends StatefulWidget {
  const AddNewTripScreen({super.key});

  @override
  State<AddNewTripScreen> createState() => _AddNewTripScreenState();
}

class _AddNewTripScreenState extends State<AddNewTripScreen> {
  String? _selectedCategory;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _coverImageBytes;

  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Trip Details'),
                        const SizedBox(height: 16),
                        _buildLabel('Trip Title'),
                        TextFormField(
                          controller: _tripNameController,
                          decoration: inputDecoration(
                            hint: 'e.g. Summer Kyoto Temples Discovery',
                            prefixIcon: const Icon(Icons.title),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter trip title'
                                  : null,
                        ),

                        const SizedBox(height: 16),
                        _buildLabel('Destination City'),
                        TextFormField(
                          controller: _destinationController,
                          decoration: inputDecoration(
                            hint: 'e.g. Bali, Indonesia',
                            prefixIcon: const Icon(Icons.location_on_rounded),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter destination'
                                  : null,
                        ),

                        const SizedBox(height: 20),
                        _buildSectionTitle('Schedule & Budget'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Start Date'),
                                  TextFormField(
                                    controller: _startDateController,
                                    readOnly: true,
                                    onTap: () => _selectDate(_startDateController),
                                    decoration: inputDecoration(
                                      hint: 'Select date',
                                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Select start date'
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('End Date'),
                                  TextFormField(
                                    controller: _endDateController,
                                    readOnly: true,
                                    onTap: () => _selectDate(_endDateController),
                                    decoration: inputDecoration(
                                      hint: 'Select date',
                                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Select end date'
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Budget'),
                                  TextFormField(
                                    controller: _budgetController,
                                    keyboardType: TextInputType.number,
                                    decoration: inputDecoration(
                                      hint: '\$1,200',
                                      prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Enter budget'
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Category'),
                                  DropdownButtonFormField<String>(
                                    value: _selectedCategory,
                                    decoration: inputDecoration(
                                      hint: 'Adventure',
                                      prefixIcon: const Icon(Icons.category_rounded),
                                    ),
                                    isExpanded: true,
                                    items: AppLists.categories
                                        .map(
                                          (category) => DropdownMenuItem(
                                            value: category,
                                            child: Text(category),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategory = value;
                                      });
                                    },
                                    validator: (value) =>
                                        value == null ? 'Select category' : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        _buildSectionTitle('More Details'),
                        const SizedBox(height: 16),
                        _buildLabel('Description & Pace'),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: inputDecoration(
                            hint: 'Details about itinerary and partner expectations...',
                            prefixIcon: const Icon(Icons.description_rounded),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter description'
                                  : null,
                        ),

                        const SizedBox(height: 20),
                        _buildLabel('Cover Photo'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickCoverImage,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.fieldColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.borderColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: _coverImageBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.memory(
                                      _coverImageBytes!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.add_a_photo_rounded,
                                          size: 32,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Upload Cover Photo',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.greyText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tap to select from gallery',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.greyText.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 28),
                        _buildActionButtons(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.greyText,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Trip',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Share your journey with fellow travelers',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.greyText.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ElevatedButton(
            onPressed: _submitTrip,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Publish Trip',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate != null) {
      controller.text = DateFormat("dd MMM yyyy").format(pickedDate);
    }
  }

  Future<Uint8List?> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return null;
    return await image.readAsBytes();
  }

  Future<void> _pickCoverImage() async {
    final imageBytes = await _pickImage();
    if (imageBytes == null) return;

    setState(() {
      _coverImageBytes = imageBytes;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _validateExtraFields() {
    if (_coverImageBytes == null) {
      _showMessage("Please upload a cover picture.");
      return false;
    }
    return true;
  }

  void _submitTrip() {
    if (_formKey.currentState!.validate() && _validateExtraFields()) {
      final newTrip = Trip(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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
        category: _selectedCategory ?? 'Adventure',
        seatsLeft: 2,
        imageBytes: _coverImageBytes,
      );

      tripList.add(newTrip);
      Navigator.pop(context);
      _showMessage("Trip published successfully!");
    }
  }
}
