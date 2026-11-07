import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/domain/day.dart';
import 'package:matontine/domain/overview.dart';
import 'package:matontine/domain/standing.dart';
import 'package:matontine/domain/today.dart';

import 'maquette_example.dart';

void main() {
  // The mockup's "Jours sautés": on Friday 6 November, the 8th and the 11th
  // are skipped.
  final skipped = exampleTerms.withSkippedDays([
    Day(2026, 11, 8),
    Day(2026, 11, 11),
  ]);

  test('payouts and the end move back by the days skipped before them', () {
    // Only the 8th falls before day 40: one day later.
    expect(skipped.payoutDay(4), Day(2026, 11, 10));
    // Both skips before tour 5: two days later.
    expect(skipped.payoutDay(5), Day(2026, 11, 21));
    expect(skipped.payoutDay(9), Day(2026, 12, 31));
    expect(skipped.payoutDay(20), Day(2027, 4, 20));
    // Tours paid out before the skips do not move.
    expect(skipped.payoutDay(3), exampleTerms.payoutDay(3));
  });

  test('a skipped day keeps the number of the day before it', () {
    expect(skipped.dayNumber(Day(2026, 11, 7)), 38);
    expect(skipped.dayNumber(Day(2026, 11, 8)), 38);
    expect(skipped.dayNumber(Day(2026, 11, 9)), 39);
    expect(skipped.dayOf(39), Day(2026, 11, 9));
    expect(skipped.isSkipped(Day(2026, 11, 8)), isTrue);
    expect(skipped.isSkipped(Day(2026, 11, 9)), isFalse);
  });

  test('days before the start and duplicates are ignored', () {
    final terms = exampleTerms.withSkippedDays([
      Day(2026, 9, 30),
      Day(2026, 11, 8),
      Day(2026, 11, 8),
    ]);
    expect(terms.skippedDays, [Day(2026, 11, 8)]);
  });

  group('skipping today (6 November, day 37)', () {
    final terms = exampleTerms.withSkippedDays([Day(2026, 11, 6)]);
    final today = Day(2026, 11, 6);
    final n = terms.dayNumber(today);
    final yesterday = terms.dayNumber(today.addDays(-1));

    test('today counts as day 36, and nothing is to collect', () {
      expect(n, 36);
      expect(yesterday, 36);
      expect(terms.payoutDay(4), Day(2026, 11, 10));
      expect(terms.payoutDay(20), Day(2027, 4, 19));
    });

    test('late members stay late, the others are up to date or ahead', () {
      Standing s(int paidDays) => standingOf(
        terms,
        halves: 2,
        paid: paidDays * 5000,
        today: n,
        yesterday: yesterday,
      );
      // Awa paid through day 34: still late, now 10 000 F.
      expect(s(34).kind, StandingKind.late);
      expect(s(34).badgeAmount, 10000);
      // Paid through day 35 only: late too, never "à encaisser".
      expect(s(35).kind, StandingKind.late);
      expect(s(36).kind, StandingKind.upToDate);
      // Paid this morning before the skip: ahead.
      expect(s(37).kind, StandingKind.ahead);
      expect(s(37).badgeAmount, 5000);
    });

    test('"Aujourd\'hui" expects nothing today', () {
      final view = todayView(
        terms,
        today: today,
        members: [
          const MemberData(
            id: 'awa',
            name: 'Awa Koné',
            position: 0,
            halves: 2,
            paid: 34 * 5000,
            paidToday: 0,
          ),
          const MemberData(
            id: 'koffi',
            name: 'Koffi Yao',
            position: 1,
            halves: 2,
            paid: 37 * 5000,
            paidToday: 5000,
          ),
        ],
        // Tours 1 to 3 are handed out; tour 4 is Koffi's.
        slots: const [
          SlotInfo(id: 's1', tour: 1, memberId: 'awa', halves: 2),
          SlotInfo(id: 's2', tour: 2, memberId: 'awa', halves: 2),
          SlotInfo(id: 's3', tour: 3, memberId: 'awa', halves: 2),
          SlotInfo(id: 's4', tour: 4, memberId: 'koffi', halves: 2),
        ],
        paidOutSlotIds: const {'s1', 's2', 's3'},
      );
      expect(view.todaySkipped, isTrue);
      expect(view.dayNumber, 36);
      expect(view.expectedToday, 0);
      expect(view.collectedToday, 5000);
      expect(view.toCollectCount, 1);
      expect(view.lateCount, 1);
      expect(view.payoutDay, Day(2026, 11, 10));
    });
  });
}
