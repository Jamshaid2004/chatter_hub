import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/calls/model/call_model.dart';

class CallTile extends StatelessWidget {
  final CallModel call;

  const CallTile({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final statusColor = call.isMissed ? Colors.red : Colors.green;
    final arrowIcon = call.isIncoming ? Icons.call_received : Icons.call_made;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: call.profilePic.isNotEmpty ? NetworkImage(call.profilePic) : null,
        child: call.profilePic.isEmpty ? Text(call.name[0]) : null,
      ),
      title: Text(
        "${call.name}${call.count > 1 ? " (${call.count})" : ""}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: call.isMissed ? Colors.red : Colors.white,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(arrowIcon, size: 16, color: statusColor),
          const SizedBox(width: 4),
          Text(call.time, style: const TextStyle(color: Colors.grey)),
        ],
      ),
      trailing: const Icon(Icons.call, color: Colors.teal),
    );
  }
}
