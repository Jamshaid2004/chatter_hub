import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/chats/model/chat_model.dart';


class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(chat.profilePic),
        radius: 27,
      ),
      title: Text(
        chat.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        chat.time,
        style: const TextStyle(color: Color.fromARGB(255, 122, 122, 122), fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}
