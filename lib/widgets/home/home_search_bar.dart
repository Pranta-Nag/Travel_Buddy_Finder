import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/config/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final VoidCallback onChanged;
  final VoidCallback onClear;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          hintText: 'Search destinations...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon:
              const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
          suffixIcon: query.isEmpty
              ? Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.tune_rounded, color: Colors.white, size: 16),
                )
              : IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: Colors.grey.shade500, size: 20),
                  onPressed: onClear,
                ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
