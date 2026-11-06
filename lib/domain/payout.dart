import 'tontine_terms.dart';

/// A member's holding and payments, as needed by the calculations.
class MemberAccount {
  const MemberAccount({
    required this.id,
    required this.halves,
    required this.paid,
  });

  final String id;

  /// Half places held across all tours (2 = one place).
  final int halves;

  /// Payments not cancelled, plus amounts already withheld.
  final int paid;
}

/// One beneficiary share of a tour: a full place, or one of two halves.
class TourShare {
  const TourShare({required this.memberId, required this.halves});

  final String memberId;

  /// 2 for a full place, 1 for a half place.
  final int halves;
}

/// The "Remise de la cagnotte" lines for one beneficiary share.
class PayoutBreakdown {
  const PayoutBreakdown({
    required this.memberId,
    required this.pot,
    required this.collected,
    required this.organizerTopUp,
    required this.withheld,
    required this.arrears,
  });

  final String memberId;

  /// "Cagnotte du tour": the whole pot, or half of it for a half place.
  final int pot;

  /// "Versé par les membres": the part of the pot members actually paid.
  final int collected;

  /// "Tu complètes de ta poche": other members' shortfall on this tour.
  final int organizerTopUp;

  /// "Retenue": the beneficiary's own arrears through the tour's last day,
  /// at most the pot.
  final int withheld;

  /// The beneficiary's whole arrears through the tour's last day. More than
  /// [withheld] only when they exceed the pot.
  final int arrears;

  /// "À remettre".
  int get handed => pot - withheld;
}

/// What each beneficiary of [tour] receives, given every member's account.
///
/// Members who are short on this tour are topped up by the organizer; a
/// beneficiary who is short has all his arrears withheld instead, which also
/// repays the organizer for earlier tours.
List<PayoutBreakdown> computePayout(
  TontineTerms terms, {
  required int tour,
  required List<TourShare> shares,
  required List<MemberAccount> members,
}) {
  final halvesInTour = shares.fold<int>(0, (sum, s) => sum + s.halves);
  if (halvesInTour != halvesPerPlace) {
    throw ArgumentError('A tour holds one place: one full or two halves.');
  }
  final beneficiaryIds = shares.map((s) => s.memberId).toSet();
  final byId = {for (final m in members) m.id: m};

  int shortfall(MemberAccount m) => _tourShortfall(terms, m, tour);

  final othersShortfall = othersShortfalls(
    terms,
    tour: tour,
    beneficiaryIds: beneficiaryIds,
    members: members,
  ).values.fold<int>(0, (sum, v) => sum + v);

  final lastDay = terms.lastDayOfTour(tour);
  final result = <PayoutBreakdown>[];
  var topUpLeft = othersShortfall;
  for (var i = 0; i < shares.length; i++) {
    final share = shares[i];
    final member = byId[share.memberId];
    if (member == null) {
      throw ArgumentError('Unknown beneficiary ${share.memberId}.');
    }
    final pot = terms.potPerTour * share.halves ~/ halvesPerPlace;
    // The last share takes the remainder, so the halves add up exactly.
    final topUp = i == shares.length - 1
        ? topUpLeft
        : othersShortfall * share.halves ~/ halvesPerPlace;
    topUpLeft -= topUp;
    final arrears = terms.dueThrough(member.halves, lastDay) - member.paid;
    // Only the beneficiary's shortfall on this tour is missing from the pot;
    // the rest of his arrears was already topped up on earlier tours. All of
    // it, even when he holds several places: they all pay into this pot.
    final ownShortfall = shortfall(member);
    result.add(
      PayoutBreakdown(
        memberId: share.memberId,
        pot: pot,
        collected: pot - topUp - ownShortfall,
        organizerTopUp: topUp,
        // A member with several places may owe more than his pot: the
        // withholding stops at the pot, the rest stays owed.
        withheld: arrears <= 0 ? 0 : (arrears > pot ? pot : arrears),
        arrears: arrears > 0 ? arrears : 0,
      ),
    );
  }
  return result;
}

/// What [member] is missing on [tour] once all his payments are counted.
int _tourShortfall(TontineTerms terms, MemberAccount member, int tour) =>
    terms.dailyDue(member.halves) * terms.tourDays -
    terms.collectedForTour(member.halves, member.paid, tour);

/// Members other than the beneficiaries who are short on [tour], with what
/// they miss: the organizer tops it up and they owe it to him ("Seydou Koné
/// 25 000 F · Moussa Diallo 15 000 F. Ils te les devront.").
Map<String, int> othersShortfalls(
  TontineTerms terms, {
  required int tour,
  required Set<String> beneficiaryIds,
  required List<MemberAccount> members,
}) => {
  for (final m in members)
    if (!beneficiaryIds.contains(m.id) && _tourShortfall(terms, m, tour) > 0)
      m.id: _tourShortfall(terms, m, tour),
};

/// Progress of the current tour for the green card on "Aujourd'hui":
/// collected so far against what was due through [today].
({int collected, int expected}) tourProgress(
  TontineTerms terms, {
  required int tour,
  required int today,
  required List<MemberAccount> members,
}) {
  final first = terms.firstDayOfTour(tour);
  final last = terms.lastDayOfTour(tour);
  final through = today < first - 1 ? first - 1 : (today > last ? last : today);
  var collected = 0;
  var expected = 0;
  for (final m in members) {
    collected += terms.collectedForTour(
      m.halves,
      m.paid,
      tour,
      throughDay: through,
    );
    expected +=
        terms.dueThrough(m.halves, through) -
        terms.dueThrough(m.halves, first - 1);
  }
  return (collected: collected, expected: expected);
}
