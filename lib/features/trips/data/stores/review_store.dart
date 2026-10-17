import 'package:flutter/foundation.dart';
import 'package:travel_buddy_finder/features/trips/data/models/review.dart';
import 'package:travel_buddy_finder/features/trips/data/stores/trip_store.dart';

class ReviewStore {
  ReviewStore._();

  static final ValueNotifier<List<Review>> reviewsNotifier =
      ValueNotifier<List<Review>>(_initialReviews);

  static final List<Review> _initialReviews = [
    Review(
      id: 'rev_1',
      tripId: 'kyoto',
      userName: 'Alexander Lee',
      userUsername: '@alexander',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      rating: 5.0,
      reviewText:
          'Unbelievable experience! The host was super knowledgeable about Kyoto shrines and made everyone feel comfortable.',
      tags: ['Friendly Host', 'Scenic Routes', 'Highly Recommended'],
      wouldRecommend: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Review(
      id: 'rev_2',
      tripId: 'kyoto',
      userName: 'Sophia Martin',
      userUsername: '@sophiam',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      rating: 4.6,
      reviewText:
          'Great trip and well-organized schedule. The tea ceremony was a highlight!',
      tags: ['Punctual & Organized', 'Fun Atmosphere'],
      wouldRecommend: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Review(
      id: 'rev_3',
      tripId: 'bali',
      userName: 'Liam Chen',
      userUsername: '@liamc',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
      rating: 5.0,
      reviewText:
          'The sunrise hike was breathtaking. Maya was an incredible guide and took care of everything!',
      tags: ['Safe & Reliable', 'Scenic Routes', 'Highly Recommended'],
      wouldRecommend: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Review(
      id: 'rev_4',
      tripId: 'Kaptai',
      userName: 'Tanvir Hossain',
      userUsername: '@tanvirh',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      rating: 4.8,
      reviewText:
          'Kaptai lake view and boat ride were peaceful and memorable. Recommended!',
      tags: ['Budget Friendly', 'Scenic Routes', 'Friendly Host'],
      wouldRecommend: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static List<Review> getReviewsForTrip(String tripId) {
    return reviewsNotifier.value
        .where((review) => review.tripId == tripId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static double getAverageRating(String tripId) {
    final tripReviews = reviewsNotifier.value
        .where((review) => review.tripId == tripId)
        .toList();
    if (tripReviews.isEmpty) return 5.0;
    final total = tripReviews.fold<double>(0.0, (sum, r) => sum + r.rating);
    return total / tripReviews.length;
  }

  static void addReview(Review review) {
    final list = List<Review>.from(reviewsNotifier.value);
    list.add(review);
    reviewsNotifier.value = list;

    // Update trip rating in TripStore if trip exists
    if (review.tripId.isNotEmpty) {
      final tripIndex = TripStore.trips.indexWhere((t) => t.id == review.tripId);
      if (tripIndex != -1) {
        final currentTrip = TripStore.trips[tripIndex];
        final avgRating = getAverageRating(review.tripId);
        currentTrip.rating = avgRating.toStringAsFixed(1);
        TripStore.update(currentTrip);
      }
    }
  }
}
