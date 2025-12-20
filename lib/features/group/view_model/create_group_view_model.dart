import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/core/services/db/db_local_service.dart';
import 'package:flutter_chatter_hub/core/services/db/db_remote_service.dart';
import 'package:flutter_chatter_hub/core/services/storage_service.dart';
import 'package:flutter_chatter_hub/features/profile_info/model/profile_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CreateGroupViewModel extends ChangeNotifier {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  ValueNotifier<List<ProfileModel>> selectedUsers = ValueNotifier([]);
  List<ProfileModel> allUsers = [];
  List<ProfileModel> filteredUsers = [];
  File? groupIconPath;

  void init() {
    // Initial setup if needed
  }

  Stream<List<ProfileModel>> listenToUsers() {
    final currentUserId = injector<SharedPref>().getValue('uid');

    return injector<FirebaseFirestoreService>().listenToAllUsers().map((users) {
      // Filter out current user
      allUsers = users.where((user) => user.uid != currentUserId).toList();
      return allUsers;
    });
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      filteredUsers = [];
    } else {
      filteredUsers = allUsers
          .where((user) =>
              user.userName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void toggleUserSelection(ProfileModel user) {
    final selected = List<ProfileModel>.from(selectedUsers.value);

    if (selected.any((u) => u.uid == user.uid)) {
      selected.removeWhere((u) => u.uid == user.uid);
    } else {
      selected.add(user);
    }

    selectedUsers.value = selected;
    notifyListeners();
  }

  Future<void> pickGroupIcon(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        groupIconPath = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error picking group icon: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> createGroup(BuildContext context) async {
    // Validation
    if (groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedUsers.value.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 2 members'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Colors.pinkAccent),
        ),
      );

      final currentUserId = injector<SharedPref>().getValue('uid')!;
      final groupId = const Uuid().v4();

      // Upload group icon if selected
      String? groupIconUrl;
      if (groupIconPath != null) {
        groupIconUrl = await injector<FirebaseStorageService>()
            .uploadGroupIcon(groupIconPath!, groupId);
      }

      // Create member list (include current user)
      final memberIds = <String>[
        currentUserId,
        ...selectedUsers.value.map((u) => u.uid),
      ];

      // Create group in Firestore
      await injector<FirebaseFirestoreService>().createGroup(
        groupId: groupId,
        groupName: groupNameController.text.trim(),
        groupIcon: groupIconUrl,
        members: memberIds,
        createdBy: currentUserId,
      );

      debugPrint('✅ Group created successfully');

      if (context.mounted) {
        // Close loading dialog
        Navigator.pop(context);
        // Close create group screen
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Group created successfully'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error creating group: $e');

      if (context.mounted) {
        // Close loading dialog
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating group: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    groupNameController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
