import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/models/trip.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';

class ViewScreen extends StatelessWidget {
  final Trip trip;
  const ViewScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Trip Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Hero(
              tag: 'trip-image-${trip.id}',
              child: trip.imageBytes != null
                  ? Image.memory(trip.imageBytes!, width: double.infinity, height: 250, fit: BoxFit.cover)
                  : Image.network(trip.imageUrl, width: double.infinity, height: 250, fit: BoxFit.cover),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          trip.title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              trip.rating,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                      const SizedBox(width: 4),
                      Text(trip.location, style: const TextStyle(color: AppColors.greyText, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Host Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(trip.avatarUrl),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trip.hostName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(trip.username, style: const TextStyle(color: AppColors.greyText)),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text("Message", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  
                  // Details Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _detailItem(Icons.attach_money, "Price", trip.price),
                      _detailItem(Icons.category, "Category", trip.category),
                      _detailItem(Icons.event_seat, "Seats Left", "${trip.seatsLeft}"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Additional Info
                  if (trip.genderPreference != null)
                    _infoTile(Icons.people, "Gender Preference", trip.genderPreference!),
                  if (trip.transportationMethods != null && trip.transportationMethods!.isNotEmpty)
                    _infoTile(Icons.directions_bus, "Transportation", trip.transportationMethods!.join(", ")),
                  
                  const SizedBox(height: 20),
                  
                  // Description
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    trip.description,
                    style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                  ),
                  
                  const Divider(height: 40),
                  
                  // Comments Section (Facebook Style)
                  const Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _commentItem(
                    "Jane Doe",
                    "@jane_d",
                    "This trip looks amazing! I would love to join.",
                    "https://i.pravatar.cc/150?u=jane",
                    "2h ago",
                  ),
                  _commentItem(
                    "John Smith",
                    "@jsmith",
                    "What is the exact meeting point?",
                    "https://i.pravatar.cc/150?u=john",
                    "5h ago",
                  ),
                  
                  const SizedBox(height: 16),
                  // Comment Input
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=you"),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Write a comment...",
                            hintStyle: const TextStyle(fontSize: 14),
                            filled: true,
                            fillColor: AppColors.fieldColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.send, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("JOIN TRIP NOW", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.greyText, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.greyText),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _commentItem(String name, String username, String comment, String avatarUrl, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.fieldColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(time, style: const TextStyle(color: AppColors.greyText, fontSize: 10)),
                    ],
                  ),
                  Text(username, style: const TextStyle(color: AppColors.greyText, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(comment),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
