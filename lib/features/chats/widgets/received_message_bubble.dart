import 'package:flutter/material.dart';

class ReceivedMessageBubble extends StatelessWidget {
  final String text;
  const ReceivedMessageBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 242, 101, 148),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(text, style: const TextStyle(color: Color.fromARGB(255, 6, 2, 2))),
      ),
    );
  }
}
