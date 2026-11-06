import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/day.dart';
import '../data/tontine_repository.dart' show todayProvider;
import '../domain/draft.dart';
import '../domain/draft.dart' as draft show moveTour;
import '../domain/tontine_terms.dart';

/// Everything entered in "Nouvelle tontine", kept across the four steps.
class CreationDraft {
  const CreationDraft({
    this.step = 1,
    this.name = '',
    this.places,
    this.contributionPerPlace,
    this.tourDays,
    required this.firstDay,
    this.members = const [],
    this.tours,
  });

  /// 1 Paramètres, 2 Membres, 3 Ordre, 4 Récap.
  final int step;
  final String name;
  final int? places;
  final int? contributionPerPlace;
  final int? tourDays;
  final Day firstDay;
  final List<DraftMember> members;

  /// Set when the order step opens; reset when the members change.
  final List<DraftTour>? tours;

  /// The terms, or `null` while a parameter is missing or invalid.
  TontineTerms? get terms {
    final places = this.places;
    final contribution = contributionPerPlace;
    final tourDays = this.tourDays;
    if (places == null || contribution == null || tourDays == null) {
      return null;
    }
    try {
      return TontineTerms(
        places: places,
        contributionPerPlace: contribution,
        tourDays: tourDays,
        firstDay: firstDay,
      );
    } on ArgumentError {
      return null;
    }
  }

  bool get parametersValid => name.trim().isNotEmpty && terms != null;

  CreationDraft copyWith({
    int? step,
    String? name,
    int? Function()? places,
    int? Function()? contributionPerPlace,
    int? Function()? tourDays,
    Day? firstDay,
    List<DraftMember>? members,
    List<DraftTour>? Function()? tours,
  }) => CreationDraft(
    step: step ?? this.step,
    name: name ?? this.name,
    places: places != null ? places() : this.places,
    contributionPerPlace: contributionPerPlace != null
        ? contributionPerPlace()
        : this.contributionPerPlace,
    tourDays: tourDays != null ? tourDays() : this.tourDays,
    firstDay: firstDay ?? this.firstDay,
    members: members ?? this.members,
    tours: tours != null ? tours() : this.tours,
  );
}

class CreationNotifier extends Notifier<CreationDraft> {
  var _nextKey = 0;

  @override
  CreationDraft build() => CreationDraft(firstDay: ref.read(todayProvider));

  void setName(String name) => state = state.copyWith(name: name);

  void setPlaces(int? places) =>
      state = state.copyWith(places: () => places, tours: () => null);

  void setContribution(int? amount) =>
      state = state.copyWith(contributionPerPlace: () => amount);

  void setTourDays(int? days) => state = state.copyWith(tourDays: () => days);

  void setFirstDay(Day day) => state = state.copyWith(firstDay: day);

  /// Adds a member and returns its key.
  String addMember({required String name, String? phone, required int halves}) {
    final key = 'm${_nextKey++}';
    state = state.copyWith(
      members: [
        ...state.members,
        DraftMember(key: key, name: name.trim(), phone: phone, halves: halves),
      ],
      tours: () => null,
    );
    return key;
  }

  void updateMember(
    String key, {
    required String name,
    String? phone,
    required int halves,
  }) {
    state = state.copyWith(
      members: [
        for (final m in state.members)
          if (m.key == key)
            DraftMember(
              key: key,
              name: name.trim(),
              phone: phone,
              halves: halves,
            )
          else
            m,
      ],
      tours: () => null,
    );
  }

  void removeMember(String key) {
    state = state.copyWith(
      members: [
        for (final m in state.members)
          if (m.key != key) m,
      ],
      tours: () => null,
    );
  }

  /// Goes to [step]. Entering the order step builds the default order once.
  void goTo(int step) {
    var next = state.copyWith(step: step);
    if (step == 3 && next.tours == null) {
      next = next.copyWith(tours: () => defaultTours(next.members));
    }
    state = next;
  }

  void draw([Random? random]) {
    state = state.copyWith(
      tours: () => drawTours(state.members, random ?? Random()),
    );
  }

  void moveTour(int from, int to) {
    final tours = state.tours;
    if (tours == null) return;
    state = state.copyWith(tours: () => draft.moveTour(tours, from, to));
  }
}

final creationProvider =
    NotifierProvider.autoDispose<CreationNotifier, CreationDraft>(
      CreationNotifier.new,
    );
