import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/enums/message_type.dart';
import 'package:flutter_chatter_hub/features/chats/model/chat_model.dart';
import 'package:flutter_chatter_hub/features/chats/model/message_model.dart';
import 'package:flutter_chatter_hub/features/group/model/group_model.dart';
import 'package:flutter_chatter_hub/features/profile_info/model/profile_model.dart';
import 'package:flutter_chatter_hub/features/status/model/status_model.dart';

class FirebaseFirestoreService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addUser(ProfileModel user) async {
    try {
      await _getUsersCollectionRef().doc(user.uid).set(user.toMap());
    } catch (e) {
      print(e);
    }
  }

// Add these methods to your FirebaseFirestoreService class

  /// Listen to all users (for group creation)
  Stream<List<ProfileModel>> listenToAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProfileModel.fromMap(doc.data()))
          .toList();
    });
  }

  /// Create a new group
  Future<void> createGroup({
    required String groupId,
    required String groupName,
    String? groupIcon,
    required List<String> members,
    required String createdBy,
  }) async {
    try {
      final group = GroupModel(
        groupId: groupId,
        groupName: groupName,
        groupIcon: groupIcon,
        members: members,
        createdBy: createdBy,
        createdAt: Timestamp.now(),
        lastMessage: 'Group created',
        lastMessageTime: Timestamp.now(),
      );

      await _firestore.collection('groups').doc(groupId).set(group.toMap());

      // Add group reference to each member's document
      for (String memberId in members) {
        await _firestore.collection('users').doc(memberId).update({
          'groups': FieldValue.arrayUnion([groupId]),
        });
      }

      debugPrint('✅ Group created: $groupId');
    } catch (e) {
      debugPrint('❌ Error creating group: $e');
      rethrow;
    }
  }

  /// Listen to user's groups
  Stream<List<ChatModel>> listenToUserGroups(String userId) {
    return _firestore
        .collection('groups')
        .where('members', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final group = GroupModel.fromMap(doc.data());
        return ChatModel(
          id: group.groupId,
          name: group.groupName,
          lastMessage: group.lastMessage,
          time: group.lastMessageTime.toDate(),
          profilePic: group.groupIcon,
        );
      }).toList();
    });
  }

  /// Send message to group
  Future<void> sendGroupMessage({
    required String groupId,
    required String senderUserId,
    required String senderUserName,
    required MessageModel message,
  }) async {
    try {
      // Add message to group's messages subcollection
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .doc(message.messageId)
          .set(message.toMap());

      // Update group's last message
      String lastMessageText;
      switch (message.type) {
        case MessageType.text:
          lastMessageText = '$senderUserName: ${message.text}';
          break;
        case MessageType.image:
          lastMessageText = '$senderUserName sent an image';
          break;
        case MessageType.video:
          lastMessageText = '$senderUserName sent a video';
          break;
        case MessageType.audio:
          lastMessageText = '$senderUserName sent a voice message';
          break;
        default:
          lastMessageText = '$senderUserName sent a message';
      }

      await _firestore.collection('groups').doc(groupId).update({
        'lastMessage': lastMessageText,
        'lastMessageTime': message.timestamp,
        'lastMessageData': message.toMap(),
      });

      debugPrint('✅ Group message sent');
    } catch (e) {
      debugPrint('❌ Error sending group message: $e');
      rethrow;
    }
  }

  /// Listen to group messages
  Stream<List<MessageModel>> listenToGroupMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data()))
          .toList();
    });
  }

  /// Get group details
  Future<GroupModel?> getGroup(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      if (doc.exists) {
        return GroupModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting group: $e');
      return null;
    }
  }

  /// Add member to group
  Future<void> addMemberToGroup(String groupId, String userId) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([userId]),
      });

      await _firestore.collection('users').doc(userId).update({
        'groups': FieldValue.arrayUnion([groupId]),
      });

      debugPrint('✅ Member added to group');
    } catch (e) {
      debugPrint('❌ Error adding member to group: $e');
      rethrow;
    }
  }

  /// Remove member from group
  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayRemove([userId]),
      });

      await _firestore.collection('users').doc(userId).update({
        'groups': FieldValue.arrayRemove([groupId]),
      });

      debugPrint('✅ Member removed from group');
    } catch (e) {
      debugPrint('❌ Error removing member from group: $e');
      rethrow;
    }
  }

  /// Delete group
  Future<void> deleteGroup(String groupId) async {
    try {
      // Get all members
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (groupDoc.exists) {
        final group = GroupModel.fromMap(groupDoc.data()!);

        // Remove group reference from all members
        for (String memberId in group.members) {
          await _firestore.collection('users').doc(memberId).update({
            'groups': FieldValue.arrayRemove([groupId]),
          });
        }

        // Delete all messages in the group
        final messages = await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('messages')
            .get();

        final batch = _firestore.batch();
        for (var doc in messages.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        // Delete the group document
        await _firestore.collection('groups').doc(groupId).delete();

        debugPrint('✅ Group deleted');
      }
    } catch (e) {
      debugPrint('❌ Error deleting group: $e');
      rethrow;
    }
  }
  // Add these methods to your FirebaseFirestoreService class

  /// Listen to all statuses
  Stream<List<StatusModel>> listenToStatuses() {
    return _firestore
        .collection('statuses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StatusModel.fromMap(doc.data()))
          .toList();
    });
  }

  /// Add a status item to user's status
  Future<void> addStatusItem({
    required String userId,
    required String userName,
    required String userProfilePic,
    required StatusItemModel statusItem,
  }) async {
    try {
      final statusRef = _firestore.collection('statuses').doc(userId);
      final statusDoc = await statusRef.get();

      if (statusDoc.exists) {
        // Update existing status
        final existingStatus = StatusModel.fromMap(statusDoc.data()!);

        // Check if status is expired
        if (existingStatus.isExpired) {
          // Delete old status and create new one
          await statusRef.delete();
          await _createNewStatus(
            userId: userId,
            userName: userName,
            userProfilePic: userProfilePic,
            statusItem: statusItem,
          );
        } else {
          // Add to existing status
          await statusRef.update({
            'statusItems': FieldValue.arrayUnion([statusItem.toMap()]),
          });
        }
      } else {
        // Create new status
        await _createNewStatus(
          userId: userId,
          userName: userName,
          userProfilePic: userProfilePic,
          statusItem: statusItem,
        );
      }

      debugPrint('✅ Status item added');
    } catch (e) {
      debugPrint('❌ Error adding status item: $e');
      rethrow;
    }
  }

  Future<void> _createNewStatus({
    required String userId,
    required String userName,
    required String userProfilePic,
    required StatusItemModel statusItem,
  }) async {
    final status = StatusModel(
      statusId: userId,
      userId: userId,
      userName: userName,
      userProfilePic: userProfilePic,
      statusItems: [statusItem],
      createdAt: Timestamp.now(),
    );

    await _firestore.collection('statuses').doc(userId).set(status.toMap());
  }

  /// Delete a specific status item
  Future<void> deleteStatusItem(String statusId, String itemId) async {
    try {
      final statusRef = _firestore.collection('statuses').doc(statusId);
      final statusDoc = await statusRef.get();

      if (!statusDoc.exists) return;

      final status = StatusModel.fromMap(statusDoc.data()!);
      final updatedItems =
          status.statusItems.where((item) => item.itemId != itemId).toList();

      if (updatedItems.isEmpty) {
        // Delete entire status if no items left
        await statusRef.delete();
      } else {
        // Update with remaining items
        await statusRef.update({
          'statusItems': updatedItems.map((item) => item.toMap()).toList(),
        });
      }

      debugPrint('✅ Status item deleted');
    } catch (e) {
      debugPrint('❌ Error deleting status item: $e');
      rethrow;
    }
  }

  /// Mark status item as viewed
  Future<void> markStatusItemAsViewed(
    String statusId,
    String itemId,
    String viewerId,
  ) async {
    try {
      final statusRef = _firestore.collection('statuses').doc(statusId);
      final statusDoc = await statusRef.get();

      if (!statusDoc.exists) return;

      final status = StatusModel.fromMap(statusDoc.data()!);
      final updatedItems = status.statusItems.map((item) {
        if (item.itemId == itemId && !item.viewedBy.contains(viewerId)) {
          return StatusItemModel(
            itemId: item.itemId,
            imageUrl: item.imageUrl,
            uploadedAt: item.uploadedAt,
            viewedBy: [...item.viewedBy, viewerId],
          );
        }
        return item;
      }).toList();

      await statusRef.update({
        'statusItems': updatedItems.map((item) => item.toMap()).toList(),
      });
    } catch (e) {
      debugPrint('❌ Error marking status as viewed: $e');
    }
  }

  /// Delete expired statuses (call this periodically or via cloud function)
  Future<void> deleteExpiredStatuses() async {
    try {
      final now = Timestamp.now();
      final twentyFourHoursAgo = Timestamp.fromDate(
        now.toDate().subtract(const Duration(hours: 24)),
      );

      final expiredStatuses = await _firestore
          .collection('statuses')
          .where('createdAt', isLessThan: twentyFourHoursAgo)
          .get();

      final batch = _firestore.batch();
      for (var doc in expiredStatuses.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('✅ Deleted ${expiredStatuses.docs.length} expired statuses');
    } catch (e) {
      debugPrint('❌ Error deleting expired statuses: $e');
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
      final currentUserChatRef = _getUsersCollectionRef()
          .doc(currentUserId)
          .collection('chats')
          .doc(chatId);

      final otherUserChatRef = _getUsersCollectionRef()
          .doc(otherUserId)
          .collection('chats')
          .doc(chatId);

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
      await currentUserChatRef
          .collection('messages')
          .doc(message.messageId)
          .set(message.toMap());

      //  Save message for other user
      await otherUserChatRef
          .collection('messages')
          .doc(message.messageId)
          .set(message.toMap());
    } catch (e) {
      print("Send message failed: $e");
    }
  }

  void deleteMessage(
      {required String currentUserId,
      required String chatId,
      required String messageId}) {
    try {
      _getUsersCollectionRef()
          .doc(currentUserId)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print(e.toString());
    }
  }

  void updateLastMessage(
      String userId, String chatId, String lastMessage, DateTime time) async {
    try {
      _getUsersCollectionRef()
          .doc(userId)
          .collection('chats')
          .doc(chatId)
          .update({'lastMessage': lastMessage, 'time': time});
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
