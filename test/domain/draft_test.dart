import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/domain/day.dart';
import 'package:matontine/domain/draft.dart';
import 'package:matontine/domain/tontine_terms.dart';

import 'maquette_example.dart';

DraftMember m(String key, int halves) =>
    DraftMember(key: key, name: key, halves: halves);

/// The mockup's members: 17 single places, Mariam with 2 places, Fatou and
/// Aminata with half a place each.
List<DraftMember> mockupMembers() => [
  m('ibrahim', 2),
  m('seydou', 2),
  m('moussa', 2),
  m('koffi', 2),
  m('mariam', 4),
  m('adjoua', 2),
  m('yao', 2),
  m('salimata', 2),
  m('fatou', 1),
  m('aminata', 1),
  for (var i = 0; i < 10; i++) m('member$i', 2),
];

String describe(DraftTour tour) =>
    tour.map((s) => s.isHalf ? '${s.memberKey}½' : s.memberKey).join('+');

void main() {
  group('membersProblem', () {
    test('the mockup members fill the 20 places', () {
      expect(totalHalves(mockupMembers()), 40);
      expect(membersProblem(exampleTerms, mockupMembers()), isNull);
      expect(halfPlaceCount(mockupMembers()), 2);
    });

    test('reports missing or extra places', () {
      final few = mockupMembers()..removeLast();
      expect(membersProblem(exampleTerms, few), MembersProblem.missingPlaces);
      final many = [...mockupMembers(), m('extra', 1)];
      expect(membersProblem(exampleTerms, many), MembersProblem.tooManyPlaces);
    });

    test('a member needs a name', () {
      final members = [
        ...mockupMembers()..removeLast(),
        const DraftMember(key: 'x', name: '  ', halves: 2),
      ];
      expect(
        membersProblem(exampleTerms, members),
        MembersProblem.unnamedMember,
      );
    });
  });

  group('defaultTours', () {
    test('follows the members, two places become two tours', () {
      final tours = defaultTours(mockupMembers());
      expect(tours, hasLength(20));
      expect(tours.take(6).map(describe), [
        'ibrahim',
        'seydou',
        'moussa',
        'koffi',
        'mariam',
        'mariam',
      ]);
      expect(tours[4].single.placeIndex, 1);
      expect(tours[5].single.placeIndex, 2);
      expect(tours[5].single.placeCount, 2);
    });

    test('pairs half places at the first half', () {
      final tours = defaultTours(mockupMembers());
      // Mariam's two places take tours 5 and 6, so Fatou comes tenth.
      expect(describe(tours[9]), 'fatou½+aminata½');
      expect(
        tours.every((t) => t.fold(0, (s, x) => s + x.halves) == 2),
        isTrue,
      );
    });
  });

  test('drawTours keeps every share and pairs the halves', () {
    final tours = drawTours(mockupMembers(), Random(7));
    expect(tours, hasLength(20));
    expect(tours.every((t) => t.fold(0, (s, x) => s + x.halves) == 2), isTrue);
    final mariam = [
      for (final t in tours)
        for (final s in t)
          if (s.memberKey == 'mariam') s.placeIndex,
    ];
    expect(mariam, [1, 2]);
  });

  test('moveTour moves a tour and renumbers places', () {
    final tours = defaultTours(mockupMembers());
    // Move Mariam's second place (tour 6) to the top.
    final moved = moveTour(tours, 5, 0);
    expect(describe(moved.first), 'mariam');
    expect(moved.first.single.placeIndex, 1);
    expect(moved[5].single.placeIndex, 2);
    expect(moved.map(describe).toSet(), tours.map(describe).toSet());
  });

  test('a single place tontine works', () {
    final terms = TontineTerms(
      places: 1,
      contributionPerPlace: 1000,
      tourDays: 5,
      firstDay: Day(2026, 11, 6),
    );
    expect(membersProblem(terms, [m('a', 2)]), isNull);
    expect(defaultTours([m('a', 2)]).single.single.memberKey, 'a');
  });
}
