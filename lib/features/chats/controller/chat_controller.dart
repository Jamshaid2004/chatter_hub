import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/chats/model/chat_model.dart';

class ChatController {
  final ValueNotifier<bool> isSearching = ValueNotifier(false);
  final ValueNotifier<String> query = ValueNotifier("");
  final TextEditingController searchController = TextEditingController();
  final TabController tabController;

  ChatController({required this.tabController});

  final List<ChatModel> mockChats = [
    ChatModel(
      name: "Esmee Kirrily",
      lastMessage: "recording audio...",
      time: "18:28",
      profilePic: "https://plus.unsplash.com/premium_photo-1665772801542-e9cc7bc60a30?w=600&auto=format&fit=crop&q=60",
    ),
    ChatModel(
      name: "Issy Lina",
      lastMessage: "typing...",
      time: "18:09",
      profilePic: "https://plus.unsplash.com/premium_photo-1665772801542-e9cc7bc60a30?w=600&auto=format&fit=crop&q=60",
    ),
    ChatModel(
      name: "Lexie",
      lastMessage: "0:18",
      time: "16:10",
      profilePic: "https://plus.unsplash.com/premium_photo-1665772801542-e9cc7bc60a30?w=600&auto=format&fit=crop&q=60",
    ),
    ChatModel(
      name: "Flutter Devs Group",
      lastMessage: "John: Check this new package",
      time: "18:28",
      profilePic: "https://plus.unsplash.com/premium_photo-1665772801542-e9cc7bc60a30?w=600&auto=format&fit=crop&q=60",
      isGroup: true,
    ),
  ];

  List<ChatModel> get filteredChats {
    final searchText = query.value.toLowerCase().trim();
    final isGroupsTab = tabController.index == 1;

    return mockChats.where((chat) {
      final matchesType = isGroupsTab ? chat.isGroup : !chat.isGroup;
      final matchesSearch = searchText.isEmpty || 
          chat.name.toLowerCase().contains(searchText);
      return matchesType && matchesSearch;
    }).toList();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      query.value = "";
    }
  }

  void dispose() {
    searchController.dispose();
  }
}