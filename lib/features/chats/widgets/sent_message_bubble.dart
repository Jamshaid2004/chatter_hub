import 'package:flutter/material.dart';

class SentMessageBubble extends StatelessWidget {
  final String text;
  const SentMessageBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8B8E3),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(1, 2),
            )
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
