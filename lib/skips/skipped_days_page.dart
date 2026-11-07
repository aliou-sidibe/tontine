import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/errors.dart';
import '../common/format.dart';
import '../common/theme.dart';
import '../common/widgets.dart';
import '../data/tontine_repository.dart';
import '../domain/day.dart';
import 'reason_picker.dart';
import 'skip_texts.dart';

/// Opens "Jours sautés" over the bottom bar.
Future<void> openSkippedDays(BuildContext context, String tontineId) =>
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => SkippedDaysPage(tontineId: tontineId),
      ),
    );

/// "Jours sautés" (mockup "Jours sautés", board 6).
class SkippedDaysPage extends ConsumerWidget {
  const SkippedDaysPage({super.key, required this.tontineId});

  final String tontineId;

  Future<void> _unskip(
    BuildContext context,
    WidgetRef ref,
    String id,
    Day day,
    Day today,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(tontineRepositoryProvider).unskipDay(id, today: today);
      ref.invalidate(tontineDetailProvider(tontineId));
      ref.invalidate(tontineCardsProvider);
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.text,
          content: Text(
            'Le ${formatDay(day)} redevient un jour de cotisation.',
          ),
        ),
      );
    } catch (error, stack) {
      logError(error, stack);
      messenger.showSnackBar(
        const SnackBar(content: Text('Annulation impossible.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(tontineDetailProvider(tontineId));
    final today = ref.watch(todayProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BackHeader(
              title: 'Jours sautés',
              bottom: 8,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: detail.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) =>
                    Center(child: Text('Lecture impossible : $error')),
                data: (detail) {
                  final terms = detail.terms;
                  final end = terms.dayOf(terms.totalDays);
                  final skippedBeforeEnd = terms.skippedDays
                      .where((d) => !d.isAfter(end))
                      .length;
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Ces jours-là, personne ne cotise. Les ramassages et '
                          'la fin de la tontine sont décalés d’autant.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.cardBorder),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            const Text(
                              'FIN DE LA TONTINE',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              formatDay(end, withYear: true),
                              style: const TextStyle(
                                fontFamily: AppFonts.display,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              skippedBeforeEnd == 0
                                  ? 'Comme prévu'
                                  : skippedBeforeEnd == 1
                                  ? '1 jour plus tard que prévu'
                                  : '$skippedBeforeEnd jours plus tard que '
                                        'prévu',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (detail.skippedDays.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'Aucun jour sauté pour l’instant.',
                            style: AppText.caption,
                          ),
                        )
                      else
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.cardBorder),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              for (final (i, row) in detail.skippedDays.indexed)
                                _SkippedRow(
                                  day: Day.parse(row.day),
                                  reason: row.reason,
                                  last: i == detail.skippedDays.length - 1,
                                  // A day already passed stays skipped.
                                  onCancel: Day.parse(row.day).isBefore(today)
                                      ? null
                                      : () => _unskip(
                                          context,
                                          ref,
                                          row.id,
                                          Day.parse(row.day),
                                          today,
                                        ),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Un jour passé reste dans la liste, sans « Annuler ».',
                          style: AppText.small,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ChooseSkipDaysPage(tontineId: tontineId),
                  ),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Sauter des jours'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A skipped day: date (600 14 px), reason, and "Annuler" while it is to come.
class _SkippedRow extends StatelessWidget {
  const _SkippedRow({
    required this.day,
    required this.reason,
    required this.last,
    required this.onCancel,
  });

  final Day day;
  final String? reason;
  final bool last;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 1,
              children: [
                Text(
                  formatDay(day, withYear: true),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                if (reason != null) Text(reason!, style: AppText.small),
              ],
            ),
          ),
          if (onCancel != null)
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onWarningPale,
                minimumSize: const Size(44, 44),
                textStyle: const TextStyle(
                  fontFamily: AppFonts.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: onCancel,
              child: const Text('Annuler'),
            ),
        ],
      ),
    );
  }
}

/// "Sauter des jours" (mockup "Jours sautés", board 5): a month calendar where
/// today and later days are picked.
class ChooseSkipDaysPage extends ConsumerStatefulWidget {
  const ChooseSkipDaysPage({super.key, required this.tontineId});

  final String tontineId;

  @override
  ConsumerState<ChooseSkipDaysPage> createState() => _ChooseSkipDaysState();
}

class _ChooseSkipDaysState extends ConsumerState<ChooseSkipDaysPage> {
  final _chosen = <Day>{};
  String? _reason;
  var _saving = false;

  /// First day of the month shown.
  late Day _month = () {
    final today = ref.read(todayProvider);
    return Day(today.year, today.month, 1);
  }();

  void _toggle(Day day) {
    HapticFeedback.selectionClick();
    setState(
      () => _chosen.contains(day) ? _chosen.remove(day) : _chosen.add(day),
    );
  }

  Future<void> _skip(Day today) async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final count = _chosen.length;
    try {
      await ref
          .read(tontineRepositoryProvider)
          .skipDays(
            tontineId: widget.tontineId,
            days: _chosen,
            reason: _reason,
            today: today,
          );
      unawaited(HapticFeedback.mediumImpact());
      ref.invalidate(tontineDetailProvider(widget.tontineId));
      ref.invalidate(tontineCardsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.text,
          content: Text(count == 1 ? '1 jour sauté' : '$count jours sautés'),
        ),
      );
    } catch (error, stack) {
      logError(error, stack);
      if (mounted) {
        setState(() => _saving = false);
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible de sauter ces jours (une cagnotte a peut-être '
              'déjà été remise ce jour-là).',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(tontineDetailProvider(widget.tontineId));
    final today = ref.watch(todayProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BackHeader(
              title: 'Sauter des jours',
              bottom: 8,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: detail.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) =>
                    Center(child: Text('Lecture impossible : $error')),
                data: (detail) {
                  final after = detail.terms.withSkippedDays(_chosen);
                  final end = after.dayOf(after.totalDays);
                  final effect = _chosen.isEmpty
                      ? null
                      : skipEffect(detail, today, _chosen);
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Choisis un ou plusieurs jours, à partir '
                          'd’aujourd’hui.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MonthCalendar(
                        month: _month,
                        today: today,
                        firstDay: detail.terms.firstDay,
                        lastDay: end,
                        skipped: detail.terms.skippedDays.toSet(),
                        chosen: _chosen,
                        onToggle: _toggle,
                        onMonth: (month) => setState(() => _month = month),
                      ),
                      const SizedBox(height: 12),
                      ReasonPicker(onChanged: (reason) => _reason = reason),
                      if (effect != null) ...[
                        const SizedBox(height: 12),
                        EffectBox(title: effect.title, lines: effect.lines),
                      ],
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),
            BottomAction(
              label: _chosen.isEmpty
                  ? 'Choisis les jours à sauter'
                  : _chosen.length == 1
                  ? 'Sauter 1 jour'
                  : 'Sauter ${_chosen.length} jours',
              onPressed: _chosen.isEmpty || _saving ? null : () => _skip(today),
            ),
          ],
        ),
      ),
    );
  }
}

const _monthNames = [
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre',
];

/// The month grid of the mockup: past days greyed, today circled, chosen
/// days in green, days already skipped in grey.
class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.month,
    required this.today,
    required this.firstDay,
    required this.lastDay,
    required this.skipped,
    required this.chosen,
    required this.onToggle,
    required this.onMonth,
  });

  final Day month;
  final Day today;
  final Day firstDay;
  final Day lastDay;
  final Set<Day> skipped;
  final Set<Day> chosen;
  final ValueChanged<Day> onToggle;
  final ValueChanged<Day> onMonth;

  Day _shift(int months) {
    final index = month.year * 12 + month.month - 1 + months;
    return Day(index ~/ 12, index % 12 + 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final next = _shift(1);
    final canBack = month.isAfter(Day(today.year, today.month, 1));
    final canNext = !next.isAfter(lastDay);
    final daysInMonth = month.daysUntil(next);
    final leading = month.weekday - 1;
    final earliest = today.isBefore(firstDay) ? firstDay : today;

    return Semantics(
      label: 'Calendrier',
      container: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          spacing: 6,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'Mois précédent',
                  color: AppColors.text,
                  onPressed: canBack ? () => onMonth(_shift(-1)) : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${_monthNames[month.month - 1]} ${month.year}',
                  style: const TextStyle(
                    fontFamily: AppFonts.display,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                IconButton(
                  tooltip: 'Mois suivant',
                  color: AppColors.text,
                  onPressed: canNext ? () => onMonth(next) : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 1.1,
              children: [
                for (final letter in const ['L', 'M', 'M', 'J', 'V', 'S', 'D'])
                  Center(
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                for (var i = 0; i < leading; i++) const SizedBox.shrink(),
                for (var d = 1; d <= daysInMonth; d++)
                  _DayCell(
                    day: Day(month.year, month.month, d),
                    enabled:
                        !Day(month.year, month.month, d).isBefore(earliest) &&
                        !Day(month.year, month.month, d).isAfter(lastDay) &&
                        !skipped.contains(Day(month.year, month.month, d)),
                    isToday: Day(month.year, month.month, d) == today,
                    skipped: skipped.contains(Day(month.year, month.month, d)),
                    chosen: chosen.contains(Day(month.year, month.month, d)),
                    onTap: onToggle,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.enabled,
    required this.isToday,
    required this.skipped,
    required this.chosen,
    required this.onTap,
  });

  final Day day;
  final bool enabled;
  final bool isToday;
  final bool skipped;
  final bool chosen;
  final ValueChanged<Day> onTap;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    if (chosen) {
      background = AppColors.primary;
      foreground = Colors.white;
    } else if (skipped) {
      background = AppColors.neutralPale;
      foreground = AppColors.onNeutralPale;
    } else {
      background = Colors.transparent;
      foreground = enabled
          ? (isToday ? AppColors.primary : AppColors.text)
          : AppColors.textTertiary;
    }
    return Semantics(
      button: enabled,
      selected: chosen,
      label: skipped ? '${formatDay(day)}, déjà sauté' : formatDay(day),
      excludeSemantics: true,
      child: Center(
        child: InkResponse(
          onTap: enabled ? () => onTap(day) : null,
          radius: 22,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: isToday && !chosen
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
            ),
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: chosen || isToday
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
