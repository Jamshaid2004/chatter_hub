import 'package:flutter/material.dart';

class CameraPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDontAllow;

  const CameraPermissionDialog({
    super.key,
    required this.onAllow,
    required this.onDontAllow,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Camera Access',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        "Allow ChatterApp to access your photos and videos on this device?",
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(onPressed: onDontAllow, child: const Text("Don't Allow")),
        ElevatedButton(onPressed: onAllow, child: const Text("Allow")),
      ],
    );
  }
}
