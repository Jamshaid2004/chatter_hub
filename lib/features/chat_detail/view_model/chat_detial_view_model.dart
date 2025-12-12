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

class ChatDetialViewModel extends ChangeNotifier {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  ValueNotifier<bool> isEmpty = ValueNotifier(true);

  void sendTextMessage({
    required String otherUserId,
    required String otherUserName,
    String? otherUserPfp,
  }) {
    try {
      if (messageController.text.trim().isEmpty) return;

      final uid = injector<SharedPref>().getValue('uid');
      final currentUsername = injector<SharedPref>().getValue('name') ?? 'No name';
      final currentUserPfp = injector<SharedPref>().getValue('profilePic') ?? '';

      final messageId = const Uuid().v4();

      final message = MessageModel(
        text: messageController.text.trim(),
        messageId: messageId,
        senderUserId: uid,
        timestamp: Timestamp.now(),
        type: MessageType.text,
      );

      final chatId = generateChatId(uid, otherUserId);

      injector<FirebaseFirestoreService>().sendMessage(
        currentUserId: uid,
        otherUserId: otherUserId,
        currentUserName: currentUsername,
        otherUserName: otherUserName,
        otherUserPfp: otherUserPfp,
        chatId: chatId,
        message: message,
        currentUserPfp: currentUserPfp,
      );

      messageController.clear();
    } catch (e) {
      debugPrint('Cannot send message: $e');
    }
  }

  Future<void> sendMediaMessage(File file, MessageType type,
      {required String otherUserId, required String otherUserName, String? otherUserPfp}) async {
    try {
      final uid = injector<SharedPref>().getValue('uid');
      final chatId = generateChatId(uid, otherUserId);

      /// Upload media
      final mediaUrl = await injector<FirebaseStorageService>().uploadChatMedia(
        file: file,
        chatId: chatId,
      );

      late final MessageModel msg;
      if (type == MessageType.image) {
        /// Create Image message
        msg = MessageModel(
          messageId: const Uuid().v4(),
          senderUserId: uid,
          imageUrl: mediaUrl,
          type: type,
          timestamp: Timestamp.now(),
        );
      } else {
        /// Create Video message
        msg = MessageModel(
          messageId: const Uuid().v4(),
          senderUserId: uid,
          videoUrl: mediaUrl,
          type: type,
          timestamp: Timestamp.now(),
        );
      }

      /// Save to firestore
      injector<FirebaseFirestoreService>().sendMessage(
        currentUserId: uid,
        otherUserId: otherUserId,
        currentUserName: injector<SharedPref>().getValue('name'),
        otherUserName: otherUserName,
        otherUserPfp: otherUserPfp,
        chatId: chatId,
        message: msg,
        currentUserPfp: injector<SharedPref>().getValue('profilePic'),
      );
    } catch (e) {
      debugPrint("Media send failed: $e");
    }
  }

  void pickMedia(String otherUserId, String otherUserName, String? otherUserPfp) async {
    try {
      final picker = ImagePicker();

      final XFile? pickedFile = await picker.pickMedia();
      if (pickedFile == null) return;

      final path = pickedFile.path.toLowerCase();

      // Debug
      debugPrint("Picked file path: $path");

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
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          otherUserPfp: otherUserPfp,
        );
      } else if (path.endsWith(".mp4") || path.endsWith(".mov") || path.endsWith(".mkv") || path.endsWith(".avi")) {
        debugPrint('Video picked');
        sendMediaMessage(
          File(pickedFile.path),
          MessageType.video,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          otherUserPfp: otherUserPfp,
        );
      }
    } catch (e) {
      debugPrint("Media pick error: $e");
    }
  }

  String generateChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  Stream<List<MessageModel>> listenToMessages(String otherUserId) {
    final userId = injector<SharedPref>().getValue('uid');
    return injector<FirebaseFirestoreService>()
        .listenToMessages(userId, generateChatId(injector<SharedPref>().getValue('uid'), otherUserId));
  }
}
