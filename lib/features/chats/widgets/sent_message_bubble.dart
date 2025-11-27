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
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 249, 198, 238),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(text, style: const TextStyle(color: Colors.black)),
      ),
    );
  }
}
