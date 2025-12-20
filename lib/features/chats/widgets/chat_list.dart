import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/config/router.dart';
import 'package:flutter_chatter_hub/core/constants/app_routes_name.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/features/chats/model/chat_model.dart';
import 'package:flutter_chatter_hub/features/chats/widgets/chat_tile.dart';
import 'package:flutter_chatter_hub/features/group/view/group_chat_screen.dart';
import 'package:go_router/go_router.dart';

class ChatList extends StatelessWidget {
  const ChatList({
    super.key,
    required this.chats,
    required this.isGroup,
  });

  final List<ChatModel> chats;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isGroup ? Icons.group : Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isGroup ? 'No groups yet' : 'No chats yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isGroup
                  ? 'Create a group to get started'
                  : 'Start a conversation',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ChatTile(
          chat: chat,
          isGroup: isGroup,
          onTap: () {
            if (isGroup) {
              // Navigate to group chat screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupChatScreen(
                    groupId: chat.id,
                    groupName: chat.name,
                    groupIcon: chat.profilePic,
                  ),
                ),
              );
            } else {
              // Navigate to one-on-one chat
              context.push(
                injector<AppRoutesName>().chatDetailScreen,
                extra: ChatDetailScreenInputParams(
                  pfp: chat.profilePic,
                  name: chat.name,
                  userId: chat.id,
                ),
              );
            }
          },
        );
      },
      separatorBuilder: (context, index) => const Divider(
        color: Color.fromARGB(255, 255, 145, 183),
        indent: 30,
        endIndent: 30,
        thickness: 1.5,
      ),
    );
  }
}
