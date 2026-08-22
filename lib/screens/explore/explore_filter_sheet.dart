import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';
import 'explore_filter.dart';

class ExploreFilterSheet extends StatefulWidget {
  final double initialBudget;
  final String initialGender;
  final List<String> initialTransportations;
  final String initialCategory;
  final SortOption initialSort;

  final Function(
    double budget,
    String gender,
    List<String> transportations,
    String category,
    SortOption sort,
  ) onApply;

  const ExploreFilterSheet({
    super.key,
    required this.initialBudget,
    required this.initialGender,
    required this.initialTransportations,
    required this.initialCategory,
    required this.initialSort,
    required this.onApply,
  });

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  late double budget;
  late String gender;
  late List<String> transportations;
  late String category;
  late SortOption sort;

  @override
  void initState() {
    super.initState();

    budget = widget.initialBudget;
    gender = widget.initialGender;
    transportations = List.from(widget.initialTransportations);
    category = widget.initialCategory;
    sort = widget.initialSort;
  }

  void _reset() {
    setState(() {
      budget = ExploreFilterData.maxBudget;
      gender = ExploreFilterData.anyGender;
      transportations.clear();
      category = ExploreFilterData.allCategory;
      sort = SortOption.recommended;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              children: [
                _buildSortSection(),
                const SizedBox(height: 28),
                _buildBudgetSection(),
                const SizedBox(height: 28),
                _buildCategorySection(),
                const SizedBox(height: 28),
                _buildGenderSection(),
                const SizedBox(height: 28),
                _buildTransportationSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filters & Sorting",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: _reset,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text(
                  "Reset All",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF64748B),
        letterSpacing: .8,
      ),
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("SORT BY"),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _sortChip(
              "Recommended",
              Icons.auto_awesome_rounded,
              SortOption.recommended,
            ),
            _sortChip(
              "Price: Low to High",
              Icons.arrow_upward_rounded,
              SortOption.priceLowToHigh,
            ),
            _sortChip(
              "Price: High to Low",
              Icons.arrow_downward_rounded,
              SortOption.priceHighToLow,
            ),
            _sortChip(
              "Highest Rated",
              Icons.star_rounded,
              SortOption.highestRated,
            ),
          ],
        ),
      ],
    );
  }

  Widget _sortChip(
    String label,
    IconData icon,
    SortOption option,
  ) {
    final selected = sort == option;

    return InkWell(
      onTap: () {
        setState(() {
          sort = option;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected
                  ? Colors.white
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? Colors.white
                    : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle("MAX BUDGET PER PERSON"),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "\$${budget.round()}",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: budget,
          min: ExploreFilterData.minBudget,
          max: ExploreFilterData.maxBudget,
          divisions: 48,
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() {
              budget = value;
            });
          },
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("\$200"),
            Text("\$5,000+"),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("CATEGORY"),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ExploreFilterData.categories.map((item) {
            final selected = category == item;

            return FilterChip(
              avatar: Icon(
                ExploreFilterData.categoryIcon(item),
                size: 16,
                color: selected
                    ? Colors.white
                    : const Color(0xFF64748B),
              ),
              label: Text(item),
              selected: selected,
              selectedColor: AppColors.primary,
              backgroundColor: const Color(0xFFF8FAFC),
              showCheckmark: false,
              labelStyle: TextStyle(
                color: selected
                    ? Colors.white
                    : const Color(0xFF334155),
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
              ),
              onSelected: (_) {
                setState(() {
                  category = item;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("GENDER PREFERENCE"),
        const SizedBox(height: 10),
        ...ExploreFilterData.genders.map(
          (item) => _genderTile(item),
        ),
      ],
    );
  }

  Widget _genderTile(String item) {
    final selected = gender == item;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            gender = item;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: .08)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.contains("Female")
                    ? Icons.female_rounded
                    : item.contains("Male")
                        ? Icons.male_rounded
                        : Icons.group_rounded,
                color: selected
                    ? AppColors.primary
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransportationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("TRANSPORTATION METHOD"),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              ExploreFilterData.transportationMethods.map((item) {
            final selected = transportations.contains(item);

            return FilterChip(
              avatar: Icon(
                ExploreFilterData.transportIcon(item),
                size: 16,
                color: selected
                    ? Colors.white
                    : const Color(0xFF64748B),
              ),
              label: Text(item),
              selected: selected,
              selectedColor: AppColors.primary,
              showCheckmark: false,
              onSelected: (value) {
                setState(() {
                  if (value) {
                    transportations.add(item);
                  } else {
                    transportations.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(
                  budget,
                  gender,
                  transportations,
                  category,
                  sort,
                );

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "Apply Filters",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}