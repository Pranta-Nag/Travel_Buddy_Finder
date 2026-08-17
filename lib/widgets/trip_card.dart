import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/screens/comment_screen.dart';
import 'package:travel_buddy_finder/screens/edit_trip_screen.dart';
import 'package:travel_buddy_finder/screens/rating_screen.dart';
import 'package:travel_buddy_finder/screens/user_profile_screen.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';

class TripCard extends StatefulWidget {
  const TripCard(
      {super.key,
      required this.trip,
      required this.isBookmarked,
      this.onBookmarkToggle,
      this.onDelete});

  final Trip trip;
  final bool isBookmarked;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onDelete;

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    final bool isOwner = widget.trip.hostName == 'You' && widget.trip.username == '@you';
    return SizedBox(
      height: 360,
      child: Card(
        elevation: 2,
        shadowColor: AppColors.greyText.withValues(alpha: .2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            child: widget.trip.imageBytes != null
                ? Image.memory(
                    widget.trip.imageBytes!,
                    height: 150, width: double.infinity, fit: BoxFit.cover)
                : Image.network(widget.trip.imageUrl,
                    height: 150, width: double.infinity, fit: BoxFit.cover),
            ),
            Positioned(
                top: 12,
                left: 12,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTripScreen(trip: widget.trip),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                  ),
                ),
            ),
            Positioned(
                left: 12,
                bottom: 12,
                child: _pill(Icons.location_on, widget.trip.location, Colors.black54)),
            Positioned(
                top: 12,
                right: 12,
                child:
                    _pill(null, widget.trip.price, AppColors.primary.withValues(alpha: .9))),
          ]),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.trip.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Align(
                  alignment: Alignment.centerRight,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.star, color: Colors.orange.shade600, size: 18),
                    const SizedBox(width: 4),
                    Text(widget.trip.rating,
                        style: const TextStyle(fontWeight: FontWeight.w600))
                  ])),
              const SizedBox(height: 10),
              Row(children: [
                GestureDetector(
                    onTap: () => _openProfile(context),
                    child: CircleAvatar(
                        radius: 14,
                        backgroundImage: NetworkImage(widget.trip.avatarUrl))),
                const SizedBox(width: 10),
                Expanded(
                    child: GestureDetector(
                        onTap: () => _openProfile(context),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('By ${widget.trip.hostName}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(widget.trip.username,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12))
                            ]))),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('${widget.trip.seatsLeft} seats left',
                        style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.w600))),
              ]),
              const Spacer(),
              Row(children: [
                _actionButton(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    _isLiked ? Colors.red : Colors.grey.shade700,
                    () {
                      setState(() {
                        _isLiked = !_isLiked;
                      });
                      if (_isLiked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('You liked ${widget.trip.title}')),
                        );
                      }
                    }),
                const SizedBox(width: 4),
                _actionButton(
                    Icons.chat_bubble_outline,
                    Colors.grey.shade700,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CommentScreen()))),
                const SizedBox(width: 4),
                _actionButton(
                    widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    widget.isBookmarked ? Colors.blue : Colors.grey.shade700,
                    widget.onBookmarkToggle ?? () {}),
                const SizedBox(width: 4),
                _actionButton(
                    Icons.star_border,
                    Colors.grey.shade700,
                    () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RatingScreen(trip: widget.trip),
                        ),
                      );
                      if (updated == true && mounted) {
                        setState(() {}); // Refresh this specific card
                      }
                    }),
                if (isOwner && widget.onDelete != null) ...[
                  const SizedBox(width: 4),
                  _actionButton(
                      Icons.delete_outline,
                      Colors.red,
                      widget.onDelete!),
                ],
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            child: const Text('Join Trip',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                      ),
                     const SizedBox(width: 6),
                     
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size.fromWidth(8),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.grey.shade700,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            child: const Text('View Trip',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                      ),
                    ],
                  ),
                ),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _pill(IconData? icon, String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          const Icon(Icons.location_on, color: Colors.white, size: 14),
          const SizedBox(width: 4)
        ],
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))
      ]));
  Widget _actionButton(
          IconData icon, Color color, VoidCallback onPressed) =>
      Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8)),
          child: IconButton(
              padding: EdgeInsets.zero,
              splashRadius: 16,
              iconSize: 16,
              color: color,
              onPressed: onPressed,
              icon: Icon(icon)));
  void _openProfile(BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => UserProfileScreen(
              name: widget.trip.hostName,
              username: widget.trip.username,
              avatarUrl: widget.trip.avatarUrl)));
}
