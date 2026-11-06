import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/domain/day.dart';
import 'package:matontine/domain/overview.dart';
import 'package:matontine/domain/payout.dart';

import 'maquette_example.dart';

/// One full place per tour: slot `s<tour>` belongs to `m<tour>`.
final _slots = [
  for (var t = 1; t <= 20; t++)
    SlotInfo(id: 's$t', tour: t, memberId: 'm$t', halves: 2),
];
final _members = [
  for (var t = 1; t <= 20; t++) MemberAccount(id: 'm$t', halves: 2, paid: 0),
];

TontineOverview _on(Day day, Set<String> paidOut) => overviewOf(
  exampleTerms,
  today: day,
  members: _members,
  slots: _slots,
  paidOutSlotIds: paidOut,
);

void main() {
  test('a tour stays on the card until its pot is handed out', () {
    // Day 41 (10 Nov): tour 4 ended yesterday, its pot is due today.
    final due = _on(Day(2026, 11, 10), {'s1', 's2', 's3'});
    expect(due.currentTour, 4);
    expect(due.payoutDay, Day(2026, 11, 10));

    final handed = _on(Day(2026, 11, 10), {'s1', 's2', 's3', 's4'});
    expect(handed.currentTour, 5);
  });

  test('the earliest tour not handed out comes first', () {
    final overview = _on(Day(2026, 11, 10), {'s1', 's3'});
    expect(overview.currentTour, 2);
  });

  test('after the last day, the last tour stays once all are handed out', () {
    final all = {for (final s in _slots) s.id};
    final overview = _on(Day(2027, 6, 1), all);
    expect(overview.currentTour, 20);
    expect(overview.finished, isTrue);
  });
}
