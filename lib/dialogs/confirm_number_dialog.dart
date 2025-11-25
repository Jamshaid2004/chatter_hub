import 'package:flutter/material.dart';

class ConfirmNumberDialogView extends StatelessWidget {
  const ConfirmNumberDialogView({
    super.key,
    required this.enteredNumber,
    required this.onEdit,
    required this.onOk,
  });

  final String enteredNumber;
  final VoidCallback onEdit;
  final VoidCallback onOk;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Confirm Number',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      content: Text(
        "You entered the number:\n\n$enteredNumber\n\nIs this OK or would you like to edit it?",
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: onEdit,
          child: const Text("Edit"),
        ),
        ElevatedButton(
          onPressed: onOk,
          child: const Text("OK"),
        ),
      ],
    );
  }
}
