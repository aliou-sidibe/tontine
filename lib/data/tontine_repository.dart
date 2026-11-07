import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/day.dart';
import '../domain/draft.dart';
import '../domain/overview.dart';
import '../domain/payout.dart';
import '../domain/today.dart';
import '../domain/tontine_terms.dart';
import 'app_database.dart';
import 'tables.dart';
import 'providers.dart';

/// A tontine with what its "Mes tontines" card needs.
class TontineCard {
  const TontineCard({
    required this.id,
    required this.name,
    required this.terms,
    required this.overview,
    required this.memberNames,
  });

  final String id;
  final String name;
  final TontineTerms terms;
  final TontineOverview overview;

  /// Member names by id.
  final Map<String, String> memberNames;
}

class TontineRepository {
  TontineRepository(this._db);

  final AppDatabase _db;

  /// Saves a new tontine, its members and its tours in one transaction:
  /// a phone switched off midway leaves no half-created tontine.
  Future<String> create({
    required String name,
    required TontineTerms terms,
    required List<DraftMember> members,
    required List<DraftTour> tours,
  }) {
    if (membersProblem(terms, members) != null) {
      throw ArgumentError('The members do not fill the places.');
    }
    if (tours.length != terms.tours) {
      throw ArgumentError('There must be one tour per place.');
    }
    return _db.transaction(() async {
      final tontine = await _db
          .into(_db.tontines)
          .insertReturning(
            TontinesCompanion.insert(
              name: name.trim(),
              places: terms.places,
              contributionPerPlace: terms.contributionPerPlace,
              tourDays: terms.tourDays,
              firstDay: terms.firstDay.toIso(),
            ),
          );
      final memberIds = <String, String>{};
      for (final (index, member) in members.indexed) {
        final phone = member.phone?.trim();
        final row = await _db
            .into(_db.members)
            .insertReturning(
              MembersCompanion.insert(
                tontineId: tontine.id,
                name: member.name.trim(),
                phone: Value(phone == null || phone.isEmpty ? null : phone),
                position: index,
              ),
            );
        memberIds[member.key] = row.id;
      }
      for (final (index, tour) in tours.indexed) {
        for (final share in tour) {
          await _db
              .into(_db.slots)
              .insert(
                SlotsCompanion.insert(
                  tontineId: tontine.id,
                  tour: index + 1,
                  memberId: memberIds[share.memberKey]!,
                  halves: share.halves,
                ),
              );
        }
      }
      return tontine.id;
    });
  }

  /// Every tontine with its overview on [today], newest first.
  Future<List<TontineCard>> cards(Day today) async {
    final tontines = await (_db.select(
      _db.tontines,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    return [for (final t in tontines) await _card(t, today)];
  }

  Future<TontineCard> _card(TontineRow tontine, Day today) async {
    final terms = termsOf(tontine, await _skippedDays(tontine.id));
    final members = await (_db.select(
      _db.members,
    )..where((m) => m.tontineId.equals(tontine.id))).get();
    final slots = await (_db.select(
      _db.slots,
    )..where((s) => s.tontineId.equals(tontine.id))).get();
    final paid = await paidByMember(tontine.id);
    final paidOut = await paidOutSlotIds(tontine.id);

    final halves = <String, int>{};
    for (final slot in slots) {
      halves[slot.memberId] = (halves[slot.memberId] ?? 0) + slot.halves;
    }
    return TontineCard(
      id: tontine.id,
      name: tontine.name,
      terms: terms,
      memberNames: {for (final m in members) m.id: m.name},
      overview: overviewOf(
        terms,
        today: today,
        members: [
          for (final m in members)
            MemberAccount(
              id: m.id,
              halves: halves[m.id] ?? 0,
              paid: paid[m.id] ?? 0,
            ),
        ],
        slots: [
          for (final s in slots)
            SlotInfo(
              id: s.id,
              tour: s.tour,
              memberId: s.memberId,
              halves: s.halves,
            ),
        ],
        paidOutSlotIds: paidOut,
      ),
    );
  }

  /// Everything about one tontine, for "Aujourd'hui", "Membres" and the
  /// member page.
  Future<TontineDetail> detail(String tontineId) async {
    final tontine = await (_db.select(
      _db.tontines,
    )..where((t) => t.id.equals(tontineId))).getSingle();
    final members =
        await (_db.select(_db.members)
              ..where((m) => m.tontineId.equals(tontineId))
              ..orderBy([(m) => OrderingTerm.asc(m.position)]))
            .get();
    final position = {for (final m in members) m.id: m.position};
    // In tour order, and two halves in members' entry order: always the
    // same display ("Fatou Bamba ½ + Aminata Koné ½") and the same split of
    // the top-up.
    final slots =
        await (_db.select(
            _db.slots,
          )..where((s) => s.tontineId.equals(tontineId))).get()
          ..sort((a, b) {
            final byTour = a.tour.compareTo(b.tour);
            return byTour != 0
                ? byTour
                : position[a.memberId]!.compareTo(position[b.memberId]!);
          });
    final cancellations = {
      for (final c in await _db.select(_db.paymentCancellations).get())
        c.paymentId: c,
    };
    final payments =
        await (_db.select(_db.payments)
              ..where((p) => p.tontineId.equals(tontineId))
              ..orderBy([
                (p) => OrderingTerm.desc(p.paidOn),
                (p) => OrderingTerm.desc(p.createdAt),
              ]))
            .get();
    final cancelledPayouts = {
      for (final c in await _db.select(_db.payoutCancellations).get())
        c.payoutId,
    };
    final payouts =
        await (_db.select(_db.payouts)
              ..where((p) => p.tontineId.equals(tontineId))
              ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
            .get();
    final skippedDays = await _skippedDays(tontineId);
    return TontineDetail(
      id: tontine.id,
      name: tontine.name,
      terms: termsOf(tontine, skippedDays),
      members: members,
      slots: slots,
      payouts: [
        for (final p in payouts)
          PayoutEntry(row: p, cancelled: cancelledPayouts.contains(p.id)),
      ],
      payments: [
        for (final p in payments)
          PaymentEntry(
            id: p.id,
            memberId: p.memberId,
            amount: p.amount,
            method: p.method,
            paidOn: Day.parse(p.paidOn),
            cancelled: cancellations.containsKey(p.id),
            cancelReason: cancellations[p.id]?.reason,
          ),
      ],
      paidOutSlotIds: await paidOutSlotIds(tontineId),
      skippedDays: skippedDays,
    );
  }

  Future<List<SkippedDayRow>> _skippedDays(String tontineId) =>
      (_db.select(_db.skippedDays)
            ..where((d) => d.tontineId.equals(tontineId))
            ..orderBy([(d) => OrderingTerm.asc(d.day)]))
          .get();

  /// Skips [days] for the whole tontine: nobody contributes on them, and
  /// every later payout and the end move back. Only today or a later day,
  /// before the end, and never a day on or before a pot already handed out.
  Future<void> skipDays({
    required String tontineId,
    required Iterable<Day> days,
    String? reason,
    required Day today,
  }) {
    final chosen = days.toSet();
    if (chosen.isEmpty) throw ArgumentError('No day to skip.');
    final trimmed = reason?.trim();
    return _db.transaction(() async {
      final tontine = await (_db.select(
        _db.tontines,
      )..where((t) => t.id.equals(tontineId))).getSingle();
      final existing = await _skippedDays(tontineId);
      final terms = termsOf(tontine, existing);
      final after = terms.withSkippedDays(chosen);
      final end = after.dayOf(after.totalDays);
      final lastPayout =
          await (_db.selectOnly(_db.payouts)
                ..addColumns([_db.payouts.paidOn.max()])
                ..where(
                  _db.payouts.tontineId.equals(tontineId) &
                      _db.payouts.id.isNotInQuery(
                        _db.selectOnly(_db.payoutCancellations)
                          ..addColumns([_db.payoutCancellations.payoutId]),
                      ),
                ))
              .map((r) => r.read(_db.payouts.paidOn.max()))
              .getSingle();
      for (final day in chosen) {
        if (day.isBefore(today)) {
          throw StateError('Only today or a later day can be skipped.');
        }
        if (terms.isSkipped(day)) throw StateError('$day is already skipped.');
        if (day.isBefore(terms.firstDay) || day.isAfter(end)) {
          throw StateError('$day is outside the tontine.');
        }
        if (lastPayout != null && !day.isAfter(Day.parse(lastPayout))) {
          throw StateError('A pot was handed out on or after $day.');
        }
      }
      for (final day in chosen) {
        await _db
            .into(_db.skippedDays)
            .insert(
              SkippedDaysCompanion.insert(
                tontineId: tontineId,
                day: day.toIso(),
                reason: Value(
                  trimmed == null || trimmed.isEmpty ? null : trimmed,
                ),
              ),
            );
      }
    });
  }

  /// Contributes again on a skipped day that has not passed yet: it never
  /// counted, so it leaves no trace.
  Future<void> unskipDay(String skippedDayId, {required Day today}) async {
    final row = await (_db.select(
      _db.skippedDays,
    )..where((d) => d.id.equals(skippedDayId))).getSingle();
    if (Day.parse(row.day).isBefore(today)) {
      throw StateError('A day already passed stays skipped.');
    }
    await (_db.delete(
      _db.skippedDays,
    )..where((d) => d.id.equals(skippedDayId))).go();
  }

  /// Records money received from a member. Append-only.
  Future<String> addPayment({
    required String tontineId,
    required String memberId,
    required int amount,
    required PaymentMethod method,
    required Day paidOn,
  }) async {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount');
    if (method == PaymentMethod.withheld) {
      throw ArgumentError('Withholdings are recorded with the payout.');
    }
    final row = await _db
        .into(_db.payments)
        .insertReturning(
          PaymentsCompanion.insert(
            tontineId: tontineId,
            memberId: memberId,
            amount: amount,
            method: method,
            paidOn: paidOn.toIso(),
          ),
        );
    return row.id;
  }

  /// Cancels a payment with a counter-entry: the payment stays in the
  /// history, crossed out.
  Future<void> cancelPayment(String paymentId, {String? reason}) async {
    final payment = await (_db.select(
      _db.payments,
    )..where((p) => p.id.equals(paymentId))).getSingle();
    if (payment.method == PaymentMethod.withheld) {
      // It goes with its payout: cancel the payout instead.
      throw StateError('A withholding is cancelled with its payout.');
    }
    final trimmed = reason?.trim();
    await _db
        .into(_db.paymentCancellations)
        .insert(
          PaymentCancellationsCompanion.insert(
            paymentId: paymentId,
            reason: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Hands out the pot of one share ("Confirmer la remise de X F") and
  /// withholds the beneficiary's arrears, in one transaction. The amounts are
  /// recomputed here from the stored payments, never taken from the screen.
  Future<String> recordPayout({
    required String tontineId,
    required String slotId,
    required PayoutMethod method,
    required Day day,
  }) {
    return _db.transaction(() async {
      final tontine = await detail(tontineId);
      final slot = tontine.slots.where((s) => s.id == slotId).firstOrNull;
      if (slot == null) throw ArgumentError.value(slotId, 'slotId');
      if (tontine.paidOutSlotIds.contains(slotId)) {
        throw StateError('This pot was already handed out.');
      }
      if (day.isBefore(tontine.terms.payoutDay(slot.tour))) {
        throw StateError('The pot is handed out after the tour ends.');
      }
      final breakdown = tontine.payoutFor(slotId);
      final payout = await _db
          .into(_db.payouts)
          .insertReturning(
            PayoutsCompanion.insert(
              tontineId: tontineId,
              slotId: slotId,
              paidOn: day.toIso(),
              pot: breakdown.pot,
              collected: breakdown.collected,
              organizerTopUp: breakdown.organizerTopUp,
              withheld: breakdown.withheld,
              handed: breakdown.handed,
              method: method,
            ),
          );
      if (breakdown.withheld > 0) {
        // The beneficiary pays his arrears out of his own pot.
        await _db
            .into(_db.payments)
            .insert(
              PaymentsCompanion.insert(
                tontineId: tontineId,
                memberId: slot.memberId,
                amount: breakdown.withheld,
                method: PaymentMethod.withheld,
                paidOn: day.toIso(),
                payoutId: Value(payout.id),
              ),
            );
      }
      return payout.id;
    });
  }

  /// Cancels a payout with a counter-entry, and the amount withheld with it:
  /// the beneficiary owes his arrears again.
  Future<void> cancelPayout(String payoutId, {String? reason}) {
    final trimmed = reason?.trim();
    final why = Value(trimmed == null || trimmed.isEmpty ? null : trimmed);
    return _db.transaction(() async {
      await _db
          .into(_db.payoutCancellations)
          .insert(
            PayoutCancellationsCompanion.insert(
              payoutId: payoutId,
              reason: why,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      final withheld = await (_db.select(
        _db.payments,
      )..where((p) => p.payoutId.equals(payoutId))).get();
      for (final payment in withheld) {
        await _db
            .into(_db.paymentCancellations)
            .insert(
              PaymentCancellationsCompanion.insert(
                paymentId: payment.id,
                reason: why,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }

  /// Swaps the beneficiaries of [tourA] and [tourB], neither paid out yet,
  /// and keeps the swap in the history.
  Future<void> swapTours({
    required String tontineId,
    required int tourA,
    required int tourB,
  }) {
    if (tourA == tourB) throw ArgumentError('Two different tours are needed.');
    return _db.transaction(() async {
      final tontine = await (_db.select(
        _db.tontines,
      )..where((t) => t.id.equals(tontineId))).getSingle();
      for (final tour in [tourA, tourB]) {
        if (tour < 1 || tour > tontine.places) {
          throw ArgumentError.value(tour, 'tour');
        }
      }
      final slots =
          await (_db.select(_db.slots)..where(
                (s) =>
                    s.tontineId.equals(tontineId) & s.tour.isIn([tourA, tourB]),
              ))
              .get();
      final paidOut = await paidOutSlotIds(tontineId);
      if (slots.any((s) => paidOut.contains(s.id))) {
        throw StateError('A tour already paid out cannot be swapped.');
      }
      for (final slot in slots) {
        await (_db.update(_db.slots)..where((s) => s.id.equals(slot.id))).write(
          SlotsCompanion(tour: Value(slot.tour == tourA ? tourB : tourA)),
        );
      }
      await _db
          .into(_db.tourSwaps)
          .insert(
            TourSwapsCompanion.insert(
              tontineId: tontineId,
              tourA: tourA,
              tourB: tourB,
            ),
          );
    });
  }

  /// Payments not cancelled, by member, withheld amounts included.
  Future<Map<String, int>> paidByMember(String tontineId) async {
    final rows = await _db
        .customSelect(
          'SELECT member_id, SUM(amount) AS total FROM payment '
          'WHERE tontine_id = ? AND id NOT IN '
          '(SELECT payment_id FROM payment_cancellation) '
          'GROUP BY member_id',
          variables: [Variable.withString(tontineId)],
          readsFrom: {_db.payments, _db.paymentCancellations},
        )
        .get();
    return {
      for (final r in rows) r.read<String>('member_id'): r.read<int>('total'),
    };
  }

  /// Slots whose pot was handed out and not cancelled.
  Future<Set<String>> paidOutSlotIds(String tontineId) async {
    final rows = await _db
        .customSelect(
          'SELECT slot_id FROM payout WHERE tontine_id = ? AND id NOT IN '
          '(SELECT payout_id FROM payout_cancellation)',
          variables: [Variable.withString(tontineId)],
          readsFrom: {_db.payouts, _db.payoutCancellations},
        )
        .get();
    return {for (final r in rows) r.read<String>('slot_id')};
  }
}

/// A payout as stored, with its cancellation.
class PayoutEntry {
  const PayoutEntry({required this.row, required this.cancelled});

  final PayoutRow row;
  final bool cancelled;
}

/// A payment as shown in the member history.
class PaymentEntry {
  const PaymentEntry({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.method,
    required this.paidOn,
    required this.cancelled,
    this.cancelReason,
  });

  final String id;
  final String memberId;
  final int amount;
  final PaymentMethod method;
  final Day paidOn;
  final bool cancelled;
  final String? cancelReason;
}

class TontineDetail {
  const TontineDetail({
    required this.id,
    required this.name,
    required this.terms,
    required this.members,
    required this.slots,
    required this.payouts,
    required this.payments,
    required this.paidOutSlotIds,
    required this.skippedDays,
  });

  final String id;
  final String name;
  final TontineTerms terms;

  /// In entry order.
  final List<MemberRow> members;

  /// In tour order.
  final List<SlotRow> slots;

  /// Oldest first, cancelled ones included.
  final List<PayoutEntry> payouts;

  /// Newest first, cancelled ones included.
  final List<PaymentEntry> payments;
  final Set<String> paidOutSlotIds;

  /// In day order.
  final List<SkippedDayRow> skippedDays;

  int halvesOf(String memberId) => slots
      .where((s) => s.memberId == memberId)
      .fold(0, (sum, s) => sum + s.halves);

  List<SlotRow> slotsOf(String memberId) => [
    for (final s in slots)
      if (s.memberId == memberId) s,
  ];

  List<PaymentEntry> paymentsOf(String memberId) => [
    for (final p in payments)
      if (p.memberId == memberId) p,
  ];

  /// Shares of [tour], in stored order.
  List<SlotRow> sharesOf(int tour) => [
    for (final s in slots)
      if (s.tour == tour) s,
  ];

  /// The payout of [slotId] that is not cancelled, if any.
  PayoutRow? payoutOf(String slotId) => payouts
      .where((p) => !p.cancelled && p.row.slotId == slotId)
      .map((p) => p.row)
      .firstOrNull;

  /// Every member's places and payments, for the calculations.
  List<MemberAccount> accounts() {
    final paid = <String, int>{};
    for (final p in payments) {
      if (!p.cancelled) paid[p.memberId] = (paid[p.memberId] ?? 0) + p.amount;
    }
    return [
      for (final m in members)
        MemberAccount(id: m.id, halves: halvesOf(m.id), paid: paid[m.id] ?? 0),
    ];
  }

  /// "Remise de la cagnotte" for one share, from today's payments.
  PayoutBreakdown payoutFor(String slotId) {
    final slot = slots.firstWhere((s) => s.id == slotId);
    final shares = sharesOf(slot.tour);
    final breakdowns = computePayout(
      terms,
      tour: slot.tour,
      shares: [
        for (final s in shares)
          TourShare(memberId: s.memberId, halves: s.halves),
      ],
      members: accounts(),
    );
    return breakdowns[shares.indexOf(slot)];
  }

  /// Members the organizer tops up for on [tour], with their shortfall.
  Map<String, int> topUpsFor(int tour) => othersShortfalls(
    terms,
    tour: tour,
    beneficiaryIds: {for (final s in sharesOf(tour)) s.memberId},
    members: accounts(),
  );

  List<MemberData> memberData(Day today) {
    final paid = <String, int>{};
    final paidToday = <String, int>{};
    for (final p in payments) {
      if (p.cancelled) continue;
      paid[p.memberId] = (paid[p.memberId] ?? 0) + p.amount;
      if (p.paidOn == today && p.method != PaymentMethod.withheld) {
        paidToday[p.memberId] = (paidToday[p.memberId] ?? 0) + p.amount;
      }
    }
    return [
      for (final m in members)
        MemberData(
          id: m.id,
          name: m.name,
          phone: m.phone,
          position: m.position,
          halves: halvesOf(m.id),
          paid: paid[m.id] ?? 0,
          paidToday: paidToday[m.id] ?? 0,
        ),
    ];
  }

  TodayView today(Day day) => todayView(
    terms,
    today: day,
    members: memberData(day),
    slots: [
      for (final s in slots)
        SlotInfo(
          id: s.id,
          tour: s.tour,
          memberId: s.memberId,
          halves: s.halves,
        ),
    ],
    paidOutSlotIds: paidOutSlotIds,
  );
}

TontineTerms termsOf(TontineRow row, List<SkippedDayRow> skippedDays) =>
    TontineTerms(
      places: row.places,
      contributionPerPlace: row.contributionPerPlace,
      tourDays: row.tourDays,
      firstDay: Day.parse(row.firstDay),
      skippedDays: [for (final d in skippedDays) Day.parse(d.day)],
    );

final tontineRepositoryProvider = Provider<TontineRepository>((ref) {
  return TontineRepository(ref.watch(appDatabaseProvider));
});

/// Today's calendar day, from the replaceable clock.
final todayProvider = Provider<Day>((ref) {
  return Day.fromDateTime(ref.watch(clockProvider)());
});

final tontineCardsProvider = FutureProvider<List<TontineCard>>((ref) {
  return ref.watch(tontineRepositoryProvider).cards(ref.watch(todayProvider));
});

final tontineDetailProvider = FutureProvider.family<TontineDetail, String>((
  ref,
  tontineId,
) {
  return ref.watch(tontineRepositoryProvider).detail(tontineId);
});
