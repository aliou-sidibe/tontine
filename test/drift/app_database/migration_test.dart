// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:matontine/data/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // Version 2 adds the skipped_day table: the tontines of version 1 stay.
  test('migration from v1 to v2 does not corrupt data', () async {
    final oldAccountData = <v1.AccountData>[];
    final expectedNewAccountData = <v2.AccountData>[];

    final oldTontineData = <v1.TontineData>[
      const v1.TontineData(
        id: 't1',
        name: 'Tontine du marché',
        places: 20,
        contributionPerPlace: 5000,
        tourDays: 10,
        firstDay: '2026-10-01',
        createdAt: 1793000000,
      ),
    ];
    final expectedNewTontineData = <v2.TontineData>[
      const v2.TontineData(
        id: 't1',
        name: 'Tontine du marché',
        places: 20,
        contributionPerPlace: 5000,
        tourDays: 10,
        firstDay: '2026-10-01',
        createdAt: 1793000000,
      ),
    ];

    final oldMemberData = <v1.MemberData>[];
    final expectedNewMemberData = <v2.MemberData>[];

    final oldSlotData = <v1.SlotData>[];
    final expectedNewSlotData = <v2.SlotData>[];

    final oldPaymentData = <v1.PaymentData>[];
    final expectedNewPaymentData = <v2.PaymentData>[];

    final oldPaymentCancellationData = <v1.PaymentCancellationData>[];
    final expectedNewPaymentCancellationData = <v2.PaymentCancellationData>[];

    final oldPayoutData = <v1.PayoutData>[];
    final expectedNewPayoutData = <v2.PayoutData>[];

    final oldPayoutCancellationData = <v1.PayoutCancellationData>[];
    final expectedNewPayoutCancellationData = <v2.PayoutCancellationData>[];

    final oldTourSwapData = <v1.TourSwapData>[];
    final expectedNewTourSwapData = <v2.TourSwapData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.account, oldAccountData);
        batch.insertAll(oldDb.tontine, oldTontineData);
        batch.insertAll(oldDb.member, oldMemberData);
        batch.insertAll(oldDb.slot, oldSlotData);
        batch.insertAll(oldDb.payment, oldPaymentData);
        batch.insertAll(oldDb.paymentCancellation, oldPaymentCancellationData);
        batch.insertAll(oldDb.payout, oldPayoutData);
        batch.insertAll(oldDb.payoutCancellation, oldPayoutCancellationData);
        batch.insertAll(oldDb.tourSwap, oldTourSwapData);
      },
      validateItems: (newDb) async {
        expect(expectedNewAccountData, await newDb.select(newDb.account).get());
        expect(expectedNewTontineData, await newDb.select(newDb.tontine).get());
        expect(expectedNewMemberData, await newDb.select(newDb.member).get());
        expect(expectedNewSlotData, await newDb.select(newDb.slot).get());
        expect(expectedNewPaymentData, await newDb.select(newDb.payment).get());
        expect(
          expectedNewPaymentCancellationData,
          await newDb.select(newDb.paymentCancellation).get(),
        );
        expect(expectedNewPayoutData, await newDb.select(newDb.payout).get());
        expect(
          expectedNewPayoutCancellationData,
          await newDb.select(newDb.payoutCancellation).get(),
        );
        expect(
          expectedNewTourSwapData,
          await newDb.select(newDb.tourSwap).get(),
        );
      },
    );
  });
  // Version 3 drops the unique day of skipped_day (a cancelled skip stays)
  // and adds skipped_day_cancellation: the skipped days of version 2 stay.
  test('migration from v2 to v3 keeps skipped days', () async {
    const tontine = (
      id: 't1',
      name: 'Tontine du marché',
      places: 20,
      contributionPerPlace: 5000,
      tourDays: 10,
      firstDay: '2026-10-01',
      createdAt: 1793000000,
    );
    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(
          oldDb.tontine,
          v2.TontineData(
            id: tontine.id,
            name: tontine.name,
            places: tontine.places,
            contributionPerPlace: tontine.contributionPerPlace,
            tourDays: tontine.tourDays,
            firstDay: tontine.firstDay,
            createdAt: tontine.createdAt,
          ),
        );
        batch.insert(
          oldDb.skippedDay,
          const v2.SkippedDayData(
            id: 's1',
            tontineId: 't1',
            day: '2026-11-08',
            reason: 'Fête',
            createdAt: 1793000000,
          ),
        );
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.skippedDay).get(), const [
          v3.SkippedDayData(
            id: 's1',
            tontineId: 't1',
            day: '2026-11-08',
            reason: 'Fête',
            createdAt: 1793000000,
          ),
        ]);
        expect(await newDb.select(newDb.skippedDayCancellation).get(), isEmpty);
        expect(await newDb.select(newDb.tontine).get(), hasLength(1));
      },
    );
  });
}
