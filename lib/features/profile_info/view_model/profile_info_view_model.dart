import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/constants/app_routes_name.dart';
import 'package:flutter_chatter_hub/core/global/navigator_key.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/core/services/db/db_local_service.dart';
import 'package:flutter_chatter_hub/core/services/db/db_remote_service.dart';
import 'package:flutter_chatter_hub/core/services/snackbar_service.dart';
import 'package:flutter_chatter_hub/core/services/storage_service.dart';
import 'package:flutter_chatter_hub/core/utils/loader_utils/loader_utils.dart';
import 'package:flutter_chatter_hub/features/profile_info/model/profile_model.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProfileInfoViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();

  ValueNotifier<File?> profileImage = ValueNotifier(null);

  void createUser() async {
    try {
      if (nameController.text.trim().isEmpty) {
        injector<SnackBarService>().showMessage(navigatorKey.currentContext!, 'Please enter name');
        return;
      }
      // Show loader
      showLoader();
      String? profilePic;
      final userId = const Uuid().v4();
      if (profileImage.value != null) {
        profilePic = await injector<FirebaseStorageService>().uploadImage(filePath: profileImage.value!.path, userId: userId);
      }
      final phoneNumber = injector<SharedPref>().getValue('phoneNumber');

      final appUser = ProfileModel(uid: userId, userName: nameController.text.trim(), profilePic: profilePic, phoneNumber: phoneNumber);

      await injector<FirebaseFirestoreService>().addUser(appUser);
      // Hide loader
      hideLoader();

      injector<SharedPref>().saveValue('isAuthCompleted', true);
      injector<SharedPref>().saveValue('uid', userId);
      injector<SharedPref>().saveValue('name', nameController.text.trim());
      if (profilePic != null) injector<SharedPref>().saveValue('profilePic', profilePic);
      // Go to home screen
      navigatorKey.currentContext!.go(injector<AppRoutesName>().homeScreen);
    } catch (e) {
      // Hide loader
      hideLoader();
      injector<SnackBarService>().showMessage(navigatorKey.currentContext!, e.toString());
    }
  }

  void pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      profileImage.value = File(pickedImage.path);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
