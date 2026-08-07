import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/screens/user_profile_screen.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({super.key});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  final List<Map<String, dynamic>> comments = [
    {
      "name": "John Doe",
      "comment": "Amazing trip! Looking forward to joining.",
      "time": "2h ago",
      "liked": false,
    },
    {
      "name": "Sarah Ahmed",
      "comment": "Is transportation included?",
      "time": "5h ago",
      "liked": true,
    },
  ];

  void addComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      comments.insert(0, {
        "name": "You",
        "comment": _commentController.text.trim(),
        "time": "Now",
        "liked": false,
      });
    });

    _commentController.clear();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final item = comments[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfileScreen(
                                  name: item["name"] ?? "User",
                                  username:
                                      "@${(item["name"] as String).replaceAll(' ', '').toLowerCase()}",
                                ),
                              ),
                            );
                          },
                          child: const CircleAvatar(
                            radius: 22,
                            child: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["name"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(item["comment"]),
                              const SizedBox(height: 8),
                              Text(
                                item["time"],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              item["liked"] = !item["liked"];
                            });
                          },
                          icon: Icon(
                            item["liked"]
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: item["liked"] ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: "Write a comment...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      onPressed: addComment,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
