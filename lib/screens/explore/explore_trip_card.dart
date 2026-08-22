import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/screens/view_screen.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';
import 'package:travel_buddy_finder/utils/bookmark_store.dart';
import 'explore_filter.dart';

class ExploreTripCard extends StatelessWidget {
  final Trip trip;
  final bool gridView;

  const ExploreTripCard({
    super.key,
    required this.trip,
    required this.gridView,
  });

  @override
  Widget build(BuildContext context) {
    return gridView
        ? _buildGridCard(context)
        : _buildListCard(context);
  }

  void _openDetails(BuildContext context, String tag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewScreen(
          trip: trip,
          heroTag: tag,
        ),
      ),
    );
  }

  Widget _image(String heroTag) {
    return Hero(
      tag: heroTag,
      child: trip.imageBytes != null
          ? Image.memory(
              trip.imageBytes!,
              fit: BoxFit.cover,
            )
          : Image.network(
              trip.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFF94A3B8),
                  ),
                );
              },
            ),
    );
  }

  Widget _bookmark() {
    return ValueListenableBuilder<List<Trip>>(
      valueListenable: BookmarkStore.savedTrips,
      builder: (_, saved, __) {
        final isSaved =
            saved.any((item) => item.id == trip.id);

        return InkWell(
          onTap: () => BookmarkStore.toggle(trip),
          child: Icon(
            isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_outline_rounded,
            color: isSaved
                ? AppColors.primary
                : const Color(0xFF475569),
            size: 18,
          ),
        );
      },
    );
  }

  Widget _buildGridCard(BuildContext context) {
    final tag = 'explore-grid-image-${trip.id}';

    return GestureDetector(
      onTap: () => _openDetails(context, tag),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              flex: 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _image(tag),

                  Positioned(
                    top: 10,
                    left: 10,
                    child: _categoryBadge(),
                  ),

                  Positioned(
                    top: 10,
                    right: 10,
                    child: _ratingBadge(),
                  ),

                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: _bookmark(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 9,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: _gridBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .65),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ExploreFilterData.categoryIcon(trip.category),
            size: 11,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            trip.category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .95),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: Color(0xFFF59E0B),
            size: 13,
          ),
          const SizedBox(width: 2),
          Text(
            trip.rating,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            _location(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              trip.price,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            Text(
              "${trip.seatsLeft} left",
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB45309),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _location() {
    return Row(
      children: [
        const Icon(
          Icons.location_on_rounded,
          size: 12,
          color: AppColors.primary,
        ),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            trip.location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(BuildContext context) {
    final tag = 'explore-list-image-${trip.id}';

    return GestureDetector(
      onTap: () => _openDetails(context, tag),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 130,
              child: _image(tag),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFF59E0B),
                              size: 14,
                            ),
                            Text(
                              trip.rating,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        _bookmark(),
                      ],
                    ),
                    Text(
                      trip.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    _location(),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            trip.hostName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        Text(
                          trip.price,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}