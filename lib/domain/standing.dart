import 'tontine_terms.dart';

/// How a member stands on a given day, as shown on the "Aujourd'hui" screen.
enum StandingKind {
  /// Behind before today: "Retard X F".
  late,

  /// Up to date until yesterday, today not paid yet: "À encaisser X F".
  toCollect,

  /// Exactly up to date: "Payé aujourd'hui" or "À jour".
  upToDate,

  /// Paid beyond today: "Avance X F".
  ahead,
}

class Standing {
  const Standing({
    required this.kind,
    required this.paid,
    required this.due,
    required this.upToDay,
  });

  final StandingKind kind;

  /// Payments not cancelled, plus amounts withheld from the member's pots.
  final int paid;

  /// Owed from day 1 through today.
  final int due;

  /// Last day fully covered by [paid] ("à jour jusqu'au jour X").
  final int upToDay;

  /// Positive when ahead, negative when behind.
  int get balance => paid - due;

  /// The amount on the badge: what is missing, or what is ahead.
  int get badgeAmount => balance.abs();
}

/// Standing of a member holding [halves] half places on [today] (a day
/// number), given everything [paid] so far.
Standing standingOf(
  TontineTerms terms, {
  required int halves,
  required int paid,
  required int today,
}) {
  final due = terms.dueThrough(halves, today);
  final dueYesterday = terms.dueThrough(halves, today - 1);
  final daily = terms.dailyDue(halves);
  var upToDay = daily == 0 ? 0 : paid ~/ daily;
  if (upToDay > terms.totalDays) upToDay = terms.totalDays;

  final StandingKind kind;
  if (paid > due) {
    kind = StandingKind.ahead;
  } else if (paid == due) {
    kind = StandingKind.upToDate;
  } else if (paid >= dueYesterday) {
    kind = StandingKind.toCollect;
  } else {
    kind = StandingKind.late;
  }
  return Standing(kind: kind, paid: paid, due: due, upToDay: upToDay);
}

/// What the organizer advanced for this member and has yet to get back:
/// what the member still owes for tours already paid out.
int organizerAdvance(
  TontineTerms terms, {
  required int halves,
  required int paid,
  required int? lastPaidOutTour,
}) {
  if (lastPaidOutTour == null) return 0;
  final owed =
      terms.dueThrough(halves, terms.lastDayOfTour(lastPaidOutTour)) - paid;
  return owed > 0 ? owed : 0;
}
