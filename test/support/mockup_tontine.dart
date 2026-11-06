import 'package:drift/drift.dart' show Value;
import 'package:matontine/data/app_database.dart';
import 'package:matontine/data/tables.dart';
import 'package:matontine/data/tontine_repository.dart';
import 'package:matontine/domain/draft.dart';

import '../domain/maquette_example.dart';

/// The mockup's 20 people, in an entry order that makes the default tours
/// match the mockup once Mariam's second place is moved to tour 14.
const mockupPeople = <(String, int)>[
  ('Ibrahim Ouattara', 2),
  ('Seydou Koné', 2),
  ('Moussa Diallo', 2),
  ('Koffi Yao', 2),
  ('Mariam Traoré', 4),
  ('Adjoua N’Guessan', 2),
  ('Yao Kouassi', 2),
  ('Salimata Cissé', 2),
  ('Fatou Bamba', 1),
  ('Aminata Koné', 1),
  ('Bakary Sangaré', 2),
  ('Issa Touré', 2),
  ('Awa Koné', 2),
  ('Rokia Sanogo', 2),
  ('Drissa Coulibaly', 2),
  ('Mamadou Bamba', 2),
  ('Kadiatou Camara', 2),
  ('Lassina Ouédraogo', 2),
  ('Nafissatou Diarra', 2),
  ('Hawa Doumbia', 2),
];

List<DraftMember> mockupDraftMembers() => [
  for (final (i, (name, halves)) in mockupPeople.indexed)
    DraftMember(key: 'k$i', name: name, halves: halves),
];

/// The mockup's order: Mariam's second place sits at tour 14, the two half
/// places at tour 9, Awa at tour 12, Hawa at tour 20.
List<DraftTour> mockupTours() {
  // Default: Mariam takes tours 5 and 6, Fatou + Aminata tour 10.
  final tours = defaultTours(mockupDraftMembers());
  return moveTour(tours, 5, 13);
}

/// Days paid on day 37 (6 Nov 2026): the three late members of the mockup,
/// everyone else up to date today.
const _daysPaid = {'Awa Koné': 34, 'Seydou Koné': 28, 'Moussa Diallo': 33};

/// Creates the mockup's "Tontine du marché" with its payments through day 37
/// and tours 1 to 3 paid out. Returns the tontine id.
Future<String> seedMockupTontine(AppDatabase db) async {
  final id = await TontineRepository(db).create(
    name: 'Tontine du marché',
    terms: exampleTerms,
    members: mockupDraftMembers(),
    tours: mockupTours(),
  );
  final members = await db.select(db.members).get();
  final slots = await db.select(db.slots).get();
  final halves = <String, int>{};
  for (final s in slots) {
    halves[s.memberId] = (halves[s.memberId] ?? 0) + s.halves;
  }
  // The late members paid nothing today; everyone else paid through
  // yesterday, then today's contribution this morning.
  Future<void> pay(String memberId, int amount, String day) => db
      .into(db.payments)
      .insert(
        PaymentsCompanion.insert(
          tontineId: id,
          memberId: memberId,
          amount: amount,
          method: PaymentMethod.cash,
          paidOn: day,
        ),
      );
  for (final m in members) {
    final daily = exampleTerms.dailyDue(halves[m.id]!);
    final late = _daysPaid[m.name];
    if (late != null) {
      await pay(m.id, daily * late, '2026-11-04');
    } else {
      await pay(m.id, daily * 36, '2026-11-05');
      await pay(m.id, daily, '2026-11-06');
    }
  }
  for (final slot in slots.where((s) => s.tour <= 3)) {
    await db
        .into(db.payouts)
        .insert(
          PayoutsCompanion.insert(
            tontineId: id,
            slotId: slot.id,
            paidOn: exampleTerms.payoutDay(slot.tour).toIso(),
            pot: 1000000,
            collected: 1000000,
            organizerTopUp: 0,
            withheld: 0,
            handed: 1000000,
            method: PayoutMethod.cash,
            createdAt: Value(DateTime(2026, 10, 11)),
          ),
        );
  }
  return id;
}

/// What each member misses on tour 4 in the mockup's "Remise de la
/// cagnotte": Koffi 5 000 F (withheld), Seydou and Moussa 40 000 F together
/// (topped up by the organizer).
const payoutShortfalls = {
  'Koffi Yao': 5000,
  'Seydou Koné': 25000,
  'Moussa Diallo': 15000,
};

/// The mockup's tontine on the evening of day 40 (9 Nov 2026): everyone paid
/// through day 40 except [payoutShortfalls]. Tour 4 is handed out the next
/// day, Tuesday 10 November. Returns the tontine id.
Future<String> seedPayoutDay(AppDatabase db) async {
  final id = await seedMockupTontine(db);
  final repository = TontineRepository(db);
  final detail = await repository.detail(id);
  final paid = await repository.paidByMember(id);
  for (final m in detail.members) {
    final target =
        exampleTerms.dueThrough(detail.halvesOf(m.id), 40) -
        (payoutShortfalls[m.name] ?? 0);
    final missing = target - (paid[m.id] ?? 0);
    if (missing > 0) {
      await db
          .into(db.payments)
          .insert(
            PaymentsCompanion.insert(
              tontineId: id,
              memberId: m.id,
              amount: missing,
              method: PaymentMethod.cash,
              paidOn: '2026-11-09',
            ),
          );
    }
  }
  return id;
}

/// The id of the member called [name].
Future<String> memberId(AppDatabase db, String name) async => (await (db.select(
  db.members,
)..where((m) => m.name.equals(name))).getSingle()).id;
