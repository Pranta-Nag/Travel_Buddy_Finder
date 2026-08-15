import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';
import 'package:travel_buddy_finder/utils/app_lists.dart';
import 'package:travel_buddy_finder/widgets/input_decoration.dart';
import 'package:travel_buddy_finder/widgets/screen_background.dart';

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
    _startDateController = TextEditingController(text: "15 Oct 2024"); // Dummy values as Trip model doesn't have these yet
    _endDateController = TextEditingController(text: "20 Oct 2024");
    _budgetController = TextEditingController(text: widget.trip.price.replaceAll('\$', ''));
    _descriptionController = TextEditingController(text: "Join me for an amazing adventure!");
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

  @override
  Widget build(BuildContext context) {
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
                              value: _selectedCategory,
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
                      child: _coverImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(_coverImageBytes!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: Colors.grey[400], size: 32),
                                const SizedBox(height: 8),
                                Text("Update Photo", style: TextStyle(color: Colors.grey[500])),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                             // Handle delete
                             Navigator.pop(context);
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Trip Deleted")));
                          },
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
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Handle update
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Trip Updated")));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text(
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
}
