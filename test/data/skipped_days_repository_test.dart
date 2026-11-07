import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/data/app_database.dart';
import 'package:matontine/data/tables.dart';
import 'package:matontine/data/tontine_repository.dart';
import 'package:matontine/domain/day.dart';

import '../support/mockup_tontine.dart';

void main() {
  late AppDatabase db;
  late TontineRepository repository;
  late String tontineId;
  final today = Day(2026, 11, 6);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = TontineRepository(db);
    tontineId = await seedMockupTontine(db);
  });
  tearDown(() => db.close());

  Future<void> skip(List<Day> days, {Day? on, String? reason}) =>
      repository.skipDays(
        tontineId: tontineId,
        days: days,
        reason: reason,
        today: on ?? today,
      );

  test('skipping the 8th and the 11th moves the calendar', () async {
    await skip([Day(2026, 11, 8), Day(2026, 11, 11)], reason: ' Fête ');

    final detail = await repository.detail(tontineId);
    expect(detail.skippedDays.map((d) => d.day), ['2026-11-08', '2026-11-11']);
    expect(detail.skippedDays.first.reason, 'Fête');
    expect(detail.terms.payoutDay(4), Day(2026, 11, 10));
    expect(detail.terms.payoutDay(5), Day(2026, 11, 21));
    expect(detail.today(today).payoutDay, Day(2026, 11, 10));
    // "Mes tontines" reads the same calendar.
    final card = (await repository.cards(today)).single;
    expect(card.overview.payoutDay, Day(2026, 11, 10));
  });

  test('skipping today: nobody owes today', () async {
    await skip([today]);
    final view = (await repository.detail(tontineId)).today(today);
    expect(view.todaySkipped, isTrue);
    expect(view.dayNumber, 36);
    expect(view.expectedToday, 0);
    // Awa, Seydou and Moussa stay late; nobody is "à encaisser" only.
    expect(view.lateCount, 3);
    expect(view.toCollectCount, 3);
  });

  test('a past day, a skipped day or a day after the end is refused', () async {
    expect(() => skip([Day(2026, 11, 5)]), throwsStateError);
    await skip([Day(2026, 11, 8)]);
    expect(() => skip([Day(2026, 11, 8)]), throwsStateError);
    // The end is now 19 April 2027; the 20th is beyond it.
    expect(() => skip([Day(2027, 4, 21)]), throwsStateError);
    expect(() => skip([]), throwsArgumentError);
    expect(await db.select(db.skippedDays).get(), hasLength(1));
  });

  test('the day a pot was handed out cannot be skipped', () async {
    // On 9 November, tour 4 is handed out, then the day cannot be skipped.
    final payoutDay = Day(2026, 11, 9);
    final detail = await repository.detail(tontineId);
    await repository.recordPayout(
      tontineId: tontineId,
      slotId: detail.sharesOf(4).single.id,
      method: PayoutMethod.cash,
      day: payoutDay,
    );
    expect(() => skip([payoutDay], on: payoutDay), throwsStateError);
    await skip([Day(2026, 11, 10)], on: payoutDay);
  });

  test('a skip is cancelled while its day has not passed', () async {
    await skip([Day(2026, 11, 8), Day(2026, 11, 11)]);
    final rows = (await repository.detail(tontineId)).skippedDays;

    await repository.unskipDay(rows.first.id, today: today);
    final detail = await repository.detail(tontineId);
    expect(detail.skippedDays.map((d) => d.day), ['2026-11-11']);
    expect(detail.terms.payoutDay(4), Day(2026, 11, 9));

    // On the 12th, the 11th has passed: it stays.
    expect(
      () => repository.unskipDay(rows.last.id, today: Day(2026, 11, 12)),
      throwsStateError,
    );
  });
}
