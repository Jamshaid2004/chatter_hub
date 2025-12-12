import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/status/model/status_model.dart';
import 'package:flutter_chatter_hub/features/status/widgets/my_status_tile.dart';
import 'package:flutter_chatter_hub/features/status/widgets/user_status_tile.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final List<StatusModel> statusList = [
    StatusModel(
      name: "Miller",
      profilePic: "https://plus.unsplash.com/premium_photo-1669750817438-3f7f3112de8d?w=600",
      time: "Today, 11:45 AM",
    ),
    StatusModel(
      name: "Jane",
      profilePic: "https://images.unsplash.com/photo-1602233158242-3ba0ac4d2167?q=80",
      time: "Yesterday, 9:12 PM",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF48BB8),
        title: const Text(
          "Status",
          style: TextStyle(
            color: Color.fromARGB(255, 187, 52, 97),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 187, 52, 97)),
      ),
      body: ListView(
        children: [
          const MyStatusTile(
            imageUrl: "https://plus.unsplash.com/premium_photo-1669750817438-3f7f3112de8d?w=600",
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              "Recent Updates",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...statusList.map(
            (status) => Column(
              children: [
                UserStatusTile(status: status),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: const Color.fromARGB(255, 187, 52, 97),
        onPressed: () {},
        child: const Icon(Icons.photo_camera, color: Colors.white),
      ),
    );
  }
}
