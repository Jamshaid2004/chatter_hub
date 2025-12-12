import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/enums/message_type.dart';
import 'package:flutter_chatter_hub/features/chat_detail/view/widgets/video_preview.dart';
import 'package:flutter_chatter_hub/features/chats/model/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe
        ? const Color(0xFFF8B8E3) // sent
        : const Color(0xFFE76B9A); // received

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: _bubblePadding(),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(1, 2),
            )
          ],
        ),
        child: _buildContent(context),
      ),
    );
  }

  EdgeInsets _bubblePadding() {
    switch (message.type) {
      case MessageType.text:
        return const EdgeInsets.symmetric(vertical: 10, horizontal: 14);
      case MessageType.image:
      case MessageType.video:
        return const EdgeInsets.all(6);
    }
  }

  Widget _buildContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.text!,
          style: TextStyle(
            color: isMe ? Colors.black87 : Colors.white,
            fontSize: 15,
          ),
        );

      case MessageType.image:
        return _buildImageBubble();

      case MessageType.video:
        return WhatsAppVideoBubble(url: message.videoUrl!, isSent: isMe);
    }
  }

  Widget _buildImageBubble() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        message.imageUrl ?? "",
        width: 220,
        height: 250,
        fit: BoxFit.cover,
      ),
    );
  }
}
