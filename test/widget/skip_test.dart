import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/data/app_database.dart';
import 'package:matontine/home/tontine_home.dart';

import '../support/mockup_tontine.dart';
import '../support/test_app.dart';

/// A tall phone: the whole screens show without scrolling.
void useTallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 1800) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Finder rich(String text) => find.text(text, findRichText: true);

void main() {
  late AppDatabase db;
  late String id;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    id = await seedMockupTontine(db);
  });
  tearDown(() => db.close());

  testWidgets('"Sauter aujourd’hui": the sheet, then the skipped day', (
    tester,
  ) async {
    useTallPhone(tester);
    await tester.pumpWidget(testApp(TontineHome(tontineId: id), db));
    await tester.pumpAndSettle();

    expect(find.text('ven. 6 nov. 2026'), findsOneWidget);
    await tester.tap(find.text('Sauter aujourd’hui'));
    await tester.pumpAndSettle();

    expect(find.text('Sauter aujourd’hui ?'), findsOneWidget);
    expect(
      find.text('ven. 6 nov. 2026 · personne ne cotise aujourd’hui'),
      findsOneWidget,
    );
    expect(find.text('Motif (facultatif)'), findsOneWidget);
    expect(find.text('Tout est décalé d’un jour'), findsOneWidget);
    expect(
      rich('Koffi Yao ramassera le mar. 10 nov. au lieu du lun. 9 nov.'),
      findsOneWidget,
    );
    expect(
      rich('Fin de la tontine : lun. 19 avr. 2027 au lieu du dim. 18 avr.'),
      findsOneWidget,
    );
    expect(
      find.text(
        nb(
          'Les 85 000 F déjà encaissés aujourd’hui restent acquis : ils '
          'comptent pour les jours suivants.',
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Imprévu'));
    await tester.tap(find.widgetWithText(FilledButton, 'Sauter aujourd’hui'));
    await tester.pumpAndSettle();

    final row = await db.select(db.skippedDays).getSingle();
    expect(row.day, '2026-11-06');
    expect(row.reason, 'Imprévu');

    expect(find.text('Jour sauté · pas de cotisation'), findsOneWidget);
    expect(find.text('Imprévu · demain, jour 37'), findsOneWidget);
    expect(rich('Jour 36 sur 200'), findsOneWidget);
    expect(find.text('jour sauté · rien n’est dû'), findsOneWidget);
    expect(
      find.text('Appui long sur un membre pour enregistrer un rattrapage'),
      findsOneWidget,
    );
    expect(
      find.text(nb('mar. 10 nov. · dans 4 jours · 1 000 000 F')),
      findsOneWidget,
    );
    // Today cannot be skipped twice, and the banner cancels nothing.
    expect(find.text('Sauter aujourd’hui'), findsNothing);
    expect(find.text('Annuler'), findsNothing);
  });

  testWidgets('skipping the 8th and the 11th from "Tours", then cancelling', (
    tester,
  ) async {
    useTallPhone(tester);
    await tester.pumpWidget(testApp(TontineHome(tontineId: id), db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tours'));
    await tester.pumpAndSettle();
    expect(
      find.text('Fête, marché fermé : personne ne cotise ces jours-là'),
      findsOneWidget,
    );
    await tester.tap(find.text('Jours sautés'));
    await tester.pumpAndSettle();
    expect(find.text('FIN DE LA TONTINE'), findsOneWidget);
    expect(find.text('dim. 18 avr. 2027'), findsOneWidget);
    expect(find.text('Comme prévu'), findsOneWidget);

    await tester.tap(find.text('Sauter des jours'));
    await tester.pumpAndSettle();
    expect(find.text('Novembre 2026'), findsOneWidget);
    expect(find.text('Choisis les jours à sauter'), findsOneWidget);
    // A past day cannot be chosen.
    await tester.tap(find.text('5'));
    await tester.pump();
    expect(find.text('Choisis les jours à sauter'), findsOneWidget);

    await tester.tap(find.text('8'));
    await tester.tap(find.text('11'));
    await tester.pump();
    await tester.tap(find.text('Fête'));
    await tester.pump();
    expect(
      find.text('dim. 8 nov. et mer. 11 nov. · tout est décalé de 2 jours'),
      findsOneWidget,
    );
    expect(
      rich('Koffi Yao ramassera le mar. 10 nov. au lieu du lun. 9 nov.'),
      findsOneWidget,
    );
    expect(
      rich('Mariam Traoré, le sam. 21 nov. au lieu du jeu. 19 nov.'),
      findsOneWidget,
    );
    expect(
      rich('Fin de la tontine : mar. 20 avr. 2027 au lieu du dim. 18 avr.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Sauter 2 jours'));
    await tester.pumpAndSettle();

    expect(find.text('dim. 8 nov. 2026'), findsOneWidget);
    expect(find.text('mer. 11 nov. 2026'), findsOneWidget);
    expect(find.text('Fête'), findsNWidgets(2));
    expect(find.text('mar. 20 avr. 2027'), findsOneWidget);
    expect(find.text('2 jours plus tard que prévu'), findsOneWidget);

    await tester.tap(find.text('Annuler').first);
    await tester.pumpAndSettle();
    expect(find.text('dim. 8 nov. 2026'), findsNothing);
    expect(find.text('1 jour plus tard que prévu'), findsOneWidget);
    expect(await db.select(db.skippedDays).get(), hasLength(1));

    // Back on "Tours": the row and the calendar follow.
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    expect(find.text('Jours sautés · 1'), findsOneWidget);
    expect(
      find.text('mer. 11 nov. · tout est décalé d’un jour'),
      findsOneWidget,
    );
    expect(find.text('ven. 20 nov.'), findsOneWidget);
  });
}
