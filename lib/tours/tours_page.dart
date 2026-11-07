import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/cancel_dialog.dart';
import '../common/errors.dart';
import '../common/format.dart';
import '../common/theme.dart';
import '../common/widgets.dart';
import '../creation/creation_page.dart' show TourRow;
import '../data/tontine_repository.dart';
import '../domain/day.dart';
import '../domain/tontine_terms.dart';
import '../payout/payout_page.dart';
import '../share/share_statement.dart';
import '../skips/skipped_days_page.dart';
import 'swap_page.dart';

enum TourStatus { done, current, next }

/// One row of the calendar, in display texts.
class TourEntry {
  const TourEntry({
    required this.tour,
    required this.who,
    required this.date,
    required this.status,
  });

  final int tour;
  final String who;
  final String date;
  final TourStatus status;
}

/// "dim. 11 oct.", with the year when it differs from today's.
String _day(Day day, Day today) =>
    formatDay(day, withYear: day.year != today.year);

/// Rows of "Calendrier des tours", in the mockup's wording.
List<TourEntry> tourEntries(TontineDetail detail, Day today) {
  final terms = detail.terms;
  final names = {for (final m in detail.members) m.id: m.name};
  final current = detail.today(today).currentTour;

  // "place 1 sur 2" numbering per member, in tour order.
  final placeCount = <String, int>{};
  for (final s in detail.slots) {
    if (s.halves == halvesPerPlace) {
      placeCount[s.memberId] = (placeCount[s.memberId] ?? 0) + 1;
    }
  }
  final placeSeen = <String, int>{};

  return [
    for (var tour = 1; tour <= terms.tours; tour++)
      () {
        final slots = [
          for (final s in detail.slots)
            if (s.tour == tour) s,
        ];
        final String who;
        if (slots.length == 2) {
          who = slots.map((s) => '${names[s.memberId]} ½').join(' + ');
        } else if (slots.length == 1) {
          final s = slots.single;
          final count = placeCount[s.memberId] ?? 1;
          final index = placeSeen[s.memberId] =
              (placeSeen[s.memberId] ?? 0) + 1;
          who = count > 1
              ? '${names[s.memberId]} · place $index sur $count'
              : names[s.memberId] ?? '';
        } else {
          who = '—';
        }
        final paidOut =
            slots.isNotEmpty &&
            slots.every((s) => detail.paidOutSlotIds.contains(s.id));
        final status = paidOut
            ? TourStatus.done
            : tour == current
            ? TourStatus.current
            : TourStatus.next;
        final day = _day(terms.payoutDay(tour), today);
        final date = switch (status) {
          TourStatus.done => '$day · ${formatFcfa(terms.potPerTour)} remis',
          TourStatus.current =>
            '$day · jours ${terms.firstDayOfTour(tour)} à '
                '${terms.lastDayOfTour(tour)}',
          TourStatus.next when slots.length == 2 =>
            '$day · ${formatFcfa(terms.potPerTour ~/ 2)} chacune',
          TourStatus.next when tour == terms.tours => '$day · dernier tour',
          TourStatus.next => day,
        };
        return TourEntry(tour: tour, who: who, date: date, status: status);
      }(),
  ];
}

/// "Tours" tab (mockup board "Calendrier des tours").
class ToursPage extends ConsumerWidget {
  const ToursPage({super.key, required this.tontineId});

  final String tontineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(tontineDetailProvider(tontineId));
    final today = ref.watch(todayProvider);
    return Scaffold(
      body: detail.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(child: Text('Lecture impossible : $error')),
        data: (detail) {
          final entries = tourEntries(detail, today);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 12,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(detail.name, style: AppText.caption),
                          const Text('Tours', style: AppText.screenTitle),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        textStyle: const TextStyle(
                          fontFamily: AppFonts.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => openSwap(context, tontineId: tontineId),
                      icon: const Icon(Icons.swap_vert, size: 16),
                      label: const Text('Échanger deux tours'),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                  'Seuls les tours pas encore ramassés peuvent être échangés. '
                  'L’échange reste dans l’historique.',
                  style: AppText.small,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _SkippedDaysRow(
                  detail: detail,
                  onTap: () => openSkippedDays(context, tontineId),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, i) => TourRow(
                    number: entries[i].tour,
                    who: entries[i].who,
                    date: entries[i].date,
                    trailing: _StatusPill(entries[i].status),
                    onTap: _onTap(context, ref, detail, entries[i], today),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _ShareButton(detail: detail, today: today),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A tour handed out offers to cancel its payout; the current tour, once
/// due, opens "Remise de la cagnotte".
VoidCallback? _onTap(
  BuildContext context,
  WidgetRef ref,
  TontineDetail detail,
  TourEntry entry,
  Day today,
) {
  final shares = detail.sharesOf(entry.tour);
  if (entry.status == TourStatus.done) {
    return () => _confirmCancelPayout(context, ref, detail, entry.tour);
  }
  final pending = [
    for (final s in shares)
      if (!detail.paidOutSlotIds.contains(s.id)) s,
  ];
  if (pending.isNotEmpty &&
      !today.isBefore(detail.terms.payoutDay(entry.tour))) {
    return () =>
        openPayout(context, tontineId: detail.id, slotId: pending.first.id);
  }
  return null;
}

Future<void> _confirmCancelPayout(
  BuildContext context,
  WidgetRef ref,
  TontineDetail detail,
  int tour,
) async {
  final names = {for (final m in detail.members) m.id: m.name};
  final payouts = [
    for (final s in detail.sharesOf(tour)) ?detail.payoutOf(s.id),
  ];
  if (payouts.isEmpty) return;
  final lines = [
    for (final p in payouts)
      '${formatFcfa(p.handed)} remis à '
          '${names[detail.slots.firstWhere((s) => s.id == p.slotId).memberId]} '
          'le ${formatDay(Day.parse(p.paidOn))}'
          '${p.withheld > 0 ? ', dont ${formatFcfa(p.withheld)} retenus' : ''}.',
  ];
  final reason = await showDialog<String>(
    context: context,
    builder: (_) => CancelDialog(
      title: 'Annuler la remise du tour $tour ?',
      body:
          '${lines.join('\n')}\nElle restera dans l’historique et le tour '
          'sera de nouveau à remettre.',
      action: 'Annuler la remise',
    ),
  );
  if (reason == null) return;
  try {
    for (final p in payouts) {
      await ref
          .read(tontineRepositoryProvider)
          .cancelPayout(p.id, reason: reason);
    }
    ref.invalidate(tontineDetailProvider(detail.id));
    ref.invalidate(tontineCardsProvider);
  } catch (error, stack) {
    logError(error, stack);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Annulation impossible.')));
    }
  }
}

/// "Partager l’état (PDF) sur WhatsApp": opens Android's share sheet with
/// the statement, WhatsApp being one tap away.
class _ShareButton extends ConsumerStatefulWidget {
  const _ShareButton({required this.detail, required this.today});

  final TontineDetail detail;
  final Day today;

  @override
  ConsumerState<_ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends ConsumerState<_ShareButton> {
  var _busy = false;

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      await shareStatement(ref, widget.detail, widget.today);
    } catch (error, stack) {
      logError(error, stack);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Partage impossible.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _busy ? null : _share,
      icon: const Icon(Icons.ios_share, size: 18),
      label: const Text('Partager l’état (PDF) sur WhatsApp'),
    );
  }
}

/// Mockup "Jours sautés", board 4: "Jours sautés · 2", the days, and how far
/// everything moved.
class _SkippedDaysRow extends StatelessWidget {
  const _SkippedDaysRow({required this.detail, required this.onTap});

  final TontineDetail detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final terms = detail.terms;
    final days = terms.skippedDays;
    final end = terms.dayOf(terms.totalDays);
    final shift = days.where((d) => !d.isAfter(end)).length;
    final listed = [for (final d in days.take(3)) formatDay(d)];
    if (days.length > 3) listed.add('…');
    final subtitle = days.isEmpty
        ? 'Fête, marché fermé : personne ne cotise ces jours-là'
        : [
            ...listed,
            if (shift > 0)
              'tout est décalé ${shift == 1 ? 'd’un jour' : 'de $shift jours'}',
          ].join(' · ');
    return RowCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.neutralPale,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_outlined,
              size: 18,
              color: AppColors.onNeutralPale,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 1,
              children: [
                Text(
                  days.isEmpty
                      ? 'Jours sautés'
                      : 'Jours sautés · ${days.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                Text(subtitle, style: AppText.small),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status);

  final TourStatus status;

  @override
  Widget build(BuildContext context) => switch (status) {
    TourStatus.done => const Pill(
      text: 'Remis',
      background: AppColors.primaryPale,
      foreground: AppColors.onPrimaryPale,
    ),
    TourStatus.current => const Pill(
      text: 'En cours',
      background: AppColors.primary,
      foreground: Colors.white,
    ),
    TourStatus.next => const Pill(
      text: 'À venir',
      background: AppColors.neutralPale,
      foreground: AppColors.onNeutralPale,
    ),
  };
}
