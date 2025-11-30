import 'package:flutter/material.dart';

class MyStatusTile extends StatelessWidget {
  final String imageUrl;

  const MyStatusTile({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Color.fromARGB(255, 228, 121, 157),
              child: Icon(Icons.add, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      title: const Text(
        "My Status",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text("Tap to add status update"),
    );
  }
}
