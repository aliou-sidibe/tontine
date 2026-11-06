import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/domain/day.dart';
import 'package:matontine/domain/tontine_terms.dart';

import 'maquette_example.dart';

void main() {
  group('mockup figures', () {
    test('one place pays 50 000 F per tour, the pot is 1 000 000 F', () {
      expect(exampleTerms.perPlacePerTour, 50000);
      expect(exampleTerms.potPerTour, 1000000);
      expect(exampleTerms.tours, 20);
      expect(exampleTerms.totalDays, 200);
      expect(exampleTerms.dailyTotal, 100000);
    });

    test('6 November 2026 is day 37, in tour 4 (days 31 to 40)', () {
      expect(exampleTerms.dayNumber(Day(2026, 11, 6)), 37);
      expect(exampleTerms.tourOfDay(37), 4);
      expect(exampleTerms.firstDayOfTour(4), 31);
      expect(exampleTerms.lastDayOfTour(4), 40);
    });

    test('payout happens on the last day of the tour', () {
      expect(exampleTerms.payoutDay(1), Day(2026, 10, 10));
      expect(exampleTerms.payoutDay(4), Day(2026, 11, 9));
      expect(exampleTerms.payoutDay(9), Day(2026, 12, 29));
      expect(exampleTerms.payoutDay(12), Day(2027, 1, 28));
      expect(exampleTerms.payoutDay(20), Day(2027, 4, 18));
    });

    test('a half place pays 2 500 F a day, two places 10 000 F', () {
      expect(exampleTerms.dailyDue(1), 2500);
      expect(exampleTerms.dailyDue(2), 5000);
      expect(exampleTerms.dailyDue(4), 10000);
    });
  });

  group('dueThrough', () {
    test('is zero before day 1 and stops at the last day', () {
      expect(exampleTerms.dueThrough(2, 0), 0);
      expect(exampleTerms.dueThrough(2, -5), 0);
      expect(exampleTerms.dueThrough(2, 37), 185000);
      expect(exampleTerms.dueThrough(2, 250), 1000000);
    });
  });

  group('collectedForTour', () {
    test('payments cover the oldest days first', () {
      // 34 days paid: tours 1 to 3 are full, tour 4 has 4 days.
      expect(exampleTerms.collectedForTour(2, 170000, 3), 50000);
      expect(exampleTerms.collectedForTour(2, 170000, 4), 20000);
      expect(exampleTerms.collectedForTour(2, 170000, 5), 0);
    });

    test('can stop at a day inside the tour', () {
      // Paid ahead through day 39, but only 7 days of tour 4 are due today.
      expect(
        exampleTerms.collectedForTour(2, 195000, 4, throughDay: 37),
        35000,
      );
    });
  });

  group('validation', () {
    test('the contribution must be a multiple of 10 F', () {
      expect(
        () => TontineTerms(
          places: 20,
          contributionPerPlace: 5005,
          tourDays: 10,
          firstDay: Day(2026, 10, 1),
        ),
        throwsArgumentError,
      );
    });
  });
}
