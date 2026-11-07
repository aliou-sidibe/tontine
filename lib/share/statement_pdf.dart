import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/standing.dart';
import '../tours/tours_page.dart';
import 'statement.dart';

/// The app's fonts, embedded in the PDF (accents, "½", "’").
class StatementFonts {
  const StatementFonts({
    required this.regular,
    required this.semiBold,
    required this.bold,
    required this.display,
  });

  final pw.Font regular;
  final pw.Font semiBold;
  final pw.Font bold;

  /// Space Grotesk 700, for the title.
  final pw.Font display;
}

// Colors of the mockup (lib/common/theme.dart), as PDF colors.
const _text = PdfColor.fromInt(0xFF17201B);
const _secondary = PdfColor.fromInt(0xFF56615B);
const _border = PdfColor.fromInt(0xFFE3E7E4);
const _divider = PdfColor.fromInt(0xFFEEF0EF);
const _primary = PdfColor.fromInt(0xFF1F6B4A);
const _primaryPale = PdfColor.fromInt(0xFFE3F1E9);
const _onPrimaryPale = PdfColor.fromInt(0xFF17583C);
const _warningPale = PdfColor.fromInt(0xFFFCEADB);
const _onWarningPale = PdfColor.fromInt(0xFF7A3A00);
const _neutralPale = PdfColor.fromInt(0xFFEEF0EF);
const _onNeutralPale = PdfColor.fromInt(0xFF3E4843);
const _infoPale = PdfColor.fromInt(0xFFE4ECF8);
const _onInfoPale = PdfColor.fromInt(0xFF1D4F91);

/// The statement as an A4 PDF, in the app's style.
Future<Uint8List> buildStatementPdf(Statement s, StatementFonts fonts) {
  final doc = pw.Document(
    title: '${s.name} · ${s.dateLine}',
    author: 'Ma Tontine',
  );
  final theme = pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold);
  pw.TextStyle style(double size, {pw.Font? font, PdfColor color = _text}) =>
      pw.TextStyle(font: font ?? fonts.regular, fontSize: size, color: color);

  doc.addPage(
    pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      footer: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Ma Tontine · ${s.name}', style: style(8, color: _secondary)),
          pw.Text(
            'Page ${context.pageNumber} sur ${context.pagesCount}',
            style: style(8, color: _secondary),
          ),
        ],
      ),
      build: (context) => [
        pw.Text(s.name, style: style(22, font: fonts.display)),
        pw.SizedBox(height: 2),
        pw.Text(s.dateLine, style: style(11, color: _secondary)),
        if (s.skippedLine != null)
          pw.Text(s.skippedLine!, style: style(10, color: _secondary)),
        pw.SizedBox(height: 14),
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: _primary,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                s.tourTitle,
                style: style(14, font: fonts.bold, color: PdfColors.white),
              ),
              pw.SizedBox(height: 3),
              pw.Text(s.tourLine, style: style(10, color: PdfColors.white)),
              pw.SizedBox(height: 3),
              pw.Text(s.progress, style: style(10, color: PdfColors.white)),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          s.lateLine,
          style: style(
            11,
            font: fonts.semiBold,
            color: s.lateLine.startsWith('Personne')
                ? _onPrimaryPale
                : _onWarningPale,
          ),
        ),
        pw.SizedBox(height: 16),
        _sectionTitle('Membres', style(13, font: fonts.bold)),
        _table(
          header: ['Membre', 'Places', 'Versé', 'Situation'],
          widths: const [3.2, 1.3, 1.6, 4],
          rightAligned: const {2},
          rows: [
            for (final m in s.members)
              [
                pw.Text(m.name, style: style(9.5, font: fonts.semiBold)),
                pw.Text(m.places, style: style(9.5)),
                pw.Text(m.paid, style: style(9.5)),
                _pill(m.situation, m.kind, style(8.5, font: fonts.semiBold)),
              ],
          ],
          headerStyle: style(8.5, font: fonts.semiBold, color: _secondary),
        ),
        // The calendar on its own page: its title never sits alone at the
        // bottom of the members' page.
        pw.NewPage(),
        _sectionTitle('Tours', style(13, font: fonts.bold)),
        _table(
          header: ['N°', 'Bénéficiaire', 'Date', 'État'],
          widths: const [0.7, 4.3, 3.6, 1.4],
          rightAligned: const {},
          rows: [
            for (final t in s.tours)
              [
                pw.Text(
                  '${t.tour}',
                  style: style(9.5, font: fonts.bold, color: _secondary),
                ),
                pw.Text(t.who, style: style(9.5, font: fonts.semiBold)),
                pw.Text(t.date, style: style(9, color: _secondary)),
                _tourPill(t.status, style(8.5, font: fonts.semiBold)),
              ],
          ],
          headerStyle: style(8.5, font: fonts.semiBold, color: _secondary),
        ),
      ],
    ),
  );
  return doc.save();
}

pw.Widget _sectionTitle(String text, pw.TextStyle style) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 6),
  child: pw.Text(text, style: style),
);

pw.Widget _table({
  required List<String> header,
  required List<double> widths,
  required Set<int> rightAligned,
  required List<List<pw.Widget>> rows,
  required pw.TextStyle headerStyle,
}) {
  pw.Widget cell(int column, pw.Widget child) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    alignment: rightAligned.contains(column)
        ? pw.Alignment.centerRight
        : pw.Alignment.centerLeft,
    child: child,
  );
  return pw.Table(
    columnWidths: {
      for (final (i, w) in widths.indexed) i: pw.FlexColumnWidth(w),
    },
    border: const pw.TableBorder(
      horizontalInside: pw.BorderSide(color: _divider, width: 0.6),
      top: pw.BorderSide(color: _border, width: 0.6),
      bottom: pw.BorderSide(color: _border, width: 0.6),
    ),
    defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
    children: [
      pw.TableRow(
        repeat: true,
        children: [
          for (final (i, h) in header.indexed)
            cell(i, pw.Text(h.toUpperCase(), style: headerStyle)),
        ],
      ),
      for (final row in rows)
        pw.TableRow(children: [for (final (i, c) in row.indexed) cell(i, c)]),
    ],
  );
}

pw.Widget _badge(
  String text,
  PdfColor background,
  PdfColor foreground,
  pw.TextStyle style,
) => pw.Container(
  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
  decoration: pw.BoxDecoration(
    color: background,
    borderRadius: pw.BorderRadius.circular(5),
  ),
  child: pw.Text(text, style: style.copyWith(color: foreground)),
);

pw.Widget _pill(
  String text,
  StandingKind kind,
  pw.TextStyle style,
) => switch (kind) {
  StandingKind.late => _badge(text, _warningPale, _onWarningPale, style),
  StandingKind.toCollect => _badge(text, _neutralPale, _onNeutralPale, style),
  StandingKind.upToDate => _badge(text, _primaryPale, _onPrimaryPale, style),
  StandingKind.ahead => _badge(text, _infoPale, _onInfoPale, style),
};

pw.Widget _tourPill(TourStatus status, pw.TextStyle style) => switch (status) {
  TourStatus.done => _badge('Remis', _primaryPale, _onPrimaryPale, style),
  TourStatus.current => _badge('En cours', _primary, PdfColors.white, style),
  TourStatus.next => _badge('À venir', _neutralPale, _onNeutralPale, style),
};
