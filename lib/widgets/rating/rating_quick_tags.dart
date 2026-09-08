import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';

class RatingQuickTags extends StatelessWidget {
  final List<String> tags;
  final Set<String> selectedTags;
  final void Function(String tag, bool selected)
      onTagChanged;

  const RatingQuickTags({
    super.key,
    required this.tags,
    required this.selectedTags,
    required this.onTagChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What went great?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map(_buildTag).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    final isSelected = selectedTags.contains(tag);

    return FilterChip(
      label: Text(tag),

      selected: isSelected,

      onSelected: (selected) {
        onTagChanged(
          tag,
          selected,
        );
      },

      selectedColor:
          AppColors.primary.withValues(alpha: 0.15),

      checkmarkColor: AppColors.primary,

      backgroundColor: const Color(0xFFF1F5F9),

      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.primary
            : const Color(0xFF334155),
        fontSize: 12,
        fontWeight: isSelected
            ? FontWeight.bold
            : FontWeight.w500,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : Colors.transparent,
        ),
      ),
    );
  }
}