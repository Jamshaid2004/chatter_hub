import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/status/model/status_model.dart';

class UserStatusTile extends StatelessWidget {
  final StatusModel status;

  const UserStatusTile({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: const Color.fromARGB(255, 230, 136, 167),
            child: CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(status.profilePic),
            ),
          ),
          title: Text(
            status.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(status.time),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 80, right: 20),
          child: Divider(
            thickness: 0.5,
            color: Color.fromARGB(255, 187, 52, 97),
          ),
        )
      ],
    );
  }
}
