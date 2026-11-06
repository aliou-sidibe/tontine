import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/data/app_database.dart';
import 'package:matontine/share/share_statement.dart';
import 'package:matontine/tours/tours_page.dart';

import '../support/mockup_tontine.dart';
import '../support/test_app.dart';

void main() {
  testWidgets('"Partager l’état (PDF)" hands the PDF to the share sheet', (
    tester,
  ) async {
    usePhone(tester);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final id = await seedMockupTontine(db);

    final shared = <(Uint8List, String, String)>[];
    await tester.pumpWidget(
      testApp(
        ToursPage(tontineId: id),
        db,
        overrides: [
          pdfSharerProvider.overrideWithValue((bytes, name, subject) async {
            shared.add((bytes, name, subject));
          }),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Partager l’état (PDF) sur WhatsApp'));
    // Fonts load and the PDF is built outside the fake clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 3)),
    );
    await tester.pumpAndSettle();

    expect(shared, hasLength(1));
    final (bytes, name, subject) = shared.single;
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(name, 'etat-tontine-du-marche-2026-11-06.pdf');
    expect(subject, 'État de la Tontine du marché');
  });
}
