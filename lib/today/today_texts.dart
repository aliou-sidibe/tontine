import '../common/format.dart';
import '../domain/day.dart';
import '../domain/standing.dart';
import '../domain/today.dart';
import '../domain/tontine_terms.dart';

/// Texts of the "Aujourd'hui" screen, with the mockup's exact wording and
/// punctuation (curly apostrophe in the rows, straight one in the tiles).

String firstName(String name) => name.trim().split(RegExp(r'\s+')).first;

/// "1 place · à jour jusqu’au jour 34", "½ place · 2 500 F par jour"…
String rowSubtitle(MemberLine line, TontineTerms terms, Day payoutDay) {
  final halves = line.member.halves;
  final standing = line.standing;
  final detail = line.advance > 0
      ? 'dont ${formatFcfa(line.advance)} avancés par toi'
      : standing.kind == StandingKind.late ||
            standing.kind == StandingKind.ahead
      ? 'à jour jusqu’au jour ${standing.upToDay}'
      : line.collectsNow
      ? 'ramasse le ${formatDayShort(payoutDay)}'
      : halves != halvesPerPlace
      ? '${formatFcfa(terms.dailyDue(halves))} par jour'
      : null;
  return [formatPlaces(halves), ?detail].join(' · ');
}

/// "Retard 15 000 F", "À encaisser 2 500 F", "Payé aujourd’hui", "Avance…".
String badgeText(MemberLine line) {
  final s = line.standing;
  return switch (s.kind) {
    StandingKind.late => 'Retard ${formatFcfa(s.badgeAmount)}',
    StandingKind.toCollect => 'À encaisser ${formatFcfa(s.badgeAmount)}',
    StandingKind.upToDate =>
      line.member.paidToday > 0 ? 'Payé aujourd’hui' : 'À jour',
    StandingKind.ahead => 'Avance ${formatFcfa(s.badgeAmount)}',
  };
}

/// "Koffi Yao ramasse", "Fatou Bamba et Aminata Koné ramassent".
String collectorsTitle(List<String> names) => switch (names) {
  [] => 'Tour à attribuer',
  [final one] => '$one ramasse',
  _ => '${names.join(' et ')} ramassent',
};

/// "mar. 10 nov. · dans 4 jours · 1 000 000 F".
String payoutLine(Day payoutDay, int daysToPayout, int pot) {
  final when = switch (daysToPayout) {
    0 => 'aujourd’hui',
    1 => 'demain',
    > 1 => 'dans $daysToPayout jours',
    -1 => 'depuis hier',
    _ => 'depuis ${-daysToPayout} jours',
  };
  return '${formatDay(payoutDay)} · $when · ${formatFcfa(pot)}';
}

/// "630 000 F réunis · 700 000 F attendus à ce jour".
String progressLine(int collected, int expected) =>
    '${formatFcfa(collected)} réunis · ${formatFcfa(expected)} attendus à ce '
    'jour';

/// "à récupérer · Seydou", "à récupérer · Seydou, Awa".
String toRecoverLine(TodayView view) {
  final names = [for (final l in view.owingOrganizer) firstName(l.member.name)];
  return names.isEmpty
      ? 'rien à récupérer'
      : 'à récupérer · ${names.join(', ')}';
}

/// "Retard 15 000 F · à jour jusqu’au jour 34" under the payment title.
String paymentStatus(Standing s) => switch (s.kind) {
  StandingKind.late =>
    'Retard ${formatFcfa(s.badgeAmount)} · à jour jusqu’au jour ${s.upToDay}',
  StandingKind.toCollect => 'À encaisser ${formatFcfa(s.badgeAmount)}',
  StandingKind.upToDate => 'À jour',
  StandingKind.ahead =>
    'Avance ${formatFcfa(s.badgeAmount)} · à jour jusqu’au jour ${s.upToDay}',
};
