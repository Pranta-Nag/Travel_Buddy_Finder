import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/trip_provider.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/core/constants/app_lists.dart';
import 'package:travel_buddy_finder/core/widgets/input_decoration.dart';
import 'package:travel_buddy_finder/core/widgets/screen_background.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip.dart';

class EditTripScreen extends StatefulWidget {
  final Trip trip;
  const EditTripScreen({super.key, required this.trip});

  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  String? _selectedCategory;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _coverImageBytes;

  late TextEditingController _tripNameController;
  late TextEditingController _destinationController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _budgetController;
  late TextEditingController _descriptionController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tripNameController = TextEditingController(text: widget.trip.title);
    _destinationController = TextEditingController(text: widget.trip.location);
    _startDateController = TextEditingController(text: "15 Oct 2026");
    _endDateController = TextEditingController(text: "20 Oct 2026");
    _budgetController = TextEditingController(text: widget.trip.price.replaceAll('\$', ''));
    _descriptionController = TextEditingController(text: widget.trip.description);
    _selectedCategory = AppLists.categories.contains(widget.trip.category)
        ? widget.trip.category
        : (AppLists.categories.isNotEmpty ? AppLists.categories.first : null);
    _coverImageBytes = widget.trip.imageBytes;
  }

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

  Future<void> _handleDelete() async {
    final tripProvider = context.read<TripProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text('Are you sure you want to delete "${widget.trip.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final tripIdInt = int.tryParse(widget.trip.id) ?? 0;
      final result = await tripProvider.deleteTrip(tripIdInt);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final tripIdInt = int.tryParse(widget.trip.id) ?? 0;
    final rawBudget = _budgetController.text.trim().replaceAll('\$', '');
    final budgetDouble = double.tryParse(rawBudget) ?? 0.0;

    final tripProvider = context.read<TripProvider>();
    final result = await tripProvider.updateTrip(
      tripId: tripIdInt,
      title: _tripNameController.text.trim(),
      location: _destinationController.text.trim(),
      price: budgetDouble,
      startDate: _startDateController.text.trim(),
      endDate: _endDateController.text.trim(),
      category: _selectedCategory ?? widget.trip.category,
      description: _descriptionController.text.trim(),
      seats: widget.trip.seatsLeft,
      transports: widget.trip.transportationMethods,
      coverPhotoBytes: _coverImageBytes,
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: result.success ? Colors.green.shade600 : Colors.redAccent,
        content: Text(
          result.message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TripProvider>().isLoading;

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Edit active Trip",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 36.0),
                    child: Text(
                      "Pre-filled with active trip values: '${widget.trip.title}'",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildLabel("TRIP TITLE"),
                  TextFormField(
                    controller: _tripNameController,
                    decoration: inputDecoration(hint: "Trip Title"),
                    validator: (value) => value!.isEmpty ? "Enter trip title" : null,
                  ),

                  const SizedBox(height: 16),
                  _buildLabel("DESTINATION CITY"),
                  TextFormField(
                    controller: _destinationController,
                    decoration: inputDecoration(hint: "Destination"),
                    validator: (value) => value!.isEmpty ? "Enter destination" : null,
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("START DATE"),
                            TextFormField(
                              controller: _startDateController,
                              readOnly: true,
                              onTap: () => _selectDate(_startDateController),
                              decoration: inputDecoration(hint: "Start Date"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("END DATE"),
                            TextFormField(
                              controller: _endDateController,
                              readOnly: true,
                              onTap: () => _selectDate(_endDateController),
                              decoration: inputDecoration(hint: "End Date"),
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
                            _buildLabel("BUDGET"),
                            TextFormField(
                              controller: _budgetController,
                              keyboardType: TextInputType.number,
                              decoration: inputDecoration(hint: "Budget"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("CATEGORY"),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              decoration: inputDecoration(hint: "Category"),
                              items: AppLists.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (v) => setState(() => _selectedCategory = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _buildLabel("DESCRIPTION & PACE"),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: inputDecoration(hint: "Describe your trip..."),
                  ),

                  const SizedBox(height: 20),
                  _buildLabel("COVER PHOTO"),
                  InkWell(
                    onTap: _pickCoverImage,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _buildCoverImagePreview(),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading ? null : _handleDelete,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Delete Trip", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleUpdate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Update Changes",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      controller.text = DateFormat("dd MMM yyyy").format(picked);
    }
  }

  Future<void> _pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _coverImageBytes = bytes);
    }
  }

  Widget _buildCoverImagePreview() {
    if (_coverImageBytes != null && _coverImageBytes!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(_coverImageBytes!, fit: BoxFit.cover),
      );
    }

    final rawUrl = widget.trip.imageUrl.trim();
    if (rawUrl.isEmpty) {
      return _buildPhotoPlaceholder();
    }

    if (rawUrl.startsWith('data:image/') ||
        (!rawUrl.startsWith('http') &&
            !rawUrl.startsWith('assets/') &&
            rawUrl.length > 200)) {
      try {
        final base64String =
            rawUrl.contains(',') ? rawUrl.split(',').last : rawUrl;
        final decodedBytes = base64Decode(base64String.trim());
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(decodedBytes, fit: BoxFit.cover),
        );
      } catch (_) {}
    }

    if (rawUrl.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(rawUrl, fit: BoxFit.cover),
      );
    }

    final resolved = rawUrl.startsWith('http') ? rawUrl : AppUrl.resolveImageUrl(rawUrl);
    if (resolved.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          resolved,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPhotoPlaceholder(),
        ),
      );
    }

    return _buildPhotoPlaceholder();
  }

  Widget _buildPhotoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, color: Colors.grey[400], size: 32),
        const SizedBox(height: 8),
        Text("Update Photo", style: TextStyle(color: Colors.grey[500])),
      ],
    );
  }
}
