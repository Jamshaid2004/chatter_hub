import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/constants/app_routes_name.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/features/chats/model/chat_model.dart';
import 'package:flutter_chatter_hub/features/chats/widgets/chat_app_bar.dart';
import 'package:flutter_chatter_hub/features/chats/widgets/chat_list.dart';
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
              ValueListenableBuilder<List<ChatModel>>(
                  valueListenable: viewModel.filteredUserChats, builder: (context, chats, _) => ChatList(chats: chats)),
              ValueListenableBuilder<List<ChatModel>>(
                  valueListenable: viewModel.filteredUserGroups, builder: (context, chats, _) => ChatList(chats: chats)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.pink,
            onPressed: () {
              context.push(injector<AppRoutesName>().addUserScreen);
            },
            child: const Icon(Icons.chat, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
