import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/enums/message_type.dart';
import 'package:flutter_chatter_hub/features/chats/model/chat_model.dart';
import 'package:flutter_chatter_hub/features/chats/model/message_model.dart';
import 'package:flutter_chatter_hub/features/profile_info/model/profile_model.dart';

class FirebaseFirestoreService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addUser(ProfileModel user) async {
    try {
      await _getUsersCollectionRef().doc(user.uid).set(user.toMap());
    } catch (e) {
      print(e);
    }
  }

  Future<ProfileModel?> getUser(String uid) async {
    try {
      final userDoc = await _getUsersCollectionRef().doc(uid).get();
      return ProfileModel.fromMap(userDoc.data()!);
    } catch (e) {
      return null;
    }
  }

  Stream<List<ChatModel>> listenToUserChats(String uid) {
    debugPrint('uid : $uid');
    return _getUsersCollectionRef()
        .doc(uid)
        .collection('chats')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((e) {
              debugPrint(e.data().toString());
              return ChatModel.fromMap(e.data());
            }).toList());
  }

  Stream<List<ChatModel>> listenToUserGroups(String userId) {
    return _getGroupsCollectionRef()
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((e) => ChatModel.fromMap(e.data())).toList());
  }

  Future<void> sendMessage({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    String? currentUserPfp,
    required String otherUserName,
    String? otherUserPfp,
    required String chatId,
    required MessageModel message,
  }) async {
    try {
      final currentUserChatRef = _getUsersCollectionRef().doc(currentUserId).collection('chats').doc(chatId);

      final otherUserChatRef = _getUsersCollectionRef().doc(otherUserId).collection('chats').doc(chatId);

      //  Chat document for current user (stores OTHER user's data)
      await currentUserChatRef.set({
        'id': otherUserId,
        'name': otherUserName,
        'profilePic': otherUserPfp,
        'lastMessage': message.type == MessageType.text
            ? message.text
            : message.type == MessageType.image
                ? "[Image]"
                : "[Video]",
        'time': DateTime.now().toIso8601String(),
        'isGroup': false,
        'members': null,
      }, SetOptions(merge: true));

      //  Chat document for other user (stores CURRENT user's data)
      await otherUserChatRef.set({
        'id': currentUserId,
        'name': currentUserName,
        'profilePic': currentUserPfp,
        'lastMessage': message.type == MessageType.text
            ? message.text
            : message.type == MessageType.image
                ? "[Image]"
                : "[Video]",
        'time': DateTime.now().toIso8601String(),
        'isGroup': false,
        'members': null,
      }, SetOptions(merge: true));

      //  Save message for current user
      await currentUserChatRef.collection('messages').doc(message.messageId).set(message.toMap());

      //  Save message for other user
      await otherUserChatRef.collection('messages').doc(message.messageId).set(message.toMap());
    } catch (e) {
      print("Send message failed: $e");
    }
  }

  void deleteMessage({required String currentUserId, required String chatId, required String messageId}) {
    try {
      _getUsersCollectionRef().doc(currentUserId).collection('chats').doc(chatId).collection('messages').doc(messageId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  void updateLastMessage(String userId, String chatId, String lastMessage, DateTime time) async {
    try {
      _getUsersCollectionRef().doc(userId).collection('chats').doc(chatId).update({'lastMessage': lastMessage, 'time': time});
    } catch (e) {}
  }

  Stream<List<MessageModel>> listenToMessages(String userId, chatId) {
    return _getUsersCollectionRef()
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((e) => e.docs.map((e) => MessageModel.fromMap(e.data())).toList());
  }

  Future<List<ProfileModel>> getAllUsers() async {
    try {
      final usersSnapshot = await _getUsersCollectionRef().get();
      final List<ProfileModel> users = [];
      for (var element in usersSnapshot.docs) {
        final user = ProfileModel.fromMap(element.data());
        users.add(user);
      }
      return users;
    } catch (e) {
      return [];
    }
  }

  /// User collection Ref
  CollectionReference<Map<String, dynamic>> _getUsersCollectionRef() {
    return _firestore.collection('users');
  }

  // Groups collection Ref
  CollectionReference<Map<String, dynamic>> _getGroupsCollectionRef() {
    return _firestore.collection('groups');
  }
}
