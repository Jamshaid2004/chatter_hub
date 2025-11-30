

import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/chats/controller/chat_controller.dart';


import 'package:flutter_chatter_hub/features/chats/screen/chat_detail_screen.dart';

import 'package:flutter_chatter_hub/features/chats/widgets/chat_tile.dart';

class ChatList extends StatelessWidget {
  final ChatController controller;

  const ChatList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {

    
    // 👇 FIX 1: Listen to the chat data (controller.chats) for general updates
    return ValueListenableBuilder(
      valueListenable: controller.chats,
      builder: (context, _, __) {
        
        // 👇 FIX 2: Nest the listener for the search query (controller.query)
        return ValueListenableBuilder<String>(
          valueListenable: controller.query,
          builder: (context, _, __) {
            
            final filteredChats = controller.filteredChats;

            if (filteredChats.isEmpty) {
              // ... No chats found text ...
              return Center(
                child: Text(
                  controller.tabController.index == 0
                      ? 'No chats found'
                      : 'No groups found',
                  style: const TextStyle(color: Colors.pink, fontSize: 18),
                ),
              );
            }

            return ListView.separated(
              itemCount: filteredChats.length,
              itemBuilder: (context, index) {
                final chat = filteredChats[index]; // Use a final variable
                return ChatTile(
                  chat: chat,
                  onTap: () {
                   
                    
                    
                    Navigator.of(context).push(
                      
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          chat: chat, 
                        ),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => const Divider(
                color: Color.fromARGB(255, 255, 145, 183),
                indent: 70,
                thickness: 1.5,
              ),
            );
          },
        );
      },
    );
  }
}