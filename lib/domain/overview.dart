import 'day.dart';
import 'payout.dart';
import 'standing.dart';
import 'tontine_terms.dart';

/// A share of a tour as stored: which member, how many halves.
class SlotInfo {
  const SlotInfo({
    required this.id,
    required this.tour,
    required this.memberId,
    required this.halves,
  });

  final String id;
  final int tour;
  final String memberId;
  final int halves;
}

/// What the "Mes tontines" card shows about a tontine.
class TontineOverview {
  const TontineOverview({
    required this.dayNumber,
    required this.currentTour,
    required this.beneficiaryIds,
    required this.payoutDay,
    required this.lateCount,
    required this.toRecover,
    required this.toursPaidOut,
    required this.finished,
  });

  /// Today's day number: 0 or less before the start, beyond the last day
  /// after the end.
  final int dayNumber;

  /// The tour shown: the one running today, or after the last day the first
  /// tour not paid out yet.
  final int currentTour;
  final List<String> beneficiaryIds;
  final Day payoutDay;

  /// Members late before today ("3 en retard").
  final int lateCount;

  /// Money the organizer advanced and has yet to get back.
  final int toRecover;
  final int toursPaidOut;
  final bool finished;

  bool get started => dayNumber >= 1;
}

TontineOverview overviewOf(
  TontineTerms terms, {
  required Day today,
  required List<MemberAccount> members,
  required List<SlotInfo> slots,
  required Set<String> paidOutSlotIds,
}) {
  final dayNumber = terms.dayNumber(today);

  final tourSlots = <int, List<SlotInfo>>{};
  for (final slot in slots) {
    (tourSlots[slot.tour] ??= []).add(slot);
  }
  bool paidOut(int tour) =>
      (tourSlots[tour] ?? const []).isNotEmpty &&
      tourSlots[tour]!.every((s) => paidOutSlotIds.contains(s.id));

  var toursPaidOut = 0;
  int? lastPaidOutTour;
  for (var tour = 1; tour <= terms.tours; tour++) {
    if (paidOut(tour)) toursPaidOut++;
    if ((tourSlots[tour] ?? const []).any(
      (s) => paidOutSlotIds.contains(s.id),
    )) {
      lastPaidOutTour = tour;
    }
  }

  var currentTour = terms.tourOfDay(dayNumber);
  if (dayNumber > terms.totalDays) {
    currentTour = terms.tours;
    for (var tour = 1; tour <= terms.tours; tour++) {
      if (!paidOut(tour)) {
        currentTour = tour;
        break;
      }
    }
  }

  var lateCount = 0;
  var toRecover = 0;
  for (final member in members) {
    final standing = standingOf(
      terms,
      halves: member.halves,
      paid: member.paid,
      today: dayNumber,
    );
    if (standing.kind == StandingKind.late) lateCount++;
    toRecover += organizerAdvance(
      terms,
      halves: member.halves,
      paid: member.paid,
      lastPaidOutTour: lastPaidOutTour,
    );
  }

  return TontineOverview(
    dayNumber: dayNumber,
    currentTour: currentTour,
    beneficiaryIds: [
      for (final s in tourSlots[currentTour] ?? const <SlotInfo>[]) s.memberId,
    ],
    payoutDay: terms.payoutDay(currentTour),
    lateCount: lateCount,
    toRecover: toRecover,
    toursPaidOut: toursPaidOut,
    finished: toursPaidOut == terms.tours,
  );
}
