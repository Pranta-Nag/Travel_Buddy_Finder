import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/screens/comment_screen.dart';
import 'package:travel_buddy_finder/screens/rating_screen.dart';
import 'package:travel_buddy_finder/screens/user_profile_screen.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';

class TripCard extends StatefulWidget {
  const TripCard({super.key});

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  bool isFavorite = false;
  bool isBookmarked = false;
  bool isRated = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Card(
        elevation: 2,
        shadowColor: AppColors.greyText.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    "https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=800",
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Kyoto, Japan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "\$1450",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Kyoto Autumn Shrines & Tea Ceremony",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.orange.shade600,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "4.8",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserProfileScreen(
                                  name: "Yuki Tanaka",
                                  username: "@yukitravels",
                                  avatarUrl:
                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrxDFKgAYu8ljREtSQvGVItBppd7lZZ0jyvTdBJ5EMLA&s=10",
                                ),
                              ),
                            );
                          },
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrxDFKgAYu8ljREtSQvGVItBppd7lZZ0jyvTdBJ5EMLA&s=10",
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserProfileScreen(
                                    name: "Yuki Tanaka",
                                    username: "@yukitravels",
                                    avatarUrl:
                                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrxDFKgAYu8ljREtSQvGVItBppd7lZZ0jyvTdBJ5EMLA&s=10",
                                  ),
                                ),
                              );
                            },
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "By Yuki Tanaka",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "@yukitravels",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "2 seats left",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _actionButton(
                          icon: isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey.shade700,
                          onPressed: () {
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _actionButton(
                          icon: Icons.chat_bubble_outline,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CommentScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _actionButton(
                          icon: isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color:
                              isBookmarked ? Colors.blue : Colors.grey.shade700,
                          onPressed: () {
                            setState(() {
                              isBookmarked = !isBookmarked;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _actionButton(
                          icon: isRated ? Icons.star : Icons.star_border,
                          color: isRated
                              ? Colors.orange.shade600
                              : Colors.grey.shade700,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RatingScreen(),
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 42,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text("Join Trip"),
                          ),
                        ),
                        // const SizedBox(width: 8),
                        // SizedBox(
                        //   height: 42,
                        //   child: OutlinedButton(
                        //     style: OutlinedButton.styleFrom(
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //     ),
                        //     onPressed: () {},
                        //     child: const Text("View"),
                        //   ),
                        // ),
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

  Widget _actionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.grey,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        splashRadius: 20,
        iconSize: 20,
        color: color,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}
