import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/models/rating_model.dart';
import 'package:travel_buddy_finder/api/providers/rating_provider.dart';
import 'package:travel_buddy_finder/api/providers/trip_provider.dart';
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
  bool _isSubmitting = false;
  bool _isHost = false;
  bool _hasPreviousRating = false;

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
    _checkHostStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingRating();
    });
  }

  void _checkHostStatus() {
    final host = widget.trip?.hostName ?? '';
    final username = widget.trip?.username ?? '';
    _isHost = CurrentUser.isCurrentUser(host, inputName: host) ||
        CurrentUser.username.toLowerCase() ==
            username.toLowerCase().replaceAll('@', '').trim();
  }

  Future<void> _loadExistingRating() async {
    final tripId = widget.trip?.id;
    if (tripId == null || tripId.isEmpty) return;

    final ratingProvider = context.read<RatingProvider>();
    final data = await ratingProvider.fetchRating(tripId);
    if (!mounted) return;

    if (data != null) {
      setState(() {
        if (data.hasRated && data.userRating != null && data.userRating! > 0) {
          _rating = data.userRating!;
          _hasPreviousRating = true;
        }
        if (data.hostUsername.isNotEmpty &&
            data.hostUsername.toLowerCase() ==
                CurrentUser.username.toLowerCase().replaceAll('@', '').trim()) {
          _isHost = true;
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
    if (_isHost) {
      _showMessage('Hosts cannot rate their own trip.');
      return;
    }
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
    if (_isHost) {
      _showMessage('Hosts are not allowed to rate their own trips.');
      return;
    }

    if (_rating < 1 || _rating > 5) {
      _showMessage('Please select a star rating (1 to 5 stars).');
      return;
    }

    final tripId = widget.trip?.id ?? '';
    if (tripId.isEmpty) {
      _showMessage('Trip ID is missing.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final ratingProvider = context.read<RatingProvider>();
    final result = await ratingProvider.submitRating(
      tripId: tripId,
      rating: _rating,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result.success) {
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

      final updatedRating = ratingProvider.getRatingForTrip(tripId);
      if (widget.trip != null && updatedRating != null) {
        setState(() {
          widget.trip!.rating = updatedRating.averageRating.toStringAsFixed(1);
        });
      }

      // Refresh trip list so popular/explore tabs show updated ratings
      context.read<TripProvider>().fetchAllTrips();

      _showSuccessDialog();
    } else {
      _showMessage(result.message);
    }
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
          content: Text(
            _hasPreviousRating
                ? 'Your rating has been updated successfully!'
                : 'Your review has been submitted and will help other travel buddies make better choices.',
            style: const TextStyle(
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
            if (_isHost)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Color(0xFFDC2626), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You are the host of this trip. Hosts cannot rate their own trips.',
                        style: TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_hasPreviousRating)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        color: Color(0xFF16A34A), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You previously rated this trip $_rating stars. You can update your rating below.',
                        style: const TextStyle(
                          color: Color(0xFF15803D),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
              isLoading: _isSubmitting,
              text: _isHost
                  ? 'Host Cannot Rate'
                  : (_hasPreviousRating ? 'Update Rating' : 'Submit Review'),
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
      title: Text(
        _hasPreviousRating ? 'Edit Trip Rating' : 'Trip Review',
        style: const TextStyle(
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
