import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/day.dart';
import '../domain/draft.dart';
import '../domain/overview.dart';
import '../domain/payout.dart';
import '../domain/tontine_terms.dart';
import 'app_database.dart';
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
