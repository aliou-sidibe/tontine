import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/data/app_database.dart';
import 'package:matontine/data/tontine_repository.dart';
import 'package:matontine/domain/day.dart';
import 'package:matontine/domain/draft.dart';

import '../domain/maquette_example.dart';
import '../support/mockup_tontine.dart';

void main() {
  late AppDatabase db;
  late TontineRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = TontineRepository(db);
  });
  tearDown(() => db.close());

  test('mockupTours matches the mockup order', () {
    final tours = mockupTours();
    final names = {for (final m in mockupDraftMembers()) m.key: m.name};
    String who(int tour) =>
        tours[tour - 1].map((s) => names[s.memberKey]).join(' + ');
    expect(who(4), 'Koffi Yao');
    expect(who(5), 'Mariam Traoré');
    expect(who(9), 'Fatou Bamba + Aminata Koné');
    expect(who(12), 'Awa Koné');
    expect(who(14), 'Mariam Traoré');
    expect(who(20), 'Hawa Doumbia');
  });

  test('create saves the tontine, members and tours', () async {
    await repository.create(
      name: '  Tontine du marché ',
      terms: exampleTerms,
      members: mockupDraftMembers(),
      tours: mockupTours(),
    );

    final tontine = await db.select(db.tontines).getSingle();
    expect(tontine.name, 'Tontine du marché');
    expect(tontine.firstDay, '2026-10-01');
    expect(await db.select(db.members).get(), hasLength(20));
    final slots = await db.select(db.slots).get();
    expect(slots, hasLength(21)); // 19 full places + 2 halves
    expect(slots.where((s) => s.tour == 9).map((s) => s.halves), [1, 1]);
  });

  test('create refuses members that do not fill the places', () async {
    final members = mockupDraftMembers()..removeLast();
    expect(
      () => repository.create(
        name: 'x',
        terms: exampleTerms,
        members: members,
        tours: defaultTours(members),
      ),
      throwsArgumentError,
    );
  });

  test('the mockup card on day 37', () async {
    await seedMockupTontine(db);

    final card = (await repository.cards(Day(2026, 11, 6))).single;
    final o = card.overview;
    expect(o.dayNumber, 37);
    expect(o.currentTour, 4);
    expect(
      [for (final id in o.beneficiaryIds) card.memberNames[id]],
      ['Koffi Yao'],
    );
    expect(o.payoutDay, Day(2026, 11, 9));
    expect(o.lateCount, 3);
    expect(o.toRecover, 10000);
    expect(o.toursPaidOut, 3);
    expect(o.finished, isFalse);
  });

  test('a cancelled payment no longer counts', () async {
    final id = await seedMockupTontine(db);
    final awa = await (db.select(
      db.members,
    )..where((m) => m.name.equals('Awa Koné'))).getSingle();
    final payment = await (db.select(
      db.payments,
    )..where((p) => p.memberId.equals(awa.id))).getSingle();
    await db
        .into(db.paymentCancellations)
        .insert(PaymentCancellationsCompanion.insert(paymentId: payment.id));

    final paid = await repository.paidByMember(id);
    expect(paid.containsKey(awa.id), isFalse);
  });
}
