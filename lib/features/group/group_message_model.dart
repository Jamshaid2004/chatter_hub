import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chatter_hub/core/enums/message_type.dart';

class GroupMessageModel {
  final String messageId;
  final String senderUserId;
  final String senderUserName;
  final String? text;
  final String? imageUrl;
  final String? videoUrl;
  final String? audioUrl;
  final MessageType type;
  final Timestamp timestamp;

  GroupMessageModel({
    required this.messageId,
    required this.senderUserId,
    required this.senderUserName,
    this.text,
    required this.type,
    required this.timestamp,
    this.imageUrl,
    this.videoUrl,
    this.audioUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderUserId': senderUserId,
      'senderUserName': senderUserName,
      'text': text,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'audioUrl': audioUrl,
      'type': type.name,
      'timestamp': timestamp,
    };
  }

  factory GroupMessageModel.fromMap(Map<String, dynamic> map) {
    return GroupMessageModel(
      messageId: map['messageId'],
      senderUserId: map['senderUserId'],
      senderUserName: map['senderUserName'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      audioUrl: map['audioUrl'],
      type: MessageType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      timestamp: map['timestamp'],
    );
  }
}
