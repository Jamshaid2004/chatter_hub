import 'package:flutter/material.dart';

class MaterialBase extends StatelessWidget {
  const MaterialBase({super.key, required this.child, this.onTap, this.onLongPress});

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(color: Colors.transparent, child: InkWell(onTap: onTap, onLongPress: onLongPress, child: child));
  }
}
