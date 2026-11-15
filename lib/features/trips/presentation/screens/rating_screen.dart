import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/rating_provider.dart';
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
  bool _isSubmitting = false;

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
  void initState() {
    super.initState();
    _checkExistingRating();
  }

  void _checkExistingRating() {
    final tripId = int.tryParse(widget.trip?.id ?? '');
    if (tripId != null && tripId > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final ratingProv = context.read<RatingProvider>();
        final detail = await ratingProv.fetchRating(tripId);
        if (detail != null && detail.userRating != null && mounted) {
          setState(() {
            _rating = detail.userRating!;
          });
        }
      });
    }
  }

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

  Future<void> _submitRating() async {
    if (_isSubmitting) return;

    if (_rating == 0) {
      _showMessage('Please select a star rating');
      return;
    }

    final trip = widget.trip;
    final tripIdStr = trip?.id ?? '';
    final intTripId = int.tryParse(tripIdStr) ?? 0;

    // Check host business rule
    if (trip != null &&
        CurrentUser.isCurrentUser(trip.hostName, inputName: trip.hostName)) {
      _showMessage('Hosts are not allowed to rate their own trips!');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reviewText = _reviewController.text.trim();

      // Submit to backend API if trip has valid numeric ID
      if (intTripId > 0) {
        final ratingProv = context.read<RatingProvider>();
        final result = await ratingProv.submitRating(
          tripId: intTripId,
          rating: _rating,
        );

        if (!result.success) {
          if (mounted) {
            _showMessage(result.message);
            setState(() {
              _isSubmitting = false;
            });
          }
          return;
        }

        if (trip != null && result.averageRating != null) {
          trip.rating = result.averageRating!.toStringAsFixed(1);
        }
      }

      // Also persist to local ReviewStore optimistically for UI tags and text
      final review = Review(
        id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
        tripId: tripIdStr,
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

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        _showMessage('Error submitting rating: $e');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
            'Your rating has been saved to the backend database '
            'and will help other travel buddies make better choices.',
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
            _isSubmitting
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : RatingSubmitButton(
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

