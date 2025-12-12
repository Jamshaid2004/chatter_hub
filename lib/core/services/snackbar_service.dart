import 'package:flutter/material.dart';

class SnackBarService {
  /// invoke to show message snackbar
  void showMessage(BuildContext context, String message, [Color? backgroundColor]) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
              const Icon(
                Icons.error,
                color: Colors.white,
              ),
            ],
          ),
          backgroundColor: backgroundColor ??= Colors.black.withValues(alpha: 0.5),
        ),
      );
  }

  /// invoke to show failure snackbar
  void failure(BuildContext context, {String? msg, SnackBarBehavior? behavior, EdgeInsetsGeometry? margin}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: behavior ?? SnackBarBehavior.fixed,
          margin: margin,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  msg ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  maxLines: 2,
                ),
              ),
              const Icon(Icons.error),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
  }

  /// invoke to show success snackbar
  void success(BuildContext context, String msg, {SnackBarBehavior? behavior}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: behavior ?? SnackBarBehavior.fixed,
          content: Row(
            children: <Widget>[
              Expanded(child: Text(msg, style: const TextStyle(color: Colors.white), maxLines: 5)),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
  }
}
