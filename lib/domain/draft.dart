import 'dart:math';

import 'tontine_terms.dart';

/// A member being entered in "Nouvelle tontine · Membres".
class DraftMember {
  const DraftMember({
    required this.key,
    required this.name,
    this.phone,
    required this.halves,
  });

  /// Stable key while the draft is edited (not the database id).
  final String key;
  final String name;
  final String? phone;

  /// Places held, counted in halves (2 = one place, 1 = half a place).
  final int halves;

  DraftMember copyWith({String? name, String? phone, int? halves}) =>
      DraftMember(
        key: key,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        halves: halves ?? this.halves,
      );
}

/// One beneficiary share: a full place or a half place of a member.
class DraftShare {
  const DraftShare({
    required this.memberKey,
    required this.halves,
    required this.placeIndex,
    required this.placeCount,
  });

  final String memberKey;

  /// 2 for a full place, 1 for a half place.
  final int halves;

  /// For a member with several full places: which one this is (1-based),
  /// out of [placeCount]. "Mariam Traoré · place 1 sur 2".
  final int placeIndex;
  final int placeCount;

  bool get isHalf => halves == 1;
}

/// A tour of the draft: one full share, or two half shares.
typedef DraftTour = List<DraftShare>;

int totalHalves(List<DraftMember> members) =>
    members.fold(0, (sum, m) => sum + m.halves);

/// Why the members cannot go to the next step yet, or `null` when they can.
enum MembersProblem {
  /// Fewer places than the tontine has.
  missingPlaces,

  /// More places than the tontine has.
  tooManyPlaces,

  /// A member has no name.
  unnamedMember,
}

MembersProblem? membersProblem(TontineTerms terms, List<DraftMember> members) {
  if (members.any((m) => m.name.trim().isEmpty)) {
    return MembersProblem.unnamedMember;
  }
  final halves = totalHalves(members);
  final expected = terms.places * halvesPerPlace;
  if (halves < expected) return MembersProblem.missingPlaces;
  if (halves > expected) return MembersProblem.tooManyPlaces;
  // With a whole number of places, half places always come in pairs.
  return null;
}

/// Number of half places among [members]: the "N demi-places" of the check
/// line in "Ordre des tours".
int halfPlaceCount(List<DraftMember> members) =>
    members.where((m) => m.halves.isOdd).length;

List<DraftShare> _sharesOf(DraftMember member) {
  final full = member.halves ~/ halvesPerPlace;
  return [
    for (var i = 1; i <= full; i++)
      DraftShare(
        memberKey: member.key,
        halves: 2,
        placeIndex: i,
        placeCount: full,
      ),
    if (member.halves.isOdd)
      DraftShare(
        memberKey: member.key,
        halves: 1,
        placeIndex: 1,
        placeCount: 1,
      ),
  ];
}

/// Tours in the order members were entered. Half places pair up in that
/// order too, each pair taking the place of its first half.
List<DraftTour> defaultTours(List<DraftMember> members) {
  final tours = <DraftTour>[];
  int? pendingIndex;
  for (final member in members) {
    for (final share in _sharesOf(member)) {
      if (!share.isHalf) {
        tours.add([share]);
      } else if (pendingIndex == null) {
        pendingIndex = tours.length;
        tours.add([share]);
      } else {
        tours[pendingIndex] = [...tours[pendingIndex], share];
        pendingIndex = null;
      }
    }
  }
  return tours;
}

/// "Tirer au sort": a random order, with half places paired at random.
List<DraftTour> drawTours(List<DraftMember> members, Random random) {
  final full = <DraftTour>[];
  final halves = <DraftShare>[];
  for (final member in members) {
    for (final share in _sharesOf(member)) {
      share.isHalf ? halves.add(share) : full.add([share]);
    }
  }
  halves.shuffle(random);
  final tours = [
    ...full,
    for (var i = 0; i + 1 < halves.length; i += 2) [halves[i], halves[i + 1]],
  ]..shuffle(random);
  // A member with several places keeps "place 1 sur 2" before "place 2 sur
  // 2" in the drawn order.
  return _renumberPlaces(tours);
}

/// Moves the tour at [from] so that it ends up at index [to] (as given by
/// `onReorderItem`), then renumbers each member's places in tour order.
List<DraftTour> moveTour(List<DraftTour> tours, int from, int to) {
  final result = [...tours];
  final moved = result.removeAt(from);
  result.insert(to, moved);
  return _renumberPlaces(result);
}

List<DraftTour> _renumberPlaces(List<DraftTour> tours) {
  final seen = <String, int>{};
  return [
    for (final tour in tours)
      [
        for (final share in tour)
          share.isHalf
              ? share
              : DraftShare(
                  memberKey: share.memberKey,
                  halves: share.halves,
                  placeIndex: seen[share.memberKey] =
                      (seen[share.memberKey] ?? 0) + 1,
                  placeCount: share.placeCount,
                ),
      ],
  ];
}
