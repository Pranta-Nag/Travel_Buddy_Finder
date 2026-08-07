import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final String name;
  final String username;
  final String avatarUrl;

  const UserProfileScreen({
    super.key,
    this.name = "Yuki Tanaka",
    this.username = "@yukitravels",
    this.avatarUrl =
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrxDFKgAYu8ljREtSQvGVItBppd7lZZ0jyvTdBJ5EMLA&s=10",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(avatarUrl),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              username,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Passionate traveler & adventure seeker. Always looking for new buddies to explore the world with! 🌍✈️",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem("Trips Hosted", "12"),
                _buildStatItem("Reviews", "48"),
                _buildStatItem("Rating", "4.9 ⭐"),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Followed $name")),
                  );
                },
                icon: const Icon(Icons.person_add),
                label: const Text("Follow Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
