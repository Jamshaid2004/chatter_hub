import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String groupId;
  final String groupName;
  final String? groupIcon;
  final List<String> members;
  final String createdBy;
  final Timestamp createdAt;
  final String lastMessage;
  final Timestamp lastMessageTime;
  final Map<String, dynamic>? lastMessageData;

  GroupModel({
    required this.groupId,
    required this.groupName,
    this.groupIcon,
    required this.members,
    required this.createdBy,
    required this.createdAt,
    this.lastMessage = '',
    required this.lastMessageTime,
    this.lastMessageData,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      groupId: map['groupId'] ?? '',
      groupName: map['groupName'] ?? '',
      groupIcon: map['groupIcon'],
      members: List<String>.from(map['members'] ?? []),
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] ?? Timestamp.now(),
      lastMessageData: map['lastMessageData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'groupIcon': groupIcon,
      'members': members,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastMessageData': lastMessageData,
    };
  }

  GroupModel copyWith({
    String? groupId,
    String? groupName,
    String? groupIcon,
    List<String>? members,
    String? createdBy,
    Timestamp? createdAt,
    String? lastMessage,
    Timestamp? lastMessageTime,
    Map<String, dynamic>? lastMessageData,
  }) {
    return GroupModel(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      groupIcon: groupIcon ?? this.groupIcon,
      members: members ?? this.members,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageData: lastMessageData ?? this.lastMessageData,
    );
  }
}
