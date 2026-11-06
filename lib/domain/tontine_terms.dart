import 'day.dart';

/// Number of half places in one full place. Places are counted in halves so
/// that every amount stays an integer.
const halvesPerPlace = 2;

/// The fixed terms of a tontine, chosen at creation.
///
/// Day numbers start at 1 on [firstDay]. One place equals one tour equals
/// one pot, so there are as many tours as [places].
class TontineTerms {
  TontineTerms({
    required this.places,
    required this.contributionPerPlace,
    required this.tourDays,
    required this.firstDay,
  }) {
    if (places < 1) throw ArgumentError.value(places, 'places');
    if (tourDays < 1) throw ArgumentError.value(tourDays, 'tourDays');
    if (contributionPerPlace <= 0 || contributionPerPlace % 10 != 0) {
      // A multiple of 10 F keeps the half-place contribution a round amount.
      throw ArgumentError.value(contributionPerPlace, 'contributionPerPlace');
    }
  }

  /// Number of places, which is also the number of tours.
  final int places;

  /// Contribution of one full place for one day, in FCFA.
  final int contributionPerPlace;

  /// Number of contribution days in one tour.
  final int tourDays;

  /// Day 1 of the tontine.
  final Day firstDay;

  int get tours => places;

  int get totalDays => places * tourDays;

  /// What one full place pays over one tour.
  int get perPlacePerTour => contributionPerPlace * tourDays;

  /// The pot collected over one tour, handed out on its last day.
  int get potPerTour => places * perPlacePerTour;

  /// Contribution of everyone for one day.
  int get dailyTotal => places * contributionPerPlace;

  /// Day number of [day]: 1 on [firstDay], 0 or less before it.
  int dayNumber(Day day) => firstDay.daysUntil(day) + 1;

  Day dayOf(int dayNumber) => firstDay.addDays(dayNumber - 1);

  /// Tour containing [dayNumber], clamped to the first and last tours.
  int tourOfDay(int dayNumber) {
    if (dayNumber < 1) return 1;
    final tour = (dayNumber - 1) ~/ tourDays + 1;
    return tour > tours ? tours : tour;
  }

  int firstDayOfTour(int tour) => (tour - 1) * tourDays + 1;

  int lastDayOfTour(int tour) => tour * tourDays;

  /// The pot is handed out on the tour's last day (day J), once that day's
  /// contributions are collected.
  Day payoutDay(int tour) => dayOf(lastDayOfTour(tour));

  /// Daily contribution of a member holding [halves] half places.
  int dailyDue(int halves) => halves * contributionPerPlace ~/ halvesPerPlace;

  /// What a member holding [halves] owes from day 1 through [dayNumber].
  int dueThrough(int halves, int dayNumber) =>
      dailyDue(halves) * _clampDay(dayNumber);

  /// Share of a member's payments that covers [tour], up to [dayNumber].
  ///
  /// Payments always cover the oldest days first, so a late member repays
  /// earlier tours (and the organizer who topped them up) before this one.
  int collectedForTour(int halves, int paid, int tour, {int? throughDay}) {
    final before = dueThrough(halves, firstDayOfTour(tour) - 1);
    final end = throughDay == null || throughDay > lastDayOfTour(tour)
        ? lastDayOfTour(tour)
        : throughDay;
    final owedInTour = dueThrough(halves, end) - before;
    if (owedInTour <= 0) return 0;
    final covering = paid - before;
    if (covering <= 0) return 0;
    return covering > owedInTour ? owedInTour : covering;
  }

  int _clampDay(int dayNumber) {
    if (dayNumber < 0) return 0;
    return dayNumber > totalDays ? totalDays : dayNumber;
  }
}
