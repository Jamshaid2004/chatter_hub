import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/chats/controller/chat_controller.dart';

import 'package:flutter_chatter_hub/features/chats/widgets/chat_app_bar.dart';
import 'package:flutter_chatter_hub/features/chats/widgets/chat_list.dart';
import 'package:flutter_chatter_hub/features/chats/widgets/custom_bottom_nav.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ChatController _chatController;
  final ValueNotifier<int> _currentIndex = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chatController = ChatController(tabController: _tabController);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(controller: _chatController),
      body: TabBarView(
        controller: _tabController,
        children: [
          ChatList(controller: _chatController),
          ChatList(controller: _chatController),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _currentIndex,
        builder: (context, index, _) {
          return CustomBottomNav(
            currentIndex: index,
            onTap: (newIndex) => _currentIndex.value = newIndex,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.pink,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}