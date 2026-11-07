import '../common/format.dart';
import '../data/tontine_repository.dart';
import '../domain/day.dart';
import '../domain/standing.dart';
import '../today/today_texts.dart';
import '../tours/tours_page.dart';

/// One member line of the shared statement.
class StatementMember {
  const StatementMember({
    required this.name,
    required this.places,
    required this.paid,
    required this.situation,
    required this.kind,
  });

  final String name;
  final String places;
  final String paid;

  /// "Retard 15 000 F · à jour jusqu’au jour 34", "Payé aujourd’hui"…
  final String situation;
  final StandingKind kind;
}

/// What the PDF shared with the members shows, in display texts. The
/// organizer's own advances stay out of it: they concern only him.
class Statement {
  const Statement({
    required this.name,
    required this.dateLine,
    required this.skippedLine,
    required this.tourTitle,
    required this.tourLine,
    required this.progress,
    required this.lateLine,
    required this.members,
    required this.tours,
    required this.fileName,
  });

  final String name;

  /// "État au ven. 6 nov. 2026 · jour 37 sur 200".
  final String dateLine;

  /// "Jours sautés : 8 nov., 11 nov.", or null when none.
  final String? skippedLine;

  /// "Tour 4 sur 20 · Koffi Yao ramasse".
  final String tourTitle;

  /// "mar. 10 nov. · dans 4 jours · 1 000 000 F".
  final String tourLine;

  /// "630 000 F réunis · 700 000 F attendus à ce jour".
  final String progress;

  /// "3 membres en retard · 80 000 F au total", or "Personne n’est en retard".
  final String lateLine;

  /// Late first, as on "Aujourd'hui".
  final List<StatementMember> members;
  final List<TourEntry> tours;

  /// "etat-tontine-du-marche-2026-11-06.pdf".
  final String fileName;
}

Statement statementOf(TontineDetail detail, Day today) {
  final terms = detail.terms;
  final view = detail.today(today);
  final names = {for (final m in detail.members) m.id: m.name};
  final day = view.dayNumber.clamp(0, terms.totalDays);
  final late = [
    for (final l in view.lines)
      if (l.standing.kind == StandingKind.late) l,
  ];
  final lateTotal = late.fold<int>(0, (s, l) => s + l.standing.badgeAmount);

  return Statement(
    name: detail.name,
    dateLine: view.dayNumber < 1
        ? 'État au ${formatDay(today, withYear: true)} · avant le début'
        : 'État au ${formatDay(today, withYear: true)} · jour $day sur '
              '${terms.totalDays}',
    skippedLine: terms.skippedDays.isEmpty
        ? null
        : 'Jours sautés : '
              '${terms.skippedDays.map(formatDayShort).join(', ')}',
    tourTitle:
        'Tour ${view.currentTour} sur ${terms.tours} · '
        '${collectorsTitle([for (final id in view.beneficiaryIds) names[id] ?? ''])}',
    tourLine: payoutLine(view.payoutDay, view.daysToPayout, terms.potPerTour),
    progress: progressLine(view.collected, view.expected),
    lateLine: late.isEmpty
        ? 'Personne n’est en retard'
        : '${late.length} membre${late.length > 1 ? 's' : ''} en retard · '
              '${formatFcfa(lateTotal)} au total',
    members: [
      for (final l in view.lines)
        StatementMember(
          name: l.member.name,
          places: formatPlaces(l.member.halves),
          paid: formatFcfa(l.standing.paid),
          situation: paymentStatus(l.standing) == 'À jour'
              ? badgeText(l)
              : paymentStatus(l.standing),
          kind: l.standing.kind,
        ),
    ],
    tours: tourEntries(detail, today),
    fileName: 'etat-${_slug(detail.name)}-${today.toIso()}.pdf',
  );
}

/// "Tontine du marché" becomes "tontine-du-marche": a file name every phone
/// and WhatsApp accept.
String _slug(String name) {
  const accents = {
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'ç': 'c',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'ô': 'o',
    'ö': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ÿ': 'y',
    'œ': 'oe',
    'æ': 'ae',
  };
  final lower = name.toLowerCase().split('').map((c) => accents[c] ?? c).join();
  final slug = lower
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return slug.isEmpty ? 'tontine' : slug;
}
