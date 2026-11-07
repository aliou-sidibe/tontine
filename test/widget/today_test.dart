import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/data/app_database.dart';
import 'package:matontine/home/tontine_home.dart';
import 'package:matontine/members/member_page.dart';

import '../support/chip_width.dart';
import '../support/mockup_tontine.dart';
import '../support/test_app.dart';

/// Scrolls the member list until [text] is on screen.
Future<void> reveal(WidgetTester tester, String text) =>
    tester.scrollUntilVisible(
      find.text(text),
      200,
      scrollable: find.byType(Scrollable).last,
    );

void main() {
  late AppDatabase db;
  late String tontineId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tontineId = await seedMockupTontine(db);
  });
  tearDown(() => db.close());

  Future<void> openToday(WidgetTester tester) async {
    usePhone(tester);
    await tester.pumpWidget(testApp(TontineHome(tontineId: tontineId), db));
    await tester.pumpAndSettle();
  }

  testWidgets('"Aujourd\'hui": header, tour card and tiles of the mockup', (
    tester,
  ) async {
    await openToday(tester);

    expect(find.text('Tontine du marché'), findsOneWidget);
    expect(find.text('Jour 37 sur 200'), findsOneWidget);
    expect(find.text('ven. 6 nov. 2026'), findsOneWidget);
    expect(find.text('TOUR 4 SUR 20'), findsOneWidget);
    expect(find.text('jours 31 à 40'), findsOneWidget);
    expect(find.text('Koffi Yao ramasse'), findsOneWidget);
    expect(
      find.text(nb('lun. 9 nov. · dans 3 jours · 1 000 000 F')),
      findsOneWidget,
    );
    expect(
      find.text(nb('630 000 F réunis · 700 000 F attendus à ce jour')),
      findsOneWidget,
    );
    expect(find.text('Encaissé aujourd\'hui'), findsOneWidget);
    expect(find.text(nb('85 000 F')), findsOneWidget);
    expect(find.text(nb('sur 100 000 F')), findsOneWidget);
    expect(find.text('Avancé par toi'), findsOneWidget);
    expect(find.text(nb('10 000 F')), findsOneWidget);
    expect(find.text('à récupérer · Seydou'), findsOneWidget);
    expect(find.text('Tous · 20'), findsOneWidget);
    expect(find.text('À encaisser · 3'), findsOneWidget);
    expect(find.text('En retard · 3'), findsOneWidget);
    for (final label in ['Tous · 20', 'À encaisser · 3', 'En retard · 3']) {
      expectHugsLabel(tester, find.text(label));
    }
    expect(
      find.text('Appui long sur un membre pour enregistrer un versement'),
      findsOneWidget,
    );
    for (final tab in ['Aujourd\'hui', 'Membres', 'Tours', 'Plus']) {
      expect(find.text(tab), findsOneWidget);
    }
  });

  testWidgets('"Aujourd\'hui": member rows as in the mockup', (tester) async {
    await openToday(tester);

    // Late members first, in entry order.
    expect(find.text('Seydou Koné'), findsOneWidget);
    expect(
      find.text(nb('1 place · dont 10 000 F avancés par toi')),
      findsOneWidget,
    );
    expect(find.text(nb('Retard 45 000 F')), findsOneWidget);
    await reveal(tester, 'Moussa Diallo');
    expect(find.text('Moussa Diallo'), findsOneWidget);
    expect(find.text('1 place · à jour jusqu’au jour 33'), findsOneWidget);
    expect(find.text(nb('Retard 20 000 F')), findsOneWidget);
    await reveal(tester, 'Awa Koné');
    expect(find.text('Awa Koné'), findsOneWidget);
    expect(find.text('1 place · à jour jusqu’au jour 34'), findsOneWidget);
    expect(find.text(nb('Retard 15 000 F')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Koffi Yao'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('1 place · ramasse le 9 nov.'), findsOneWidget);
    expect(find.text('Payé aujourd’hui'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Mariam Traoré'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text(nb('2 places · 10 000 F par jour')), findsOneWidget);
  });

  testWidgets('a single tap does nothing, a long press opens the payment', (
    tester,
  ) async {
    await openToday(tester);

    await reveal(tester, 'Awa Koné');
    await tester.tap(find.text('Awa Koné'));
    await tester.pumpAndSettle();
    expect(find.text('Versement de Awa Koné'), findsNothing);

    await tester.longPress(find.text('Awa Koné'));
    await tester.pumpAndSettle();
    expect(find.text('Versement de Awa Koné'), findsOneWidget);
    expect(
      find.text(nb('Retard 15 000 F · à jour jusqu’au jour 34')),
      findsOneWidget,
    );
    expect(find.text(nb('Le jour · 5 000 F')), findsOneWidget);
    // The mockup said 20 000 F; 15 000 F is what Awa really owes (see plan).
    expect(find.text(nb('Jour + retard · 15 000 F')), findsOneWidget);
    expectHugsLabel(tester, find.text(nb('Le jour · 5 000 F')));
    expectHugsLabel(tester, find.text(nb('Jour + retard · 15 000 F')));
    expect(find.text('Montant reçu'), findsOneWidget);
    expect(find.text('Awa sera à jour jusqu’au jour 35'), findsOneWidget);
    expect(find.text('Espèces'), findsOneWidget);
    expect(find.text('Mobile money'), findsOneWidget);
    expect(find.text('Date du versement'), findsOneWidget);
    expect(find.text('Aujourd’hui, ven. 6 nov.'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);
    expect(find.text(nb('Enregistrer 5 000 F')), findsOneWidget);

    // Typing replaces the pre-filled amount.
    await tester.ensureVisible(find.text('000'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.tap(find.text('0'));
    await tester.tap(find.text('000'));
    await tester.pump();
    expect(find.text(nb('Enregistrer 10 000 F')), findsOneWidget);
    expect(find.text('Awa sera à jour jusqu’au jour 36'), findsOneWidget);

    await tester.ensureVisible(find.text('Mobile money'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mobile money'));
    await tester.ensureVisible(find.text(nb('Enregistrer 10 000 F')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(nb('Enregistrer 10 000 F')));
    await tester.pumpAndSettle();

    expect(find.text('Versement de Awa Koné'), findsNothing);
    final awa = await (db.select(
      db.members,
    )..where((m) => m.name.equals('Awa Koné'))).getSingle();
    final payments =
        await (db.select(db.payments)..where(
              (p) => p.memberId.equals(awa.id) & p.paidOn.equals('2026-11-06'),
            ))
            .get();
    expect(payments, hasLength(1));
    expect(payments.single.method.name, 'mobileMoney');
    // Awa paid everything due until yesterday: only today is left.
    await reveal(tester, nb('À encaisser 5 000 F'));
    expect(find.text(nb('À encaisser 5 000 F')), findsOneWidget);
  });

  testWidgets('"Fiche membre": Awa as in the mockup', (tester) async {
    usePhone(tester);
    final awa = await (db.select(
      db.members,
    )..where((m) => m.name.equals('Awa Koné'))).getSingle();
    await tester.pumpWidget(
      testApp(MemberPage(tontineId: tontineId, memberId: awa.id), db),
    );
    await tester.pumpAndSettle();

    expect(find.text('Awa Koné'), findsOneWidget);
    expect(find.text(nb('1 place · 5 000 F par jour')), findsOneWidget);
    expect(find.text('En retard'), findsOneWidget);
    expect(find.text(nb('15 000 F')), findsOneWidget);
    expect(find.text('à jour jusqu’au jour 34'), findsOneWidget);
    expect(find.text('Total versé'), findsOneWidget);
    expect(find.text(nb('170 000 F')), findsWidgets);
    expect(find.text(nb('sur 185 000 F attendus')), findsOneWidget);
    expect(find.text('Son tour'), findsOneWidget);
    expect(find.text('Tour 12 · jeu. 28 janv. 2027'), findsOneWidget);
    expect(find.text(nb('1 000 000 F')), findsOneWidget);
    expect(find.text('Échanger'), findsOneWidget);
    expect(find.text('Versements'), findsOneWidget);
    expect(find.text('mer. 4 nov.'), findsOneWidget);
    expect(find.text('Espèces'), findsOneWidget);
  });

  testWidgets('cancelling a payment crosses it out', (tester) async {
    usePhone(tester);
    final awa = await (db.select(
      db.members,
    )..where((m) => m.name.equals('Awa Koné'))).getSingle();
    await tester.pumpWidget(
      testApp(MemberPage(tontineId: tontineId, memberId: awa.id), db),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('mer. 4 nov.'));
    await tester.pumpAndSettle();
    expect(
      find.text(nb('Annuler ce versement de 170 000 F ?')),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'erreur de saisie');
    await tester.tap(find.text('Annuler le versement'));
    await tester.pumpAndSettle();

    expect(find.text('Espèces · annulé, erreur de saisie'), findsOneWidget);
    expect(find.text(nb('sur 185 000 F attendus')), findsOneWidget);
    expect(await db.select(db.paymentCancellations).get(), hasLength(1));
  });
}
