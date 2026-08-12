import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';
import 'package:travel_buddy_finder/utils/app_lists.dart';
import 'package:travel_buddy_finder/widgets/input_decoration.dart';
import 'package:travel_buddy_finder/widgets/screen_background.dart';

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "CREATE NEW PUBLIC TRIP",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "TRIP TITLE",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _tripNameController,
                    decoration: inputDecoration(
                      hint: "e.g. Summer Kyoto Temples Discovery",
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Enter trip title"
                        : null,
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "DESTINATION CITY",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _destinationController,
                    decoration: inputDecoration(
                      hint: "e.g. Bali, Indonesia",
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Enter destination"
                        : null,
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "START DATE",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _startDateController,
                              readOnly: true,
                              onTap: () => _selectDate(_startDateController),
                              decoration: inputDecoration(hint: "Select date"),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? "Select start date"
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
                            const Text(
                              "END DATE",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _endDateController,
                              readOnly: true,
                              onTap: () => _selectDate(_endDateController),
                              decoration: inputDecoration(hint: "Select date"),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? "Select end date"
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
                            const Text(
                              "BUDGET",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _budgetController,
                              keyboardType: TextInputType.number,
                              decoration: inputDecoration(
                                hint: "\$1,200",
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? "Enter budget"
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
                            const Text(
                              "CATEGORY",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: inputDecoration(
                                hint: "Adventure",
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
                                  value == null ? "Select category" : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "DESCRIPTION & PACE",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: inputDecoration(
                      hint:
                          "Details about itinerary and partner expectations...",
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Enter description"
                        : null,
                  ),

                  const SizedBox(height: 16),

                  InkWell(
                    onTap: _pickCoverImage,
                    borderRadius: BorderRadius.circular(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 170,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: _coverImageBytes != null
                            ? Image.memory(
                                _coverImageBytes!,
                                fit: BoxFit.cover,
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Upload Cover Photo',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              AppColors.buttonColor,
                            ),
                          ),
                          onPressed: _submitTrip,
                          child: const Text(
                            "Publish Trip",
                            style: TextStyle(color: Colors.black),
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
      _showMessage("Trip published successfully!");
    }
  }
}
