import 'package:flutter/material.dart';

class UndoSnackBar {
  UndoSnackBar({
    required BuildContext context,
    required String content,
    required VoidCallback onUndo,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        action: SnackBarAction(label: "Rückgängig", onPressed: onUndo),
        duration: Duration(seconds: 10),
        persist: false,
      ),
    );
  }
}
