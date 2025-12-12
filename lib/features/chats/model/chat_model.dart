// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

class ChatModel {
  final String name;
  final String id;
  final String lastMessage;
  final DateTime time;
  final String? profilePic;
  final bool isGroup;
  final List<String>? members;

  ChatModel({
    required this.name,
    required this.id,
    required this.lastMessage,
    required this.time,
    required this.profilePic,
    this.isGroup = false,
    this.members = const [],
  });

  ChatModel copyWith({
    String? name,
    String? chatId,
    String? lastMessage,
    DateTime? time,
    String? profilePic,
    bool? isGroup,
    List<String>? members,
  }) {
    return ChatModel(
      name: name ?? this.name,
      id: chatId ?? id,
      lastMessage: lastMessage ?? this.lastMessage,
      time: time ?? this.time,
      profilePic: profilePic ?? this.profilePic,
      isGroup: isGroup ?? this.isGroup,
      members: members ?? this.members,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'id': id,
      'lastMessage': lastMessage,
      'time': time,
      'profilePic': profilePic,
      'isGroup': isGroup,
      'members': members,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    debugPrint('Profile pic in map : ${map['profilePic']}');
    return ChatModel(
      name: map['name'] ?? '',
      id: map['id'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      time: _parseTime(map['time']),
      profilePic: map['profilePic'],
      isGroup: map['isGroup'] ?? false,
      members: List<String>.from((map['members'] ?? [])),
    );
  }

  static DateTime _parseTime(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value);
    } catch (_) {
      return DateTime.now();
    }
  }

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) => ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatModel(name: $name, chatId: $id, lastMessage: $lastMessage, time: $time, profilePic: $profilePic, isGroup: $isGroup)';
  }

  @override
  bool operator ==(covariant ChatModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.id == id &&
        other.lastMessage == lastMessage &&
        other.time == time &&
        other.profilePic == profilePic &&
        other.isGroup == isGroup;
  }

  @override
  int get hashCode {
    return name.hashCode ^ id.hashCode ^ lastMessage.hashCode ^ time.hashCode ^ profilePic.hashCode ^ isGroup.hashCode;
  }
}
