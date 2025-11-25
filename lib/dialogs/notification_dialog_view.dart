import 'package:flutter/material.dart';

class NotificationDialogView extends StatelessWidget {
  const NotificationDialogView({super.key, required this.onAllow, required this.onDontAllow});

  final VoidCallback onAllow;
  final VoidCallback onDontAllow;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title:const Text('Notifications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
       content: const Text(
        "Allow ChatterApp to send you notifications?",
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(onPressed: (onDontAllow), child:const Text('Dont Allow')),
         ElevatedButton(
          onPressed: onAllow,
          child: const Text("Allow"),
        ),
    
      ],
    );
  }
}