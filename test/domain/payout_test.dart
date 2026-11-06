import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/domain/payout.dart';

import 'maquette_example.dart';

/// Accounts on the evening of day 40, when tour 4 ends. Everyone has paid
/// through day 40 except the members listed with a shortfall on tour 4.
List<MemberAccount> membersAtEndOfTour4({
  Map<String, int> shortOnTour4 = const {},
  Map<String, int> olderArrears = const {},
}) {
  return [
    for (final m in exampleMembersOnDay37())
      MemberAccount(
        id: m.id,
        halves: m.halves,
        paid:
            exampleTerms.dueThrough(m.halves, 40) -
            (shortOnTour4[m.id] ?? 0) -
            (olderArrears[m.id] ?? 0),
      ),
  ];
}

void main() {
  test('mockup: Koffi receives 995 000 F', () {
    final members = membersAtEndOfTour4(
      shortOnTour4: {'koffi': 5000, 'seydou': 25000, 'moussa': 15000},
    );
    final payout = computePayout(
      exampleTerms,
      tour: 4,
      shares: const [TourShare(memberId: 'koffi', halves: 2)],
      members: members,
    ).single;

    expect(payout.pot, 1000000);
    expect(payout.collected, 955000);
    expect(payout.organizerTopUp, 40000);
    expect(payout.withheld, 5000);
    expect(payout.handed, 995000);
  });

  test('a beneficiary with older arrears has all of them withheld', () {
    // Koffi was 10 000 F short on tour 3, which the organizer topped up.
    final members = membersAtEndOfTour4(olderArrears: {'koffi': 10000});
    final payout = computePayout(
      exampleTerms,
      tour: 4,
      shares: const [TourShare(memberId: 'koffi', halves: 2)],
      members: members,
    ).single;

    // Payments cover the oldest days first: the 10 000 F missing now sit on
    // tour 4, and the withheld amount puts Koffi back up to date.
    expect(payout.withheld, 10000);
    expect(payout.organizerTopUp, 0);
    expect(payout.collected, 990000);
    expect(payout.handed, 990000);
  });

  test('two half places share the pot, each with its own withholding', () {
    // Tour 9 belongs to Fatou and Aminata. Look at it when tour 9 ends.
    final members = [
      for (final m in exampleMembersOnDay37())
        MemberAccount(
          id: m.id,
          halves: m.halves,
          paid:
              exampleTerms.dueThrough(m.halves, 90) -
              switch (m.id) {
                'fatou' => 2500,
                'member0' => 15000,
                _ => 0,
              },
        ),
    ];
    final payouts = computePayout(
      exampleTerms,
      tour: 9,
      shares: const [
        TourShare(memberId: 'fatou', halves: 1),
        TourShare(memberId: 'aminata', halves: 1),
      ],
      members: members,
    );

    expect(payouts.map((p) => p.pot), [500000, 500000]);
    expect(payouts.map((p) => p.organizerTopUp), [7500, 7500]);
    expect(payouts.map((p) => p.withheld), [2500, 0]);
    expect(payouts.map((p) => p.handed), [497500, 500000]);
    // Halves add up to what members paid for the tour.
    expect(payouts.fold<int>(0, (s, p) => s + p.collected), 1000000 - 17500);
  });

  test('a tour must hold exactly one place', () {
    expect(
      () => computePayout(
        exampleTerms,
        tour: 9,
        shares: const [TourShare(memberId: 'fatou', halves: 1)],
        members: exampleMembersOnDay37(),
      ),
      throwsArgumentError,
    );
  });

  test('mockup card: 630 000 F collected of 700 000 F due so far', () {
    final progress = tourProgress(
      exampleTerms,
      tour: 4,
      today: exampleToday,
      members: exampleMembersOnDay37(),
    );
    expect(progress.expected, 700000);
    expect(progress.collected, 630000);
  });
}
