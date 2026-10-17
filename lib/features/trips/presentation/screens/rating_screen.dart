import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/features/trips/data/models/trip.dart';
import 'package:travel_buddy_finder/features/trips/data/models/review.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';
import 'package:travel_buddy_finder/features/trips/data/stores/review_store.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/rating/rating_quick_tags.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/rating/rating_review_box.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/rating/rating_stars_card.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/rating/rating_submit_button.dart';
import 'package:travel_buddy_finder/features/trips/presentation/widgets/rating/rating_trip_preview.dart';

class RatingScreen extends StatefulWidget {
  final Trip? trip;

  const RatingScreen({
    super.key,
    this.trip,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 5;
  final TextEditingController _reviewController = TextEditingController();

  final Set<String> _selectedTags = {};
  bool _wouldRecommend = true;
  final List<String> _quickTags = [
    'Friendly Host',
    'Great Communication',
    'Safe & Reliable',
    'Punctual & Organized',
    'Fun Atmosphere',
    'Highly Recommended',
    'Scenic Routes',
    'Budget Friendly',
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Needs Improvement 😞';
      case 2:
        return 'Fair Experience 😐';
      case 3:
        return 'Good Journey 😊';
      case 4:
        return 'Great Experience! 😃';
      case 5:
        return 'Exceptional & Unforgettable! 🌟';
      default:
        return 'Tap stars to rate';
    }
  }

  void _onRatingChanged(int rating) {
    setState(() {
      _rating = rating;
    });
  }

  void _onTagChanged(
    String tag,
    bool selected,
  ) {
    setState(() {
      if (selected) {
        _selectedTags.add(tag);
      } else {
        _selectedTags.remove(tag);
      }
    });
  }

  void _onRecommendationChanged(bool value) {
    setState(() {
      _wouldRecommend = value;
    });
  }

  void _submitRating() {
    if (_rating == 0) {
      _showMessage(
        'Please select a star rating',
      );
      return;
    }

    final tripId = widget.trip?.id ?? '';
    final reviewText = _reviewController.text.trim();

    final review = Review(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      tripId: tripId,
      userName: CurrentUser.name,
      userUsername: CurrentUser.username,
      userAvatarUrl: CurrentUser.avatarUrl,
      rating: _rating.toDouble(),
      reviewText: reviewText.isEmpty ? _getRatingLabel(_rating) : reviewText,
      tags: _selectedTags.toList(),
      wouldRecommend: _wouldRecommend,
      createdAt: DateTime.now(),
    );

    ReviewStore.addReview(review);

    if (widget.trip != null) {
      setState(() {
        widget.trip!.rating =
            ReviewStore.getAverageRating(tripId).toStringAsFixed(1);
      });
    }
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.stars_rounded,
                color: Colors.orange,
                size: 28,
              ),
              SizedBox(width: 10),
              Text('Thank You!'),
            ],
          ),
          content: const Text(
            'Your review has been submitted and will help '
            'other travel buddies make better choices.',
            style: TextStyle(
              color: AppColors.greyText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context, true);
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final hostName = trip?.hostName ?? 'Travel Buddy';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (trip != null) ...[
              RatingTripPreview(
                trip: trip,
              ),
              const SizedBox(height: 20),
            ],
            RatingStarsCard(
              hostName: hostName,
              rating: _rating,
              ratingLabel: _getRatingLabel(_rating),
              onRatingChanged: _onRatingChanged,
            ),
            const SizedBox(height: 20),
            RatingQuickTags(
              tags: _quickTags,
              selectedTags: _selectedTags,
              onTagChanged: _onTagChanged,
            ),
            const SizedBox(height: 20),
            RatingReviewBox(
              controller: _reviewController,
              wouldRecommend: _wouldRecommend,
              onRecommendationChanged: _onRecommendationChanged,
            ),
            const SizedBox(height: 28),
            RatingSubmitButton(
              onPressed: _submitRating,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFF1E293B),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text(
        'Trip Review',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Skip',
            style: TextStyle(
              color: AppColors.greyText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
