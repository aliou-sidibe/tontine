import 'day.dart';
import 'overview.dart';
import 'payout.dart';
import 'standing.dart';
import 'tontine_terms.dart';

/// A member as loaded for the "Aujourd'hui" screen.
class MemberData {
  const MemberData({
    required this.id,
    required this.name,
    this.phone,
    required this.position,
    required this.halves,
    required this.paid,
    required this.paidToday,
  });

  final String id;
  final String name;
  final String? phone;
  final int position;

  /// Half places held across all tours.
  final int halves;

  /// Payments not cancelled, plus withheld amounts.
  final int paid;

  /// Cash or mobile money received today (withholdings excluded).
  final int paidToday;
}

/// A member with everything the row of "Aujourd'hui" shows.
class MemberLine {
  const MemberLine({
    required this.member,
    required this.standing,
    required this.advance,
    required this.collectsNow,
  });

  final MemberData member;
  final Standing standing;

  /// What the organizer advanced for this member and has not got back.
  final int advance;

  /// Beneficiary of the tour shown on the green card.
  final bool collectsNow;
}

/// Everything the "Aujourd'hui" screen shows for one tontine.
class TodayView {
  const TodayView({
    required this.dayNumber,
    required this.currentTour,
    required this.beneficiaryIds,
    required this.payoutDay,
    required this.daysToPayout,
    required this.collected,
    required this.expected,
    required this.collectedToday,
    required this.expectedToday,
    required this.lines,
    required this.todaySkipped,
    required this.pendingShares,
  });

  final int dayNumber;
  final int currentTour;
  final List<String> beneficiaryIds;
  final Day payoutDay;

  /// Days from today to the payout (0 today, negative when overdue).
  final int daysToPayout;

  /// Collected and expected for the current tour, through today.
  final int collected;
  final int expected;

  /// "Encaissé aujourd'hui … sur …".
  final int collectedToday;
  final int expectedToday;

  /// Members in display order: late, to collect, up to date, ahead.
  final List<MemberLine> lines;

  /// Today is a skipped day: nothing is due today.
  final bool todaySkipped;

  /// Shares of the current tour whose pot is not handed out yet, in tour
  /// order.
  final List<SlotInfo> pendingShares;

  /// The payout day has come and a share is still to hand out.
  bool get payoutDue => daysToPayout <= 0 && pendingShares.isNotEmpty;

  int get toRecover => lines.fold(0, (sum, l) => sum + l.advance);

  /// Members the organizer advanced money for.
  List<MemberLine> get owingOrganizer => [
    for (final l in lines)
      if (l.advance > 0) l,
  ];

  int get toCollectCount => lines.where((l) => l.standing.balance < 0).length;

  int get lateCount =>
      lines.where((l) => l.standing.kind == StandingKind.late).length;
}

const _order = {
  StandingKind.late: 0,
  StandingKind.toCollect: 1,
  StandingKind.upToDate: 2,
  StandingKind.ahead: 3,
};

TodayView todayView(
  TontineTerms terms, {
  required Day today,
  required List<MemberData> members,
  required List<SlotInfo> slots,
  required Set<String> paidOutSlotIds,
}) {
  final overview = overviewOf(
    terms,
    today: today,
    members: [
      for (final m in members)
        MemberAccount(id: m.id, halves: m.halves, paid: m.paid),
    ],
    slots: slots,
    paidOutSlotIds: paidOutSlotIds,
  );
  final dayNumber = overview.dayNumber;

  int? lastPaidOutTour;
  for (final slot in slots) {
    if (paidOutSlotIds.contains(slot.id) &&
        (lastPaidOutTour == null || slot.tour > lastPaidOutTour)) {
      lastPaidOutTour = slot.tour;
    }
  }

  final beneficiaries = overview.beneficiaryIds.toSet();
  final lines =
      [
        for (final m in members)
          MemberLine(
            member: m,
            standing: standingOf(
              terms,
              halves: m.halves,
              paid: m.paid,
              today: dayNumber,
              yesterday: terms.dayNumber(today.addDays(-1)),
            ),
            advance: organizerAdvance(
              terms,
              halves: m.halves,
              paid: m.paid,
              lastPaidOutTour: lastPaidOutTour,
            ),
            collectsNow: beneficiaries.contains(m.id),
          ),
      ]..sort((a, b) {
        final byKind = _order[a.standing.kind]!.compareTo(
          _order[b.standing.kind]!,
        );
        return byKind != 0
            ? byKind
            : a.member.position.compareTo(b.member.position);
      });

  final progress = tourProgress(
    terms,
    tour: overview.currentTour,
    today: dayNumber,
    members: [
      for (final m in members)
        MemberAccount(id: m.id, halves: m.halves, paid: m.paid),
    ],
  );
  final skipped = terms.isSkipped(today);
  final contributing =
      !skipped && dayNumber >= 1 && dayNumber <= terms.totalDays;

  return TodayView(
    dayNumber: dayNumber,
    currentTour: overview.currentTour,
    beneficiaryIds: overview.beneficiaryIds,
    payoutDay: overview.payoutDay,
    daysToPayout: today.daysUntil(overview.payoutDay),
    collected: progress.collected,
    expected: progress.expected,
    collectedToday: members.fold(0, (sum, m) => sum + m.paidToday),
    expectedToday: contributing ? terms.dailyTotal : 0,
    lines: lines,
    todaySkipped: skipped,
    pendingShares: [
      for (final s in slots)
        if (s.tour == overview.currentTour && !paidOutSlotIds.contains(s.id)) s,
    ],
  );
}
