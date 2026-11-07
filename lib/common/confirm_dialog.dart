import 'package:flutter/material.dart';

import 'theme.dart';

/// Asks before a sensitive action (skipping days, handing out a pot,
/// swapping tours), in the style of `CancelDialog`. Resolves to true only
/// when the action button is tapped.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
  String keep = 'Retour',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) =>
        ConfirmDialog(title: title, body: body, action: action, keep: keep),
  );
  return confirmed ?? false;
}

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.body,
    required this.action,
    this.keep = 'Retour',
  });

  final String title;
  final String body;

  /// Label of the confirming button ("Sauter 2 jours").
  final String action;

  /// Label of the button that leaves things as they are.
  final String keep;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
      content: Text(body, style: AppText.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(keep),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(
              fontFamily: AppFonts.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(action),
        ),
      ],
    );
  }
}
