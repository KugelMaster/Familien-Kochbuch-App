import 'package:flutter/material.dart';

class DeletePrompt {
  /// Shows the user a delete prompt with the options to cancel or to accept.
  /// Returns [true], if the user confirmed, [false] otherwise.
  static Future<bool> open({
    required BuildContext context,
    required String title,
    required String content,
  }) async => await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 40),
      title: Text(title, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            content,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text("Abbrechen"),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade800,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Ja, löschen"),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    ),
  ) ?? false;
}
