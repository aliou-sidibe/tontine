import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/data/app_database.dart';
import 'package:matontine/data/tontine_repository.dart';
import 'package:matontine/domain/day.dart';
import 'package:matontine/domain/standing.dart';
import 'package:matontine/share/statement.dart';
import 'package:matontine/share/statement_pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../support/mockup_tontine.dart';
import '../support/test_app.dart';

void main() {
  late AppDatabase db;
  late TontineDetail detail;
  final today = Day(2026, 11, 6);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final id = await seedMockupTontine(db);
    detail = await TontineRepository(db).detail(id);
  });
  tearDown(() => db.close());

  test('the statement of the mockup tontine on day 37', () {
    final s = statementOf(detail, today);

    expect(s.name, 'Tontine du marché');
    expect(s.dateLine, 'État au ven. 6 nov. 2026 · jour 37 sur 200');
    expect(s.tourTitle, 'Tour 4 sur 20 · Koffi Yao ramasse');
    expect(s.tourLine, nb('lun. 9 nov. · dans 3 jours · 1 000 000 F'));
    expect(s.progress, nb('630 000 F réunis · 700 000 F attendus à ce jour'));
    expect(s.lateLine, nb('3 membres en retard · 80 000 F au total'));
    expect(s.fileName, 'etat-tontine-du-marche-2026-11-06.pdf');

    // Late members first, as on "Aujourd'hui".
    final seydou = s.members.first;
    expect(seydou.name, 'Seydou Koné');
    expect(seydou.places, '1 place');
    expect(seydou.paid, nb('140 000 F'));
    expect(seydou.situation, nb('Retard 45 000 F · à jour jusqu’au jour 28'));
    expect(seydou.kind, StandingKind.late);
    final koffi = s.members.singleWhere((m) => m.name == 'Koffi Yao');
    expect(koffi.situation, 'Payé aujourd’hui');
    expect(
      s.members.singleWhere((m) => m.name == 'Mariam Traoré').places,
      '2 places',
    );
    expect(s.members, hasLength(20));
    expect(s.tours, hasLength(20));
    // The organizer's advances are not shared.
    expect(s.members.map((m) => m.situation).join(), isNot(contains('avancé')));
  });

  test('the PDF is built with the app fonts', () async {
    pw.Font font(String file) => pw.Font.ttf(
      File('assets/fonts/$file').readAsBytesSync().buffer.asByteData(),
    );
    final bytes = await buildStatementPdf(
      statementOf(detail, today),
      StatementFonts(
        regular: font('Inter-Regular.ttf'),
        semiBold: font('Inter-SemiBold.ttf'),
        bold: font('Inter-Bold.ttf'),
        display: font('SpaceGrotesk-Bold.ttf'),
      ),
    );
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    final out = Platform.environment['MATONTINE_PDF_OUT'];
    if (out != null) File(out).writeAsBytesSync(bytes);
  });
}
