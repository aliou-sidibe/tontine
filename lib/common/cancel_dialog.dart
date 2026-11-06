import 'package:flutter/material.dart';

import 'theme.dart';
import 'widgets.dart';

/// Asks for a cancellation by counter-entry, with an optional reason.
/// Returns the reason (possibly empty), or null when the user keeps the
/// entry. The dialog owns its text field, so it is disposed with it.
class CancelDialog extends StatefulWidget {
  const CancelDialog({
    super.key,
    required this.title,
    required this.body,
    required this.action,
  });

  final String title;
  final String body;

  /// Label of the cancelling button ("Annuler le versement").
  final String action;

  @override
  State<CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<CancelDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        widget.title,
        style: const TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(widget.body, style: AppText.body),
          LabeledBox(
            label: 'Motif (facultatif)',
            child: BareInput(controller: _reason, hint: 'erreur de saisie'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Garder'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.onWarningPale),
          onPressed: () => Navigator.of(context).pop(_reason.text),
          child: Text(widget.action),
        ),
      ],
    );
  }
}
