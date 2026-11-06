import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/tontine_repository.dart';
import '../domain/day.dart';
import 'statement.dart';
import 'statement_pdf.dart';

/// Hands a PDF to Android's share sheet (WhatsApp, Drive…). Replaced in
/// tests.
typedef PdfSharer = Future<void> Function(
  Uint8List bytes,
  String fileName,
  String subject,
);

final pdfSharerProvider = Provider<PdfSharer>((ref) {
  return (bytes, fileName, subject) =>
      Printing.sharePdf(bytes: bytes, filename: fileName, subject: subject);
});

/// The app's bundled fonts, loaded once.
final statementFontsProvider = FutureProvider<StatementFonts>((ref) async {
  Future<pw.Font> font(String file) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/$file'));
  return StatementFonts(
    regular: await font('Inter-Regular.ttf'),
    semiBold: await font('Inter-SemiBold.ttf'),
    bold: await font('Inter-Bold.ttf'),
    display: await font('SpaceGrotesk-Bold.ttf'),
  );
});

/// Builds the statement of [detail] on [today] and opens the share sheet.
Future<void> shareStatement(
  WidgetRef ref,
  TontineDetail detail,
  Day today,
) async {
  final statement = statementOf(detail, today);
  final fonts = await ref.read(statementFontsProvider.future);
  final bytes = await buildStatementPdf(statement, fonts);
  await ref.read(pdfSharerProvider)(
    bytes,
    statement.fileName,
    'État de la ${statement.name}',
  );
}
