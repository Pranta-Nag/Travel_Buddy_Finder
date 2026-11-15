import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_finder/api/providers/rating_provider.dart';

/// 1. Compact badge for Trip Card in Home Feed
class TripRatingBadge extends StatelessWidget {
  final double rating;
  final int count;

  const TripRatingBadge({
    super.key,
    required this.rating,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No ratings yet',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 14),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// 2. Interactive Dialog to Rate or Edit Rating using OpenStreetMap Guideline
class RateTripDialog extends StatefulWidget {
  final int tripId;
  final String? userToken;
  final bool isEdit;
  final int initialRating;

  const RateTripDialog({
    super.key,
    required this.tripId,
    this.userToken,
    this.isEdit = false,
    this.initialRating = 5,
  });

  @override
  State<RateTripDialog> createState() => _RateTripDialogState();
}

class _RateTripDialogState extends State<RateTripDialog> {
  late int _selectedStars;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedStars = widget.initialRating > 0 ? widget.initialRating : 5;
  }

  String getRatingLabel(int stars) {
    switch (stars) {
      case 5:
        return '⭐⭐⭐⭐⭐ Fantastic Experience!';
      case 4:
        return '⭐⭐⭐⭐ Great Trip!';
      case 3:
        return '⭐⭐⭐ Average Trip';
      case 2:
        return '⭐⭐ Below Expectations';
      case 1:
        return '⭐ Poor Experience';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratingProv = context.read<RatingProvider>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.isEdit ? 'Update Your Rating' : 'Rate This Trip',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'How was your travel buddy experience?',
            style: TextStyle(color: Color(0xFF475569), fontSize: 14),
          ),
          const SizedBox(height: 16),
          RatingBar.builder(
            initialRating: _selectedStars.toDouble(),
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) {
              setState(() {
                _selectedStars = rating.toInt();
              });
            },
          ),
          const SizedBox(height: 14),
          Text(
            getRatingLabel(_selectedStars),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _isSubmitting
              ? null
              : () async {
                  setState(() => _isSubmitting = true);
                  final result = await ratingProv.submitRating(
                    tripId: widget.tripId,
                    rating: _selectedStars,
                  );
                  if (context.mounted) {
                    Navigator.pop(context, result.success);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result.success
                              ? 'Rating saved successfully!'
                              : (result.message.isNotEmpty
                                  ? result.message
                                  : 'Failed to save rating.'),
                        ),
                        backgroundColor: result.success ? Colors.green : Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  widget.isEdit ? 'Update' : 'Submit',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
