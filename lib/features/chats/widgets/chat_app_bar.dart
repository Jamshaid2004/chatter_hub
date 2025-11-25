import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/chats/controller/chat_controller.dart';


class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatController controller;

  const ChatAppBar({super.key, required this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color.fromARGB(255, 244, 181, 225),
      title: ValueListenableBuilder<bool>(
        valueListenable: controller.isSearching,
        builder: (context, searching, _) {
          return searching ? _buildSearchField() : _buildTitle();
        },
      ),
      actions: [_buildActions()],
      bottom: _buildTabBar(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: controller.searchController,
      autofocus: true,
      style: const TextStyle(
        color: Colors.pink,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      cursorColor: Colors.pink,
      decoration: InputDecoration(
        hintText: "Search ${controller.tabController.index == 0 ? 'chats' : 'groups'}...",
        hintStyle: const TextStyle(
          color: Colors.pink,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.pink, size: 20),
          onPressed: () {
            controller.searchController.clear();
            controller.query.value = "";
          },
        ),
      ),
      onChanged: (val) => controller.query.value = val,
    );
  }

  Widget _buildTitle() {
    return const Text(
      "Chatter Hub",
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.pink,
      ),
    );
  }

  Widget _buildActions() {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isSearching,
      builder: (context, searching, _) {
        return Row(
          children: [
            IconButton(
              icon: Icon(searching ? Icons.close : Icons.search, color: Colors.pink),
              onPressed: controller.toggleSearch,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.pink),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: controller.tabController,
      indicatorColor: Colors.pink,
      labelColor: Colors.pink,
      unselectedLabelColor: Colors.pink.withOpacity(0.6),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      tabs: const [
        Tab(text: 'Chats'),
        Tab(text: 'Groups'),
      ],
    );
  }
}