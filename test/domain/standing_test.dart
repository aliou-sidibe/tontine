import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/domain/standing.dart';

import 'maquette_example.dart';

void main() {
  Standing on37({required int halves, required int paid}) =>
      standingOf(exampleTerms, halves: halves, paid: paid, today: exampleToday);

  test('Awa: late 15 000 F, up to date through day 34', () {
    final awa = on37(halves: 2, paid: 34 * 5000);
    expect(awa.kind, StandingKind.late);
    expect(awa.badgeAmount, 15000);
    expect(awa.upToDay, 34);
  });

  test('Seydou: late 45 000 F', () {
    final seydou = on37(halves: 2, paid: 28 * 5000);
    expect(seydou.kind, StandingKind.late);
    expect(seydou.badgeAmount, 45000);
  });

  test('Fatou, half place, paid through yesterday: 2 500 F to collect', () {
    final fatou = on37(halves: 1, paid: 36 * 2500);
    expect(fatou.kind, StandingKind.toCollect);
    expect(fatou.badgeAmount, 2500);
  });

  test('Mariam, two places, paid today: up to date', () {
    final mariam = on37(halves: 4, paid: 37 * 10000);
    expect(mariam.kind, StandingKind.upToDate);
    expect(mariam.balance, 0);
  });

  test('Ibrahim: 10 000 F ahead, up to date through day 39', () {
    final ibrahim = on37(halves: 2, paid: 39 * 5000);
    expect(ibrahim.kind, StandingKind.ahead);
    expect(ibrahim.badgeAmount, 10000);
    expect(ibrahim.upToDay, 39);
  });

  group('organizerAdvance', () {
    test('Seydou still owes the organizer 10 000 F for tour 3', () {
      expect(
        organizerAdvance(
          exampleTerms,
          halves: 2,
          paid: 28 * 5000,
          lastPaidOutTour: 3,
        ),
        10000,
      );
    });

    test('Awa is behind only on the current tour: nothing advanced', () {
      expect(
        organizerAdvance(
          exampleTerms,
          halves: 2,
          paid: 34 * 5000,
          lastPaidOutTour: 3,
        ),
        0,
      );
    });

    test('nothing is advanced before the first payout', () {
      expect(
        organizerAdvance(
          exampleTerms,
          halves: 2,
          paid: 0,
          lastPaidOutTour: null,
        ),
        0,
      );
    });
  });
}
