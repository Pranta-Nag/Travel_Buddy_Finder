import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/widgets/home/category_pill.dart';

class CategoryBar extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<String> categories = [
    'All',
    'Adventure',
    'Beach',
    'Cultural',
    'Family',
    'Romantic',
    'Wildlife',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CategoryPill(
              label: cat,
              isSelected: isSelected,
              onTap: () => onCategorySelected(cat),
            ),
          );
        }).toList(),
      ),
    );
  }
}
