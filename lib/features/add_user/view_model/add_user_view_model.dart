import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/core/services/db/db_local_service.dart';
import 'package:flutter_chatter_hub/core/services/db/db_remote_service.dart';
import 'package:flutter_chatter_hub/core/utils/loader_utils/loader_utils.dart';
import 'package:flutter_chatter_hub/features/profile_info/model/profile_model.dart';

class AddUserViewModel extends ChangeNotifier {
  List<ProfileModel> allUsers = [];
  ValueNotifier<List<ProfileModel>> filteredUsers = ValueNotifier([]);

  final TextEditingController searchController = TextEditingController();

  void init() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await loadUsers();
    });
  }

  void searchUsers(String value) {
    if (value.isEmpty) {
      filteredUsers.value = allUsers
          .where(
            (element) => element.uid != injector<SharedPref>().getValue('uid'),
          )
          .toList();
    } else {
      filteredUsers.value = filteredUsers.value.where((user) => user.phoneNumber.contains(value)).toList();
    }
  }

  Future<void> loadUsers() async {
    try {
      // Show laoder
      showLoader();
      allUsers = await injector<FirebaseFirestoreService>().getAllUsers();
      if (allUsers.isNotEmpty) {
        filteredUsers.value = allUsers
            .where(
              (element) => element.uid != injector<SharedPref>().getValue('uid'),
            )
            .toList();
      }
      // Hide loader
      hideLoader();
    } catch (e) {
      // Hide loader
      hideLoader();
      debugPrint(e.toString());
    }
  }
}
