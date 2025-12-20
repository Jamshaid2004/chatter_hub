import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chatter_hub/core/enums/message_type.dart';

class MessageModel {
  final String messageId;
  final String senderUserId;
  final String? text;
  final String? imageUrl;
  final String? videoUrl;
  final String? audioUrl;
  final MessageType type;
  final Timestamp timestamp;

  MessageModel({
    required this.messageId,
    required this.senderUserId,
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
      'text': text,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'audioUrl': audioUrl,
      'type': type.name,
      'timestamp': timestamp,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'],
      senderUserId: map['senderUserId'],
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
