import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/confirm_dialog.dart';
import '../common/errors.dart';
import '../common/format.dart';
import '../common/theme.dart';
import '../data/tontine_repository.dart';
import '../domain/day.dart';
import 'reason_picker.dart';
import 'skip_texts.dart';

/// Opens "Sauter aujourd'hui ?" (mockup "Jours sautés", board 2).
Future<void> showSkipTodaySheet(
  BuildContext context, {
  required TontineDetail detail,
  required Day today,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final skipped = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim.withValues(alpha: 0.85),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SkipTodaySheet(detail: detail, today: today),
  );
  if (skipped == true) {
    messenger.showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.text,
        content: Text('Aujourd’hui est sauté : personne ne cotise.'),
      ),
    );
  }
}

class SkipTodaySheet extends ConsumerStatefulWidget {
  const SkipTodaySheet({super.key, required this.detail, required this.today});

  final TontineDetail detail;
  final Day today;

  @override
  ConsumerState<SkipTodaySheet> createState() => _SkipTodaySheetState();
}

class _SkipTodaySheetState extends ConsumerState<SkipTodaySheet> {
  String? _reason;
  var _saving = false;

  Future<void> _skip(SkipEffect effect) async {
    final confirmed = await confirmAction(
      context,
      title: 'Confirmer le saut ?',
      body:
          '${sentence('Personne ne cotise le ${formatDay(widget.today)}')} '
          '${sentence(effect.title)} Tu pourras l’annuler dans Tours › Jours sautés '
          'jusqu’à la fin de la journée.',
      action: 'Sauter aujourd’hui',
    );
    if (!confirmed || !mounted) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(tontineRepositoryProvider)
          .skipDays(
            tontineId: widget.detail.id,
            days: [widget.today],
            reason: _reason,
            today: widget.today,
          );
      unawaited(HapticFeedback.mediumImpact());
      ref.invalidate(tontineDetailProvider(widget.detail.id));
      ref.invalidate(tontineCardsProvider);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error, stack) {
      logError(error, stack);
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de sauter aujourd’hui.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effect = skipEffect(widget.detail, widget.today, {
      widget.today,
    }, todayOnly: true);
    final collected = widget.detail.today(widget.today).collectedToday;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.sheetHandle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                const Text(
                  'Sauter aujourd’hui ?',
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  '${formatDay(widget.today, withYear: true)} · personne ne '
                  'cotise aujourd’hui',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            ReasonPicker(onChanged: (reason) => _reason = reason),
            EffectBox(
              title: effect.title,
              lines: effect.lines,
              note: collected > 0
                  ? 'Les ${formatFcfa(collected)} déjà encaissés aujourd’hui '
                        'restent acquis : ils comptent pour les jours suivants.'
                  : null,
            ),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: AppFonts.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: _saving ? null : () => _skip(effect),
                    child: const Text('Sauter aujourd’hui'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
