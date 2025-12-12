import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/home/view_model/home_view_model.dart';
import 'package:provider/provider.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (_, viewModel, __) => AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF48BB8),
        title: ValueListenableBuilder<bool>(
          valueListenable: viewModel.isSearching,
          builder: (context, searching, _) {
            return searching ? _buildSearchField(viewModel) : _buildTitle();
          },
        ),
        actions: [
          _buildActions(
            viewModel,
          )
        ],
        bottom: _buildTabBar(
          viewModel,
        ),
      ),
    );
  }

  Widget _buildSearchField(HomeViewModel viewmodel) {
    return TextField(
      controller: viewmodel.searchController,
      autofocus: true,
      style: const TextStyle(
        color: Color.fromARGB(226, 162, 55, 91),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      cursorColor: const Color.fromARGB(226, 162, 55, 91),
      decoration: InputDecoration(
        hintText: "Search ${viewmodel.tabBarIndex == 0 ? 'chats' : 'groups'}...",
        hintStyle: const TextStyle(
          color: Color.fromARGB(226, 162, 55, 91),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Color.fromARGB(226, 162, 55, 91), size: 20),
          onPressed: () {
            viewmodel.searchController.clear();
          },
        ),
      ),
      onChanged: (val) {
        if (viewmodel.tabBarIndex == 0) {
          viewmodel.searchUserChats(val);
        } else {
          viewmodel.searchUserGroups(val);
        }
      },
    );
  }

  Widget _buildTitle() {
    return const Text(
      "Chatter Hub",
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(226, 162, 55, 91),
      ),
    );
  }

  Widget _buildActions(HomeViewModel viewModel) {
    return ValueListenableBuilder<bool>(
      valueListenable: viewModel.isSearching,
      builder: (context, searching, _) {
        return Row(
          children: [
            IconButton(
              icon: Icon(searching ? Icons.close : Icons.search, color: const Color.fromARGB(226, 162, 55, 91)),
              onPressed: viewModel.toggleSearch,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Color.fromARGB(226, 162, 55, 91)),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildTabBar(HomeViewModel viewModel) {
    return TabBar(
      indicatorColor: const Color.fromARGB(226, 162, 55, 91),
      labelColor: const Color.fromARGB(226, 162, 55, 91),
      unselectedLabelColor: const Color.fromARGB(255, 175, 50, 92).withOpacity(0.6),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      onTap: (value) {
        viewModel.setTabBarIndex(value);
      },
      tabs: const [
        Tab(text: 'Chats'),
        Tab(text: 'Groups'),
      ],
    );
  }
}
