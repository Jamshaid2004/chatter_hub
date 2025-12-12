import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/global/navigator_key.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/core/services/db/db_local_service.dart';
import 'package:flutter_chatter_hub/core/services/db/db_remote_service.dart';
import 'package:flutter_chatter_hub/core/utils/loader_utils/loader_utils.dart';
import 'package:flutter_chatter_hub/features/chats/model/chat_model.dart';
import 'package:flutter_chatter_hub/features/profile_info/model/profile_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class HomeViewModel extends ChangeNotifier {
  List<ChatModel> userChats = [];
  List<ChatModel> userGroups = [];
  ValueNotifier<List<ChatModel>> filteredUserChats = ValueNotifier([]);
  ValueNotifier<List<ChatModel>> filteredUserGroups = ValueNotifier([]);

  ValueNotifier<bool> isSearching = ValueNotifier(false);

  final TextEditingController searchController = TextEditingController();

  int tabBarIndex = 0;

  StreamSubscription? _chatsSub;
  StreamSubscription? _groupsSub;

  ProfileModel? appUser;

  void init() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showLoader();
      await fetchUser();
      await _initZegoCallInvitation();
      _listenToChats();
      _listenToGroups();
      hideLoader();
    });
  }

  Future<void> _initZegoCallInvitation() async {
    try {
      debugPrint("🔵 Initializing Zego for user: ${appUser!.uid}");
      // Request permissions FIRST
      await _requestPermissions();
      ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

      // Create signaling plugin instance
      final signalingPlugin = ZegoUIKitSignalingPlugin();
      
      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: 657066025,
        appSign: "36bcd473ea7cde6b22fd232e79031714380edde4c0aca2ebad14ca574e0526d5",
        userID: appUser!.uid,
        userName: appUser!.userName,
        plugins: [signalingPlugin],
        // Configure call based on type (audio or video)
        requireConfig: (ZegoCallInvitationData data) {
          // Check if it's a video call or voice call
          if (data.type == ZegoCallType.videoCall) {
            return ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();
          } else {
            return ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
          }
        },
      );

      // Wait for signaling plugin to connect (it connects automatically after init)
      // Give it some time to establish the connection - signaling connects asynchronously
      await Future.delayed(const Duration(milliseconds: 2000));
      
      debugPrint("✅ Zego initialized successfully");
      debugPrint("🔵 Signaling plugin connecting... (this happens asynchronously)");
      debugPrint("🔵 User ID: ${appUser!.uid}, User Name: ${appUser!.userName}");
    } catch (e) {
      debugPrint("Zego Init Error: $e");
    }
  }

  Future<void> _requestPermissions() async {
    // Add permission_handler package
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  Future<void> fetchUser() async {
    try {
      final userId = injector<SharedPref>().getValue('uid');
      final user = await injector<FirebaseFirestoreService>().getUser(userId);
      appUser = user;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void setTabBarIndex(int index) {
    tabBarIndex = index;
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
    }
  }

  void _listenToChats() {
    final userId = injector<SharedPref>().getValue('uid');

    _chatsSub = injector<FirebaseFirestoreService>().listenToUserChats(userId!).listen((chats) {
      debugPrint('Chats length is : ${chats.length}');
      userChats = chats;
      _applyChatSearch();
    });
  }

  void _listenToGroups() {
    final userId = injector<SharedPref>().getValue('uid');

    _groupsSub = injector<FirebaseFirestoreService>().listenToUserGroups(userId!).listen((groups) {
      userGroups = groups;
      _applyGroupSearch();
    });
  }

  void _applyChatSearch() {
    if (searchController.text.isNotEmpty) {
      searchUserChats(searchController.text);
    } else {
      filteredUserChats.value = userChats;
    }
  }

  void _applyGroupSearch() {
    if (searchController.text.isNotEmpty) {
      searchUserGroups(searchController.text);
    } else {
      filteredUserGroups.value = userGroups;
    }
  }

  void searchUserChats(String query) {
    if (query.isNotEmpty) {
      filteredUserChats.value = userChats.where((chat) => chat.name.toLowerCase().contains(query.toLowerCase())).toList();
    } else {
      filteredUserChats.value = userChats;
    }
  }

  void searchUserGroups(String query) {
    if (query.isNotEmpty) {
      filteredUserGroups.value = userGroups.where((group) => group.name.toLowerCase().contains(query.toLowerCase())).toList();
    } else {
      filteredUserGroups.value = userGroups;
    }
  }

  @override
  void dispose() {
    _chatsSub?.cancel();
    _groupsSub?.cancel();
    searchController.dispose();
    super.dispose();
  }

  static HomeViewModel getInstance([bool listen = false]) {
    return Provider.of<HomeViewModel>(navigatorKey.currentContext!, listen: listen);
  }
}
