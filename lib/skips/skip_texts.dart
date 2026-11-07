import '../common/format.dart';
import '../data/tontine_repository.dart';
import '../domain/day.dart';

/// One line of the effect box: plain text around one date in bold.
class EffectLine {
  const EffectLine(this.before, this.strong, this.after);

  final String before;
  final String strong;
  final String after;
}

/// What skipping [days] changes, in the mockup's words: "Tout est décalé
/// d'un jour", "Koffi Yao ramassera le mar. 10 nov. au lieu du lun. 9 nov.",
/// "Fin de la tontine : lun. 19 avr. 2027 au lieu du dim. 18 avr.".
class SkipEffect {
  const SkipEffect({
    required this.title,
    required this.lines,
    required this.shift,
  });

  final String title;
  final List<EffectLine> lines;

  /// Days the end of the tontine moves back.
  final int shift;
}

/// "dim. 8 nov. et mer. 11 nov.", "dim. 8 nov., lun. 9 nov. et mer. 11 nov.".
String joinDays(Iterable<Day> days) {
  final texts = [for (final d in days.toList()..sort()) formatDay(d)];
  if (texts.length <= 1) return texts.join();
  return '${texts.sublist(0, texts.length - 1).join(', ')} et ${texts.last}';
}

/// Ends a sentence: "au lieu du lun. 9 nov." keeps the abbreviation's dot
/// as the full stop.
String _sentence(String text) => text.endsWith('.') ? text : '$text.';

String _shiftText(int shift) =>
    'tout est décalé ${shift == 1 ? 'd’un jour' : 'de $shift jours'}';

SkipEffect skipEffect(
  TontineDetail detail,
  Day today,
  Set<Day> days, {
  bool todayOnly = false,
}) {
  final before = detail.terms;
  final after = before.withSkippedDays(days);
  final names = {for (final m in detail.members) m.id: m.name};
  final view = detail.today(today);

  final lines = <EffectLine>[];
  for (
    var tour = view.currentTour;
    tour <= before.tours && lines.length < 2;
    tour++
  ) {
    final old = before.payoutDay(tour);
    final now = after.payoutDay(tour);
    if (old == now) continue;
    final who = [for (final s in detail.sharesOf(tour)) names[s.memberId] ?? '']
        .join(' et ');
    lines.add(
      lines.isEmpty
          ? EffectLine(
              '$who ${detail.sharesOf(tour).length > 1 ? 'ramasseront' : 'ramassera'} le ',
              formatDay(now),
              _sentence(' au lieu du ${formatDay(old)}'),
            )
          : EffectLine(
              '$who, le ',
              formatDay(now),
              _sentence(' au lieu du ${formatDay(old)}'),
            ),
    );
  }
  final oldEnd = before.dayOf(before.totalDays);
  final newEnd = after.dayOf(after.totalDays);
  final shift = oldEnd.daysUntil(newEnd);
  lines.add(
    EffectLine(
      'Fin de la tontine : ',
      formatDay(newEnd, withYear: true),
      _sentence(' au lieu du ${formatDay(oldEnd)}'),
    ),
  );
  final shiftText = _shiftText(shift);
  return SkipEffect(
    title: todayOnly
        ? '${shiftText[0].toUpperCase()}${shiftText.substring(1)}'
        : '${joinDays(days)} · $shiftText',
    lines: lines,
    shift: shift,
  );
}

/// "Imprévu · demain, jour 37", "reprise mar. 10 nov., jour 37".
String skippedTodayLine(TontineDetail detail, Day today) {
  final terms = detail.terms;
  final reason = detail.skippedDays
      .where((d) => d.day == today.toIso())
      .map((d) => d.reason)
      .firstOrNull;
  final next = terms.dayNumber(today) + 1;
  final resume = terms.dayOf(next);
  final when = resume == today.addDays(1)
      ? 'demain, jour $next'
      : 'reprise ${formatDay(resume)}, jour $next';
  return [?reason, when].join(' · ');
}
