import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/core/services/db/db_local_service.dart';
import 'package:flutter_chatter_hub/core/services/db/db_remote_service.dart';
import 'package:flutter_chatter_hub/core/services/storage_service.dart';
import 'package:flutter_chatter_hub/features/status/model/status_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class StatusViewModel extends ChangeNotifier {
  List<StatusModel> allStatuses = [];
  StatusModel? myStatus;
  ValueNotifier<bool> isUploading = ValueNotifier(false);

  Stream<List<StatusModel>> listenToStatuses() {
    final currentUserId = injector<SharedPref>().getValue('uid');

    return injector<FirebaseFirestoreService>()
        .listenToStatuses()
        .map((statuses) {
      // Filter out expired statuses
      final validStatuses =
          statuses.where((status) => !status.isExpired).toList();

      // Separate my status from others
      myStatus = validStatuses.firstWhere(
        (status) => status.userId == currentUserId,
        orElse: () => StatusModel(
          statusId: '',
          userId: '',
          userName: '',
          userProfilePic: '',
          statusItems: [],
          createdAt: Timestamp.now(),
        ),
      );

      // Get other users' statuses
      allStatuses = validStatuses
          .where((status) => status.userId != currentUserId)
          .toList();

      // Sort by most recent
      allStatuses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      notifyListeners();
      return allStatuses;
    });
  }

  Future<void> uploadStatus(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile == null) return;

      isUploading.value = true;

      final currentUserId = injector<SharedPref>().getValue('uid');
      final currentUserName =
          injector<SharedPref>().getValue('name') ?? 'Unknown';
      final currentUserPfp =
          injector<SharedPref>().getValue('profilePic') ?? '';

      // Upload image to storage
      final imageUrl = await injector<FirebaseStorageService>()
          .uploadStatusImage(File(pickedFile.path), currentUserId!);

      debugPrint('✅ Image uploaded: $imageUrl');

      // Create status item
      final statusItem = StatusItemModel(
        itemId: const Uuid().v4(),
        imageUrl: imageUrl,
        uploadedAt: Timestamp.now(),
        viewedBy: [],
      );

      // Add to existing status or create new one
      await injector<FirebaseFirestoreService>().addStatusItem(
        userId: currentUserId,
        userName: currentUserName,
        userProfilePic: currentUserPfp,
        statusItem: statusItem,
      );

      isUploading.value = false;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Status uploaded successfully'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      debugPrint('✅ Status uploaded successfully');
    } catch (e) {
      isUploading.value = false;
      debugPrint('❌ Error uploading status: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> deleteStatusItem(String statusId, String itemId) async {
    try {
      await injector<FirebaseFirestoreService>()
          .deleteStatusItem(statusId, itemId);
      debugPrint('✅ Status item deleted');
    } catch (e) {
      debugPrint('❌ Error deleting status item: $e');
    }
  }

  Future<void> markStatusAsViewed(String statusId, String itemId) async {
    try {
      final currentUserId = injector<SharedPref>().getValue('uid');
      await injector<FirebaseFirestoreService>()
          .markStatusItemAsViewed(statusId, itemId, currentUserId!);
    } catch (e) {
      debugPrint('❌ Error marking status as viewed: $e');
    }
  }
}
