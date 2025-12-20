import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/enums/message_type.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/core/services/db/db_local_service.dart';
import 'package:flutter_chatter_hub/core/services/db/db_remote_service.dart';
import 'package:flutter_chatter_hub/core/services/storage_service.dart';
import 'package:flutter_chatter_hub/features/chats/model/message_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class GroupChatViewModel extends ChangeNotifier {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  ValueNotifier<bool> isEmpty = ValueNotifier(true);

  void sendTextMessage({required String groupId}) {
    try {
      if (messageController.text.trim().isEmpty) return;

      final uid = injector<SharedPref>().getValue('uid');
      final currentUsername =
          injector<SharedPref>().getValue('name') ?? 'No name';

      final messageId = const Uuid().v4();

      final message = MessageModel(
        text: messageController.text.trim(),
        messageId: messageId,
        senderUserId: uid,
        timestamp: Timestamp.now(),
        type: MessageType.text,
      );

      injector<FirebaseFirestoreService>().sendGroupMessage(
        groupId: groupId,
        senderUserId: uid,
        senderUserName: currentUsername,
        message: message,
      );

      messageController.clear();
    } catch (e) {
      debugPrint('Cannot send message: $e');
    }
  }

  Future<void> sendMediaMessage(
    File file,
    MessageType type, {
    required String groupId,
  }) async {
    try {
      final uid = injector<SharedPref>().getValue('uid');
      final currentUsername =
          injector<SharedPref>().getValue('name') ?? 'Unknown';

      // Upload media
      final mediaUrl =
          await injector<FirebaseStorageService>().uploadGroupMedia(
        file: file,
        groupId: groupId,
      );

      late final MessageModel msg;
      if (type == MessageType.image) {
        msg = MessageModel(
          messageId: const Uuid().v4(),
          senderUserId: uid,
          imageUrl: mediaUrl,
          type: type,
          timestamp: Timestamp.now(),
        );
      } else {
        msg = MessageModel(
          messageId: const Uuid().v4(),
          senderUserId: uid,
          videoUrl: mediaUrl,
          type: type,
          timestamp: Timestamp.now(),
        );
      }

      // Save to firestore
      injector<FirebaseFirestoreService>().sendGroupMessage(
        groupId: groupId,
        senderUserId: uid,
        senderUserName: currentUsername,
        message: msg,
      );
    } catch (e) {
      debugPrint("Media send failed: $e");
    }
  }

  void pickMedia(String groupId) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickMedia();

      if (pickedFile == null) return;

      final path = pickedFile.path.toLowerCase();

      if (path.endsWith(".jpg") ||
          path.endsWith(".jpeg") ||
          path.endsWith(".png") ||
          path.endsWith(".heic") ||
          path.endsWith(".gif") ||
          path.endsWith(".webp")) {
        debugPrint('Image picked');
        sendMediaMessage(
          File(pickedFile.path),
          MessageType.image,
          groupId: groupId,
        );
      } else if (path.endsWith(".mp4") ||
          path.endsWith(".mov") ||
          path.endsWith(".mkv") ||
          path.endsWith(".avi")) {
        debugPrint('Video picked');
        sendMediaMessage(
          File(pickedFile.path),
          MessageType.video,
          groupId: groupId,
        );
      }
    } catch (e) {
      debugPrint("Media pick error: $e");
    }
  }

  Stream<List<MessageModel>> listenToGroupMessages(String groupId) {
    return injector<FirebaseFirestoreService>().listenToGroupMessages(groupId);
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
