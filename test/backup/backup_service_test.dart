// Ported from IP Caisse (test/sauvegarde/sauvegarde_service_test.dart),
// translated to English; the photo cases are gone with the photos.

import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/auth/auth_service.dart';
import 'package:matontine/backup/backup_service.dart';
import 'package:matontine/data/app_database.dart';
import 'package:matontine/data/tables.dart';
import 'package:matontine/data/tontine_repository.dart';
import 'package:matontine/domain/day.dart';
import 'package:path/path.dart' as p;

import '../support/mockup_tontine.dart';

const _password = 'sauvegarde-1';

void main() {
  late Directory root;
  late File databaseFile;
  late AppDatabase database;
  late BackupService service;
  late String tontineId;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  Future<AppDatabase> open() async => AppDatabase(NativeDatabase(databaseFile));

  BackupService serviceFor(AppDatabase db) =>
      BackupService(db, root, iterations: 1000);

  /// A payment made after the backup: it must disappear on restore.
  Future<void> payAfterBackup(AppDatabase db) async {
    final awa = await memberId(db, 'Awa Koné');
    await TontineRepository(db).addPayment(
      tontineId: tontineId,
      memberId: awa,
      amount: 5000,
      method: PaymentMethod.cash,
      paidOn: Day(2026, 11, 6),
    );
  }

  Future<int> paymentCount(AppDatabase db) async =>
      (await db.select(db.payments).get()).length;

  Future<List<String>> tontineNames(AppDatabase db) async =>
      (await db.select(db.tontines).get()).map((t) => t.name).toList();

  late int seededPayments;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('matontine_backup');
    databaseFile = File(p.join(root.path, databaseFileName));
    database = await open();
    service = serviceFor(database);
    await AuthService(
      database,
      iterations: 1000,
    ).createAccount('ibrahim', 'secret1');
    tontineId = await seedMockupTontine(database);
    seededPayments = await paymentCount(database);
  });
  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  /// Does the swap as the app does: database closed, then reopened.
  Future<void> restore(Directory directory) async {
    await database.close();
    await applyRestore(root, directory);
    database = await open();
    service = serviceFor(database);
  }

  group('round trip', () {
    test('restores the original database and account', () async {
      final backup = await service.create(_password);
      await payAfterBackup(database);

      await restore(await service.prepare(backup, _password));

      expect(await paymentCount(database), seededPayments);
      expect(await tontineNames(database), ['Tontine du marché']);
      expect(
        await AuthService(
          database,
          iterations: 1000,
        ).login('ibrahim', 'secret1'),
        LoginResult.success,
      );
    });

    test('restores on a new phone, without a database', () async {
      final backup = await service.create(_password);
      final prepared = await service.prepare(backup, _password);
      await database.close();
      for (final f in root.listSync().whereType<File>()) {
        f.deleteSync();
      }

      await applyRestore(root, prepared);

      database = await open();
      expect(await paymentCount(database), seededPayments);
    });

    test('leaves no temporary file, session or last tontine', () async {
      await File(p.join(root.path, 'session.json')).writeAsString('x');
      await File(p.join(root.path, 'last_tontine.txt')).writeAsString('x');
      final backup = await service.create(_password);
      await restore(await service.prepare(backup, _password));

      final names = root.listSync().map((e) => p.basename(e.path));
      expect(
        names.where((n) => n.contains('tmp') || n.contains('before')),
        isEmpty,
      );
      expect(names, isNot(contains('session.json')));
      expect(names, isNot(contains('last_tontine.txt')));
    });
  });

  group('protection', () {
    test('the content is not readable in the file', () async {
      final backup = await service.create(_password);
      expect(
        String.fromCharCodes(backup).contains('Tontine du march'),
        isFalse,
      );
      expect(String.fromCharCodes(backup).contains('Awa'), isFalse);
    });

    test('refuses a backup password that is too short', () async {
      await expectLater(
        service.create('court'),
        throwsA(isA<BackupException>()),
      );
    });

    test('refuses a wrong password without changing anything', () async {
      final backup = await service.create(_password);
      await expectLater(
        service.prepare(backup, 'mauvais-mot'),
        throwsA(isA<BackupException>()),
      );
      expect(await paymentCount(database), seededPayments);
    });

    test('detects a modified file', () async {
      final backup = await service.create(_password);
      backup[backup.length - 10] ^= 0xFF;
      await expectLater(
        service.prepare(backup, _password),
        throwsA(isA<BackupException>()),
      );
    });

    test('refuses an excessive iteration count', () async {
      final backup = await service.create(_password);
      // Right after the signature and the version.
      backup.setRange(9, 13, [0xFF, 0xFF, 0xFF, 0xFF]);
      await expectLater(
        service.prepare(backup, _password),
        throwsA(
          isA<BackupException>().having(
            (e) => e.message,
            'message',
            contains('endommagé'),
          ),
        ),
      );
    });

    test('refuses a file that is not a backup', () async {
      await expectLater(
        service.prepare(Uint8List.fromList([1, 2, 3]), _password),
        throwsA(isA<BackupException>()),
      );
    });

    test('refuses a backup with impossible values', () async {
      // A tour with two full places: the payout screen could not compute it.
      await database.customStatement(
        "UPDATE slot SET tour = 5 WHERE tour = 6 AND tontine_id = '$tontineId'",
      );
      final backup = await service.create(_password);
      await expectLater(
        service.prepare(backup, _password),
        throwsA(
          isA<BackupException>().having(
            (e) => e.message,
            'message',
            contains('endommagée'),
          ),
        ),
      );
    });
  });

  group('startup', () {
    test('applies the scheduled restore', () async {
      final backup = await service.create(_password);
      await payAfterBackup(database);
      final directory = await service.prepare(backup, _password);
      await service.schedule(directory);
      await database.close();

      expect(await prepareStartup(root), StartupResult.normal);

      database = await open();
      expect(await paymentCount(database), seededPayments);
      final names = root.listSync().map((e) => p.basename(e.path));
      expect(
        names.where(
          (n) =>
              n.contains('tmp') ||
              n.contains('before') ||
              n.contains('scheduled'),
        ),
        isEmpty,
      );
    });

    test('ignores a backup prepared but not scheduled', () async {
      final backup = await service.create(_password);
      await payAfterBackup(database);
      await service.prepare(backup, _password);
      await database.close();

      await prepareStartup(root);

      database = await open();
      expect(await paymentCount(database), seededPayments + 1);
      expect(
        await Directory(p.join(root.path, 'restore_tmp')).exists(),
        isFalse,
      );
    });

    test('puts back the original data after a power cut mid-swap', () async {
      final backup = await service.create(_password);
      final directory = await service.prepare(backup, _password);
      await service.schedule(directory);
      await payAfterBackup(database);
      await database.close();
      // State left by a power cut: the old database is already aside.
      await databaseFile.rename('${databaseFile.path}.before');
      await databaseFile.writeAsBytes([0, 0, 0]);

      expect(await prepareStartup(root), StartupResult.restoreFailed);

      database = await open();
      expect(await paymentCount(database), seededPayments + 1);
      expect(
        await Directory(p.join(root.path, 'restore_tmp')).exists(),
        isFalse,
      );
    });

    test('keeps the restore if the power cut comes during clean-up', () async {
      final backup = await service.create(_password);
      await payAfterBackup(database);
      final directory = await service.prepare(backup, _password);
      await service.schedule(directory);
      await database.close();
      // Power cut right after the swap: the new data is in place, the old
      // database is not deleted yet.
      await databaseFile.rename('${databaseFile.path}.before');
      await File(p.join(directory.path, databaseFileName))
          .rename(databaseFile.path);
      await File(p.join(root.path, 'restore_done')).writeAsBytes([]);

      await prepareStartup(root);

      database = await open();
      expect(await paymentCount(database), seededPayments);
      final names = root.listSync().map((e) => p.basename(e.path));
      expect(
        names.where(
          (n) =>
              n.contains('tmp') ||
              n.contains('before') ||
              n.contains('scheduled') ||
              n.contains('done'),
        ),
        isEmpty,
      );
    });

    test('a power cut on a new phone starts from scratch', () async {
      final backup = await service.create(_password);
      await service.prepare(backup, _password);
      await database.close();
      await databaseFile.delete();
      await File('${databaseFile.path}.before').writeAsBytes(const []);
      await databaseFile.writeAsBytes([0, 0, 0]);

      await prepareStartup(root);

      expect(await databaseFile.exists(), isFalse);
      expect(await File('${databaseFile.path}.before').exists(), isFalse);
      database = await open();
      expect(await tontineNames(database), isEmpty);
    });

    test('a journal left after a power cut follows the old database', () async {
      final backup = await service.create(_password);
      final directory = await service.prepare(backup, _password);
      await service.schedule(directory);
      await database.close();
      // Journal left by an interrupted write on the old database.
      final journal = File('${databaseFile.path}-journal');
      await journal.writeAsBytes([9, 9, 9]);

      expect(await prepareStartup(root), StartupResult.normal);

      expect(await journal.exists(), isFalse);
      database = await open();
      expect(await paymentCount(database), seededPayments);
    });

    test('a failed restore keeps the data and is not retried', () async {
      final backup = await service.create(_password);
      final directory = await service.prepare(backup, _password);
      await service.schedule(directory);
      await payAfterBackup(database);
      await database.close();
      // A read-only staging directory: the swap fails midway.
      await Process.run('chmod', ['555', directory.path]);
      addTearDown(() => Process.run('chmod', ['755', directory.path]));

      expect(await prepareStartup(root), StartupResult.restoreFailed);

      await Process.run('chmod', ['755', directory.path]);
      database = await open();
      expect(await paymentCount(database), seededPayments + 1);
      final names = root.listSync().map((e) => p.basename(e.path));
      expect(
        names.where((n) => n.contains('before') || n.contains('scheduled')),
        isEmpty,
      );
      await database.close();
      // The next launch starts normally and finishes the clean-up.
      expect(await prepareStartup(root), StartupResult.normal);
      expect(await directory.exists(), isFalse);
      database = await open();
      expect(await paymentCount(database), seededPayments + 1);
    }, skip: Platform.isWindows ? 'chmod unavailable' : false);

    test('does not start if the previous state cannot be put back', () async {
      await database.close();
      // Power cut mid-swap, then a read-only directory: the database set
      // aside cannot go back in place.
      await databaseFile.rename('${databaseFile.path}.before');
      await databaseFile.writeAsBytes([0, 0, 0]);
      await Process.run('chmod', ['555', root.path]);
      addTearDown(() => Process.run('chmod', ['755', root.path]));

      expect(await prepareStartup(root), StartupResult.blocked);

      await Process.run('chmod', ['755', root.path]);
      expect(await File('${databaseFile.path}.before').exists(), isTrue);
      // The next launch, with the directory writable again, puts it back.
      expect(await prepareStartup(root), StartupResult.restoreFailed);
      database = await open();
      expect(await paymentCount(database), seededPayments);
    }, skip: Platform.isWindows ? 'chmod unavailable' : false);

    test('cancelling a scheduled restore removes it', () async {
      final backup = await service.create(_password);
      final directory = await service.prepare(backup, _password);
      await service.schedule(directory);
      await payAfterBackup(database);

      await service.cancelSchedule();
      await database.close();

      expect(await prepareStartup(root), StartupResult.normal);
      database = await open();
      expect(await paymentCount(database), seededPayments + 1);
      expect(await directory.exists(), isFalse);
    });

    test('does nothing without a pending restore', () async {
      await prepareStartup(root);
      expect(await paymentCount(database), seededPayments);
    });
  });

  group('reminder', () {
    final now = DateTime(2026, 11, 10);

    test('reminds without a backup and after 7 days', () {
      expect(backupOverdue(null, now), isTrue);
      expect(backupOverdue(DateTime(2026, 11, 3), now), isTrue);
      expect(backupOverdue(DateTime(2026, 11, 4), now), isFalse);
    });

    test('reminds if the backup date is in the future', () {
      // Wrong clock at backup time: it is not trusted.
      expect(backupOverdue(DateTime(2027, 11, 4), now), isTrue);
    });

    test('reads the date written by the native code after checking', () async {
      expect(await service.lastBackup(), isNull);
      await service.lastBackupFile.writeAsString('2026-11-02T14:30:00');
      expect(await service.lastBackup(), DateTime(2026, 11, 2, 14, 30));
    });

    test('writes the file to copy, the same as a backup', () async {
      final file = await service.createFile(_password);
      final directory = await service.prepare(
        await file.readAsBytes(),
        _password,
      );
      expect(await directory.exists(), isTrue);
      await directory.delete(recursive: true);
    });
  });
}
