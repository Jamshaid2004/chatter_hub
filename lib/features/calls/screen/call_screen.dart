import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/calls/model/call_model.dart';
import 'package:flutter_chatter_hub/features/calls/widgets/call_tile.dart';



class CallsScreen extends StatelessWidget {
  CallsScreen({super.key});

  final List<CallModel> calls = [
    CallModel(
      name: "harry",
      profilePic: "https://randomuser.me/api/portraits/men/1.jpg",
      time: "Today, 2:29 pm",
      isIncoming: true,
      count: 2,
    ),
    CallModel(
      name: "John",
      profilePic: "https://randomuser.me/api/portraits/men/2.jpg",
      time: "Today, 12:56 am",
      isIncoming: true,
    ),
    CallModel(
      name: "Nick",
      profilePic: "",
      time: "Yesterday, 10:16 pm",
      isIncoming: true,
      count: 3,
    ),
    CallModel(
      name: "Bob",
      profilePic: "https://randomuser.me/api/portraits/men/3.jpg",
      time: "Yesterday, 2:07 pm",
      isIncoming: false,
      isMissed: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Calls"),
        backgroundColor: Colors.black,
        actions: const [
          Icon(Icons.search),
          SizedBox(width: 12),
          Icon(Icons.more_vert),
        ],
      ),
      body: ListView(
        children: [
          const ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.favorite, color: Colors.white),
            ),
            title: Text("Add favourite", style: TextStyle(color: Colors.white)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Recent",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          ...calls.map((c) => CallTile(call: c)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add_call, color: Colors.white),
        onPressed: () {},
      ),
    );
  }
}
