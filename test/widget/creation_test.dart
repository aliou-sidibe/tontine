import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/common/theme.dart';
import 'package:matontine/creation/creation_page.dart';
import 'package:matontine/creation/creation_state.dart';
import 'package:matontine/data/app_database.dart';
import 'package:matontine/data/providers.dart';
import 'package:matontine/tontines/tontines_page.dart';

import '../support/mockup_tontine.dart';

/// The mockup writes amounts with spaces; the app puts non-breaking ones
/// inside amounts only ("5 000 F"), not between words.
String nb(String text) => text
    .replaceAllMapped(RegExp(r'(\d) (?=\d{3}\b)'), (m) => '${m[1]}\u00A0')
    .replaceAllMapped(RegExp(r'(\d) F\b'), (m) => '${m[1]}\u00A0F');

/// A phone the size of the mockup frames (390 × 844).
void usePhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Widget app(Widget home, AppDatabase db) => ProviderScope(
  overrides: [
    appDatabaseProvider.overrideWithValue(db),
    clockProvider.overrideWithValue(() => DateTime(2026, 11, 6, 10)),
  ],
  child: MaterialApp(
    theme: appTheme(),
    locale: const Locale('fr'),
    supportedLocales: const [Locale('fr')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: home,
  ),
);

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  testWidgets('"Mes tontines": the mockup card', (tester) async {
    usePhone(tester);
    await seedMockupTontine(db);
    await tester.pumpWidget(app(const TontinesPage(), db));
    await tester.pumpAndSettle();

    expect(find.text('EN COURS'), findsOneWidget);
    expect(find.text('Tontine du marché'), findsOneWidget);
    expect(find.text('Jour 37 / 200'), findsOneWidget);
    expect(
      find.text(nb('20 places · 5 000 F par jour · tours de 10 jours')),
      findsOneWidget,
    );
    expect(
      find.text('Tour 4 : Koffi Yao ramasse le mar. 10 nov.'),
      findsOneWidget,
    );
    expect(find.text('3 en retard'), findsOneWidget);
    expect(find.text(nb('10 000 F à récupérer')), findsOneWidget);
  });

  testWidgets('"Paramètres": the mockup values and calculation', (
    tester,
  ) async {
    usePhone(tester);
    await tester.pumpWidget(app(const CreationPage(), db));

    expect(find.text('Nouvelle tontine'), findsOneWidget);
    expect(find.text('1 · Paramètres'), findsOneWidget);
    expect(find.text('CALCULÉ PAR L’APPLI'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Tontine du marché');
    await tester.enterText(fields.at(1), '20');
    await tester.enterText(fields.at(2), '10');
    await tester.enterText(fields.at(3), '5000');
    // The first day comes from the picker; set it like the picker does.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CreationPage)),
    );
    container
        .read(creationProvider.notifier)
        .setFirstDay(container.read(creationProvider).firstDay.addDays(-36));
    await tester.pump();

    expect(find.text(nb('5 000')), findsOneWidget);
    expect(
      find.text(nb('Une demi-place cotise 2 500 F, deux places 10 000 F')),
      findsOneWidget,
    );
    expect(find.text('jeu. 1 oct. 2026'), findsOneWidget);
    expect(find.text(nb('50 000 F')), findsOneWidget);
    expect(find.text(nb('1 000 000 F')), findsOneWidget);
    expect(find.text('20 tours · 200 jours'), findsOneWidget);
    expect(find.text('dim. 11 oct. 2026'), findsOneWidget);
    expect(find.text('lun. 19 avr. 2027'), findsOneWidget);
    expect(
      find.text(
        'Tous les jours comptent. Le ramassage a lieu le lendemain du '
        'dernier jour du tour.',
      ),
      findsOneWidget,
    );
    expect(find.text('Suivant : les membres'), findsOneWidget);
  });

  testWidgets('"Ordre des tours": the mockup rows', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(app(const CreationPage(), db));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CreationPage)),
    );
    final notifier = container.read(creationProvider.notifier)
      ..setName('Tontine du marché')
      ..setPlaces(20)
      ..setTourDays(10)
      ..setContribution(5000)
      ..setFirstDay(container.read(creationProvider).firstDay.addDays(-36));
    for (final (name, halves) in mockupPeople) {
      notifier.addMember(name: name, halves: halves);
    }
    notifier.goTo(3);
    notifier.moveTour(5, 13); // Mariam's second place to tour 14
    await tester.pumpAndSettle();

    expect(find.text('3 · Ordre'), findsOneWidget);
    expect(find.text('Qui ramasse quand ?'), findsOneWidget);
    expect(find.text('Tirer au sort'), findsOneWidget);
    expect(
      find.text('20 places sur 20 · les 2 demi-places sont associées'),
      findsOneWidget,
    );
    expect(find.text('Ibrahim Ouattara'), findsOneWidget);
    expect(find.text('dim. 11 oct. 2026'), findsOneWidget);
    expect(find.text('Koffi Yao'), findsOneWidget);
    expect(find.text('mar. 10 nov. 2026'), findsOneWidget);
    expect(find.text('Mariam Traoré · place 1 sur 2'), findsOneWidget);
    expect(find.text('ven. 20 nov. 2026'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Fatou Bamba ½ + Aminata Koné ½'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Fatou Bamba ½ + Aminata Koné ½'), findsOneWidget);
    expect(
      find.text(nb('mer. 30 déc. 2026 · 500 000 F chacune')),
      findsOneWidget,
    );
    expect(find.text('Suivant : récapitulatif'), findsOneWidget);
  });

  testWidgets('the four steps create the tontine', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CreationPage()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
        db,
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Petite tontine');
    await tester.enterText(fields.at(1), '2');
    await tester.enterText(fields.at(2), '5');
    await tester.enterText(fields.at(3), '1000');
    await tester.pump();
    await tester.tap(find.text('Suivant : les membres'));
    await tester.pumpAndSettle();

    expect(find.text('Qui participe ?'), findsOneWidget);
    expect(find.text('0 place sur 2 · il manque 2 places'), findsOneWidget);
    for (final name in ['Awa Koné', 'Koffi Yao']) {
      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, name);
      await tester.pump();
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
    }
    expect(find.text('2 places sur 2'), findsOneWidget);

    await tester.tap(find.text('Suivant : l’ordre des tours'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant : récapitulatif'));
    await tester.pumpAndSettle();
    expect(find.text('Tout est prêt ?'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('CALENDRIER'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('CALENDRIER'), findsOneWidget);

    await tester.tap(find.text('Démarrer la tontine'));
    await tester.pumpAndSettle();

    final tontine = await db.select(db.tontines).getSingle();
    expect(tontine.name, 'Petite tontine');
    expect(await db.select(db.slots).get(), hasLength(2));
    expect(find.text('open'), findsOneWidget);
  });
}
