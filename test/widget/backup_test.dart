import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/auth/auth_service.dart';
import 'package:matontine/backup/backup_page.dart';
import 'package:matontine/backup/backup_service.dart';
import 'package:matontine/data/app_database.dart';
import 'package:matontine/data/providers.dart';
import 'package:matontine/tontines/tontines_page.dart';
import 'package:path/path.dart' as p;

import '../support/mockup_tontine.dart';
import '../support/test_app.dart';

/// Android's file picker and the restart, without Android.
class FakeChooser implements FileChooser {
  FakeChooser({this.picked});

  final Uint8List? picked;
  final saved = <String>[];
  var restarted = false;

  @override
  Future<bool> save({
    required String name,
    required File source,
    required File marker,
  }) async {
    saved.add(name);
    // As the native code does once the copy is checked.
    await marker.writeAsString('2026-11-06T10:00:00');
    await source.delete();
    return true;
  }

  @override
  Future<Uint8List?> pick() async => picked;

  @override
  Future<void> restart() async => restarted = true;
}

/// Lets real work (isolates, files) run until [done], pumping frames.
Future<void> waitFor(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 100 && !done(); i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
  }
  expect(done(), isTrue, reason: 'timed out');
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedMockupTontine(db);
  });
  tearDown(() => db.close());

  /// Fast key derivation for tests.
  final fastService = backupServiceProvider.overrideWith(
    (ref) => BackupService(
      ref.watch(appDatabaseProvider),
      ref.watch(documentsDirectoryProvider),
      iterations: 1000,
    ),
  );

  testWidgets('"Mes tontines" reminds to back up, "Plus tard" hides it', (
    tester,
  ) async {
    usePhone(tester);
    await tester.pumpWidget(
      testApp(
        const TontinesPage(),
        db,
        overrides: [lastBackupProvider.overrideWith((ref) async => null)],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Aucune sauvegarde pour l’instant. Sans elle, un téléphone perdu '
        'efface tout.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Plus tard'));
    await tester.pumpAndSettle();
    expect(find.text('Sauvegarder'), findsNothing);
  });

  testWidgets('no reminder after a recent backup', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(
      testApp(
        const TontinesPage(),
        db,
        overrides: [
          lastBackupProvider.overrideWith((ref) async => DateTime(2026, 11, 2)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sauvegarder'), findsNothing);
  });

  testWidgets('a reminder 9 days after the last backup', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(
      testApp(
        const TontinesPage(),
        db,
        overrides: [
          lastBackupProvider.overrideWith(
            (ref) async => DateTime(2026, 10, 28),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Dernière sauvegarde il y a 9 jours. Pense à en refaire une.'),
      findsOneWidget,
    );
  });

  testWidgets('creating a backup saves it through the picker', (tester) async {
    usePhone(tester);
    final chooser = FakeChooser();
    await tester.pumpWidget(
      testApp(
        const BackupPage(),
        db,
        overrides: [
          fastService,
          fileChooserProvider.overrideWithValue(chooser),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Aucune pour l’instant'), findsOneWidget);

    await tester.tap(find.text('Créer une sauvegarde'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'court');
    await tester.enterText(find.byType(TextFormField).at(1), 'court');
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();
    expect(find.text('Au moins 8 caractères.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'sauvegarde-1');
    await tester.enterText(find.byType(TextFormField).at(1), 'sauvegarde-1');
    await tester.tap(find.text('Valider'));
    // Encryption runs in an isolate, outside the fake clock.
    await waitFor(tester, () => chooser.saved.isNotEmpty);
    await waitFor(
      tester,
      () => find.text('ven. 6 nov. 2026 à 10:00').evaluate().isNotEmpty,
    );

    expect(chooser.saved.single, endsWith('.matontine'));
    expect(chooser.saved.single, startsWith('ma-tontine-2026-11-06-'));
    expect(find.text('Sauvegarde enregistrée et vérifiée.'), findsOneWidget);
    expect(find.text('ven. 6 nov. 2026 à 10:00'), findsOneWidget);
  });

  testWidgets('restoring schedules the backup, then restarts', (tester) async {
    usePhone(tester);
    final root = Directory.systemTemp.createTempSync('matontine_restore');
    addTearDown(() => root.deleteSync(recursive: true));
    // A backup holds exactly one account, or it is refused.
    final backup = await tester.runAsync(() async {
      await AuthService(db, iterations: 1000).createAccount('test', 'test12');
      return BackupService(db, root, iterations: 1000).create('sauvegarde-1');
    });
    final chooser = FakeChooser(picked: backup);
    late Directory documents;
    await tester.pumpWidget(
      testApp(
        Consumer(
          builder: (context, ref, _) {
            documents = ref.watch(documentsDirectoryProvider);
            return const BackupPage();
          },
        ),
        db,
        overrides: [
          fastService,
          fileChooserProvider.overrideWithValue(chooser),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restaurer une sauvegarde'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'sauvegarde-1');
    await tester.tap(find.text('Valider'));
    await waitFor(
      tester,
      () => find.text('Remplacer les données ?').evaluate().isNotEmpty,
    );
    await tester.tap(find.text('Remplacer'));
    await waitFor(tester, () => chooser.restarted);

    expect(chooser.restarted, isTrue);
    expect(
      File(p.join(documents.path, 'restore_scheduled')).existsSync(),
      isTrue,
    );
  });
}
