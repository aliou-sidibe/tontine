import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/data/app_database.dart';
import 'package:matontine/data/tables.dart';
import 'package:matontine/data/tontine_repository.dart';
import 'package:matontine/domain/day.dart';

import '../support/mockup_tontine.dart';

void main() {
  late AppDatabase db;
  late TontineRepository repository;
  late String tontineId;

  final payoutDay = Day(2026, 11, 9);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = TontineRepository(db);
    tontineId = await seedPayoutDay(db);
  });
  tearDown(() => db.close());

  Future<String> slotOfTour(int tour) async {
    final detail = await repository.detail(tontineId);
    return detail.sharesOf(tour).single.id;
  }

  test('the mockup payout: 995 000 F for Koffi', () async {
    final detail = await repository.detail(tontineId);
    final slot = detail.sharesOf(4).single;
    final b = detail.payoutFor(slot.id);
    expect(b.pot, 1000000);
    expect(b.collected, 955000);
    expect(b.organizerTopUp, 40000);
    expect(b.withheld, 5000);
    expect(b.handed, 995000);

    final names = {for (final m in detail.members) m.id: m.name};
    expect(
      {for (final e in detail.topUpsFor(4).entries) names[e.key]: e.value},
      {'Seydou Koné': 25000, 'Moussa Diallo': 15000},
    );
  });

  test('recording the payout withholds Koffi\'s arrears', () async {
    final slotId = await slotOfTour(4);
    final payoutId = await repository.recordPayout(
      tontineId: tontineId,
      slotId: slotId,
      method: PayoutMethod.mobileMoney,
      day: payoutDay,
    );

    final payout = await db
        .select(db.payouts)
        .get()
        .then((rows) => rows.singleWhere((p) => p.id == payoutId));
    expect(payout.handed, 995000);
    expect(payout.organizerTopUp, 40000);
    expect(payout.withheld, 5000);
    expect(payout.method, PayoutMethod.mobileMoney);
    expect(payout.paidOn, '2026-11-09');

    final koffi = await memberId(db, 'Koffi Yao');
    final withheld = await (db.select(
      db.payments,
    )..where((p) => p.payoutId.equals(payoutId))).getSingle();
    expect(withheld.memberId, koffi);
    expect(withheld.amount, 5000);
    expect(withheld.method, PaymentMethod.withheld);

    // Koffi is back up to date through day 40; tour 5 is now on the card.
    final detail = await repository.detail(tontineId);
    expect(detail.paidOutSlotIds, contains(slotId));
    expect(detail.accounts().singleWhere((a) => a.id == koffi).paid, 40 * 5000);
    final view = detail.today(payoutDay);
    expect(view.currentTour, 5);
    // Seydou caught up on tour 3; he and Moussa owe the organizer the
    // 40 000 F topped up on tour 4.
    expect(view.toRecover, 40000);
  });

  test(
    'the pot cannot be handed out twice, nor before the tour ends',
    () async {
      final slotId = await slotOfTour(4);
      expect(
        () => repository.recordPayout(
          tontineId: tontineId,
          slotId: slotId,
          method: PayoutMethod.cash,
          day: Day(2026, 11, 8),
        ),
        throwsStateError,
      );
      await repository.recordPayout(
        tontineId: tontineId,
        slotId: slotId,
        method: PayoutMethod.cash,
        day: payoutDay,
      );
      expect(
        () => repository.recordPayout(
          tontineId: tontineId,
          slotId: slotId,
          method: PayoutMethod.cash,
          day: payoutDay,
        ),
        throwsStateError,
      );
    },
  );

  test('cancelling a payout cancels its withholding too', () async {
    final slotId = await slotOfTour(4);
    final payoutId = await repository.recordPayout(
      tontineId: tontineId,
      slotId: slotId,
      method: PayoutMethod.cash,
      day: payoutDay,
    );
    await repository.cancelPayout(payoutId, reason: 'mauvais tour');

    final detail = await repository.detail(tontineId);
    expect(detail.paidOutSlotIds, isNot(contains(slotId)));
    expect(detail.payoutOf(slotId), isNull);
    expect(detail.payouts.last.cancelled, isTrue);
    final withheld = detail.payments.singleWhere(
      (p) => p.method == PaymentMethod.withheld,
    );
    expect(withheld.cancelled, isTrue);
    expect(withheld.cancelReason, 'mauvais tour');
    // The tour is due again, with the same amounts.
    expect(detail.today(payoutDay).currentTour, 4);
    expect(detail.payoutFor(slotId).handed, 995000);
  });

  test('a withholding cannot be cancelled on its own', () async {
    final payoutId = await repository.recordPayout(
      tontineId: tontineId,
      slotId: await slotOfTour(4),
      method: PayoutMethod.cash,
      day: payoutDay,
    );
    final withheld = await (db.select(
      db.payments,
    )..where((p) => p.payoutId.equals(payoutId))).getSingle();
    expect(() => repository.cancelPayment(withheld.id), throwsStateError);
    expect(await db.select(db.paymentCancellations).get(), isEmpty);
  });

  test('swapping two tours moves their beneficiaries', () async {
    final awa = await memberId(db, 'Awa Koné');
    final fatou = await memberId(db, 'Fatou Bamba');
    await repository.swapTours(tontineId: tontineId, tourA: 12, tourB: 9);

    final detail = await repository.detail(tontineId);
    expect(detail.sharesOf(9).map((s) => s.memberId), [awa]);
    expect(detail.sharesOf(12).map((s) => s.memberId), contains(fatou));
    expect(detail.sharesOf(12), hasLength(2));
    final swap = await db.select(db.tourSwaps).getSingle();
    expect((swap.tourA, swap.tourB), (12, 9));
  });

  test('a tour already paid out cannot be swapped', () async {
    expect(
      () => repository.swapTours(tontineId: tontineId, tourA: 3, tourB: 12),
      throwsStateError,
    );
    expect(
      () => repository.swapTours(tontineId: tontineId, tourA: 12, tourB: 12),
      throwsArgumentError,
    );
    expect(await db.select(db.tourSwaps).get(), isEmpty);
  });
}
