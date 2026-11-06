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
    final terms = termsOf(tontine);
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
    final slots =
        await (_db.select(_db.slots)
              ..where((s) => s.tontineId.equals(tontineId))
              ..orderBy([(s) => OrderingTerm.asc(s.tour)]))
            .get();
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
    return TontineDetail(
      id: tontine.id,
      name: tontine.name,
      terms: termsOf(tontine),
      members: members,
      slots: slots,
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
    );
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
    required this.payments,
    required this.paidOutSlotIds,
  });

  final String id;
  final String name;
  final TontineTerms terms;

  /// In entry order.
  final List<MemberRow> members;

  /// In tour order.
  final List<SlotRow> slots;

  /// Newest first, cancelled ones included.
  final List<PaymentEntry> payments;
  final Set<String> paidOutSlotIds;

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

TontineTerms termsOf(TontineRow row) => TontineTerms(
  places: row.places,
  contributionPerPlace: row.contributionPerPlace,
  tourDays: row.tourDays,
  firstDay: Day.parse(row.firstDay),
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
