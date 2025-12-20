import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/chats/model/chat_model.dart';

class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;
  final bool isGroup;

  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
    this.isGroup = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage:
                chat.profilePic != null ? NetworkImage(chat.profilePic!) : null,
            backgroundColor: isGroup
                ? const Color.fromARGB(255, 187, 52, 97)
                : Colors.grey[300],
            radius: 27,
            child: chat.profilePic == null
                ? Icon(
                    isGroup ? Icons.group : Icons.person,
                    size: 30,
                    color: Colors.white,
                  )
                : null,
          ),
          // Group indicator badge
          if (isGroup)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 187, 52, 97),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        chat.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chat.lastMessage,
        style: const TextStyle(color: Colors.black),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        formatChatTime(chat.time),
        style: const TextStyle(
          color: Color.fromARGB(255, 122, 122, 122),
          fontSize: 12,
        ),
      ),
      onTap: onTap,
    );
  }

  /* ----------------------------- Helper Methods ----------------------------- */

  String formatChatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    // Today: show HH:mm (e.g. 4:22 PM)
    if (difference.inDays == 0) {
      return "${_two(time.hour)}:${_two(time.minute)}";
    }

    // Yesterday
    if (difference.inDays == 1) {
      return "Yesterday";
    }

    // This week: show weekday (Mon, Tue…)
    if (difference.inDays < 7) {
      const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      return weekdays[time.weekday - 1];
    }

    // Older: show dd/MM/yyyy
    return "${_two(time.day)}/${_two(time.month)}/${time.year}";
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}
