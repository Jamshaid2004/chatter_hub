import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/constants/app_routes_name.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/features/chats/model/chat_model.dart';
import 'package:flutter_chatter_hub/features/chats/widgets/chat_app_bar.dart';
import 'package:flutter_chatter_hub/features/chats/widgets/chat_list.dart';
import 'package:flutter_chatter_hub/features/group/view/create_group_screen.dart';
import 'package:flutter_chatter_hub/features/home/view_model/home_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (_, viewModel, __) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: const ChatAppBar(),
          body: TabBarView(
            children: [
              // Chats Tab
              ValueListenableBuilder<List<ChatModel>>(
                valueListenable: viewModel.filteredUserChats,
                builder: (context, chats, _) => ChatList(
                  chats: chats,
                  isGroup: false,
                ),
              ),
              // Groups Tab
              ValueListenableBuilder<List<ChatModel>>(
                valueListenable: viewModel.filteredUserGroups,
                builder: (context, groups, _) => ChatList(
                  chats: groups,
                  isGroup: true,
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.pink,
            onPressed: () {
              // Check which tab is active
              if (viewModel.tabBarIndex == 0) {
                // Chats tab - navigate to add user
                context.push(injector<AppRoutesName>().addUserScreen);
              } else {
                // Groups tab - navigate to create group
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateGroupScreen(),
                  ),
                );
              }
            },
            child: Icon(
              viewModel.tabBarIndex == 0 ? Icons.chat : Icons.group_add,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
