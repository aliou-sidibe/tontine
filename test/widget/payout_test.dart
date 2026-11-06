import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/data/app_database.dart';
import 'package:matontine/data/tables.dart';
import 'package:matontine/home/tontine_home.dart';
import 'package:matontine/members/member_page.dart';

import '../support/mockup_tontine.dart';
import '../support/test_app.dart';

/// Tuesday 10 November 2026, payout day of tour 4.
final payoutMorning = DateTime(2026, 11, 10, 9);

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  testWidgets('no payout button before the payout day', (tester) async {
    usePhone(tester);
    final id = await seedMockupTontine(db);
    await tester.pumpWidget(testApp(TontineHome(tontineId: id), db));
    await tester.pumpAndSettle();

    expect(find.text('Koffi Yao ramasse'), findsOneWidget);
    expect(find.text('Remettre la cagnotte'), findsNothing);
  });

  testWidgets('"Remise de la cagnotte" as in the mockup, then confirmed', (
    tester,
  ) async {
    usePhone(tester);
    final id = await seedPayoutDay(db);
    await tester.pumpWidget(
      testApp(TontineHome(tontineId: id), db, now: payoutMorning),
    );
    await tester.pumpAndSettle();

    // The tour stays on the card until its pot is handed out.
    expect(find.text('TOUR 4 SUR 20'), findsOneWidget);
    expect(
      find.text(nb('mar. 10 nov. · aujourd’hui · 1 000 000 F')),
      findsOneWidget,
    );
    await tester.tap(find.text('Remettre la cagnotte'));
    await tester.pumpAndSettle();

    expect(find.text('Remise de la cagnotte'), findsOneWidget);
    expect(find.text('TOUR 4 · JOURS 31 À 40'), findsOneWidget);
    expect(find.text('Koffi Yao'), findsOneWidget);
    expect(
      find.text('mar. 10 nov. 2026 · lendemain du jour 40'),
      findsOneWidget,
    );
    expect(find.text('Cagnotte du tour'), findsOneWidget);
    expect(find.text(nb('1 000 000 F')), findsOneWidget);
    expect(find.text('Versé par les membres'), findsOneWidget);
    expect(find.text(nb('955 000 F')), findsOneWidget);
    expect(find.text('Tu complètes de ta poche'), findsOneWidget);
    expect(find.text(nb('+ 40 000 F')), findsOneWidget);
    expect(
      find.text(
        nb(
          'Seydou Koné 25 000 F · Moussa Diallo 15 000 F. Ils te les devront.',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Retenue : retard de Koffi'), findsOneWidget);
    expect(find.text(nb('− 5 000 F')), findsOneWidget);
    expect(find.text('Koffi est remis à jour.'), findsOneWidget);
    expect(find.text('À remettre à Koffi'), findsOneWidget);
    expect(find.text(nb('995 000 F')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Remis en'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Remis en'), findsOneWidget);
    expect(find.text('Espèces'), findsOneWidget);
    expect(
      find.text(
        'Une remise confirmée s’annule seulement par une '
        'contre-écriture.',
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Mobile money'));
    await tester.tap(find.text('Mobile money'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(nb('Confirmer la remise de 995 000 F')));
    await tester.pumpAndSettle();

    expect(find.text('Remise de la cagnotte'), findsNothing);
    final payout = await db
        .select(db.payouts)
        .get()
        .then((rows) => rows.singleWhere((p) => p.paidOn == '2026-11-10'));
    expect(payout.handed, 995000);
    expect(payout.method, PayoutMethod.mobileMoney);
    // The card moves on to tour 5; the organizer now waits for 40 000 F.
    expect(find.text('TOUR 5 SUR 20'), findsOneWidget);
    expect(find.text('Remettre la cagnotte'), findsNothing);
    expect(find.text(nb('40 000 F')), findsOneWidget);
    expect(find.text('à récupérer · Seydou, Moussa'), findsOneWidget);
  });

  testWidgets('two tours are swapped from "Tours"', (tester) async {
    // A tall phone: the 20 tours fit without scrolling.
    tester.view.physicalSize = const Size(390, 1800) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final id = await seedMockupTontine(db);
    await tester.pumpWidget(testApp(TontineHome(tontineId: id), db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tours'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Échanger deux tours'));
    await tester.pumpAndSettle();

    expect(find.text('Choisis deux tours'), findsOneWidget);
    // A tour already handed out cannot be picked.
    await tester.tap(find.text('Ibrahim Ouattara'));
    await tester.pump();
    expect(find.text('Choisis deux tours'), findsOneWidget);

    await tester.tap(find.text('Fatou Bamba ½ + Aminata Koné ½'));
    await tester.pump();
    await tester.tap(find.text('Awa Koné'));
    await tester.pump();
    await tester.tap(find.text('Échanger les tours 9 et 12'));
    await tester.pumpAndSettle();

    final awa = await memberId(db, 'Awa Koné');
    final slots = await (db.select(
      db.slots,
    )..where((s) => s.memberId.equals(awa))).get();
    expect(slots.single.tour, 9);
    expect(await db.select(db.tourSwaps).get(), hasLength(1));
    // Back on "Tours", with the new order.
    expect(find.text('Échanger deux tours'), findsOneWidget);
  });

  testWidgets('"Échanger" on the member page picks the member\'s tour', (
    tester,
  ) async {
    usePhone(tester);
    final id = await seedMockupTontine(db);
    final awa = await memberId(db, 'Awa Koné');
    await tester.pumpWidget(
      testApp(MemberPage(tontineId: id, memberId: awa), db),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Échanger'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Koffi Yao'));
    await tester.pump();
    expect(find.text('Échanger les tours 4 et 12'), findsOneWidget);
  });

  testWidgets('a payout is cancelled from "Tours"', (tester) async {
    usePhone(tester);
    final id = await seedMockupTontine(db);
    await tester.pumpWidget(testApp(TontineHome(tontineId: id), db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tours'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Moussa Diallo'));
    await tester.pumpAndSettle();
    expect(find.text('Annuler la remise du tour 3 ?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'mauvais tour');
    await tester.tap(find.text('Annuler la remise'));
    await tester.pumpAndSettle();

    final cancellation = await db.select(db.payoutCancellations).getSingle();
    expect(cancellation.reason, 'mauvais tour');
    // Tour 3 is due again: it is back on the card, and "En cours".
    expect(find.text('En cours'), findsOneWidget);
    await tester.tap(find.text('Aujourd\'hui'));
    await tester.pumpAndSettle();
    expect(find.text('TOUR 3 SUR 20'), findsOneWidget);
    expect(find.text('Remettre la cagnotte'), findsOneWidget);
  });
}
