import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'app_database.steps.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Database name: the file [databaseFileName] lives in the app documents
/// directory.
const databaseName = 'matontine';
const databaseFileName = '$databaseName.sqlite';

@DriftDatabase(
  tables: [
    Accounts,
    Tontines,
    Members,
    Slots,
    Payments,
    PaymentCancellations,
    Payouts,
    PayoutCancellations,
    TourSwaps,
    SkippedDays,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: databaseName,
              // A plain directory: the backup reads the database and a
              // restore replaces it at exactly this path.
              native: const DriftNativeOptions(
                databaseDirectory: getApplicationDocumentsDirectory,
              ),
            ),
      );

  /// On every schema change: bump this number, run
  /// `dart run drift_dev make-migrations`, then write the migration step.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        // Skipped days (feasts, market closed).
        await m.createTable(schema.skippedDay);
        await m.createIndex(schema.skippedDayTontine);
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
