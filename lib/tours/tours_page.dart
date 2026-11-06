import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/format.dart';
import '../common/theme.dart';
import '../common/widgets.dart';
import '../creation/creation_page.dart' show TourRow;
import '../data/tontine_repository.dart';
import '../domain/day.dart';
import '../domain/tontine_terms.dart';

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
                      // Wired in step 4 (échange de tours).
                      onPressed: null,
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
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: OutlinedButton.icon(
                  // Wired in step 5 (partage PDF).
                  onPressed: null,
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: const Text('Partager l’état (PDF) sur WhatsApp'),
                ),
              ),
            ],
          );
        },
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
