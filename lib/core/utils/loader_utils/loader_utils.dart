import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/global/navigator_key.dart';
import 'package:flutter_chatter_hub/core/shared/widgets/custom_loader/custom_loader.dart';
import 'package:flutter_chatter_hub/core/shared/widgets/material_base.dart';

/// Variable to check iaf the loader is visible
bool _isLoading = false;

///Show the loader
void showLoader({BuildContext? context, String? text}) {
  if (_isLoading) return;

  _showLoadingDialog(context: context, text: text);
  _isLoading = true;
}

///Hide the loader
void hideLoader({BuildContext? context}) {
  if (!_isLoading) return;

  _hideLoadingDialog(context: context);
  _isLoading = false;
}

/// Show the loading dialog
Future<void> _showLoadingDialog({BuildContext? context, String? text}) {
  return showDialog(
    barrierDismissible: false,
    context: context ?? navigatorKey.currentContext!,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    builder: (context) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SpinKitFadingCircle(color: Colors.pink, size: 50.0),
            if (text != null) ...[
              const SizedBox(height: 8),
              MaterialBase(child: Text(text, style: const TextStyle(color: Colors.white))),
            ],
          ],
        ),
      );
    },
  );
}

/// Hide our current dialog
void _hideLoadingDialog({BuildContext? context}) => Navigator.of(context ?? navigatorKey.currentContext!).pop();
