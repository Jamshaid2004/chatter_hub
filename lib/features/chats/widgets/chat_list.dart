import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/config/router.dart';
import 'package:flutter_chatter_hub/core/constants/app_routes_name.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/features/chats/model/chat_model.dart';
import 'package:flutter_chatter_hub/features/chats/widgets/chat_tile.dart';
import 'package:go_router/go_router.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key, required this.chats});

  final List<ChatModel> chats;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ChatTile(
          chat: chat,
          onTap: () => context.push(injector<AppRoutesName>().chatDetailScreen,
              extra: ChatDetailScreenInputParams(pfp: chat.profilePic, name: chat.name, userId: chat.id)),
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
