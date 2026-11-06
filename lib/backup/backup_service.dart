// Ported from IP Caisse (lib/sauvegarde/sauvegarde_service.dart), translated
// to English. Same file format and same restore steps; Ma Tontine has no
// photos, and the checks on a restored database match its own tables.

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../auth/session.dart';
import '../data/app_database.dart';
import '../home/last_tontine.dart';

const backupPasswordMinLength = 8;
const _reminderDelay = Duration(days: 7);

/// The file the database opens: see [databaseFileName].
const _databaseName = databaseFileName;
const _oldSuffix = '.before';
const _stagingDirectory = 'restore_tmp';
const _scheduledName = 'restore_scheduled';

/// Written as soon as the new data is in place: on the next start, only the
/// clean-up is left.
const _swapDoneName = 'restore_done';

/// SQLite side files: the journal (`-journal` by default, `-wal` and `-shm`
/// in WAL mode). A journal left after a power cut belongs to its database:
/// it follows it, otherwise SQLite would replay it on the other one.
const _databaseSideFiles = ['-journal', '-wal', '-shm'];
const _lastBackupName = 'last_backup.txt';
const _pendingFileName = 'pending_backup.matontine';
const _databaseEntry = 'database.sqlite';
const _manifestEntry = 'manifest.json';

// File header: signature, version, iterations, salt, nonce, then MAC.
final _signature = ascii.encode('MATONTIN');
const _formatVersion = 1;
const _saltLength = 16;
const _nonceLength = 12;
const _macLength = 16;

/// Beyond this, a damaged or crafted file would block the restore for hours.
/// The app writes 200 000.
const _maxIterations = 2000000;

/// An error whose message is shown as is to the user (in French).
class BackupException implements Exception {
  BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A date in the future comes from a wrong clock at backup time: it cannot
/// be trusted, the reminder shows.
bool backupOverdue(DateTime? last, DateTime now) =>
    last == null || last.isAfter(now) || now.difference(last) >= _reminderDelay;

/// What the start found before opening the database.
enum StartupResult {
  /// Nothing to report, or restore applied.
  normal,

  /// A restore failed or was interrupted: the previous data is in place, to
  /// tell the user.
  restoreFailed,

  /// The state before a restore could not be put back. Opening the database
  /// would create an empty one over it: the app must not start, and the next
  /// launch tries again.
  blocked,
}

/// To call at startup, before opening the database: applies a scheduled
/// restore, or puts back the previous state if a restore was interrupted,
/// for example by a power cut. No connection is open on the swapped files.
///
/// Never throws: an error here would keep the app from opening at every
/// launch.
Future<StartupResult> prepareStartup(Directory root) async {
  final scheduled = File(p.join(root.path, _scheduledName));
  final staging = Directory(p.join(root.path, _stagingDirectory));
  final bool interrupted;
  try {
    interrupted = await _undoInterruptedSwap(root);
  } on Object {
    return StartupResult.blocked;
  }
  var result = interrupted ? StartupResult.restoreFailed : StartupResult.normal;
  try {
    if (!interrupted &&
        await scheduled.exists() &&
        await File(p.join(staging.path, _databaseName)).exists()) {
      await applyRestore(root, staging);
    }
  } on Object {
    // The failure puts back the previous state. If it could not, the old
    // database still waits beside: do not start on an incomplete one.
    if (await _swapInProgress(root)) return StartupResult.blocked;
    result = StartupResult.restoreFailed;
  }
  // A restore is tried once: the schedule goes first, even after a failure,
  // and even if the staged files cannot be deleted (unlike IP Caisse, where
  // a failed clean-up left the schedule and retried the restore). A failed
  // clean-up is done again on the next launch.
  try {
    if (await scheduled.exists()) await scheduled.delete();
  } on Object {
    // Without the staged database, a leftover schedule does nothing.
  }
  try {
    if (await staging.exists()) await staging.delete(recursive: true);
  } on Object {
    // No consequence for the data.
  }
  return result;
}

/// True if an old database is still waiting: a swap did not finish.
Future<bool> _swapInProgress(Directory root) async {
  try {
    return await File(p.join(root.path, '$_databaseName$_oldSuffix')).exists();
  } on Object {
    return true;
  }
}

/// The old database is deleted last: if it still exists, the swap did not
/// finish. Returns `true` if the previous state was put back.
Future<bool> _undoInterruptedSwap(Directory root) async {
  // Power cut during the clean-up: the restore succeeded, keep it. A
  // clean-up that fails again is redone on the next launch: the new data is
  // already in place.
  if (await File(p.join(root.path, _swapDoneName)).exists()) {
    try {
      await _finishSwap(root);
    } on Object {
      // No consequence for the data.
    }
    return false;
  }
  final oldDatabase = File(p.join(root.path, '$_databaseName$_oldSuffix'));
  if (!await oldDatabase.exists()) return false;
  await _deleteDatabase(root);
  if (await oldDatabase.length() > 0) {
    await oldDatabase.rename(p.join(root.path, _databaseName));
    for (final side in _databaseSideFiles) {
      final old = File(p.join(root.path, '$_databaseName$side$_oldSuffix'));
      if (await old.exists()) {
        await old.rename(p.join(root.path, '$_databaseName$side'));
      }
    }
  } else {
    await oldDatabase.delete();
  }
  return true;
}

Future<void> _deleteDatabase(Directory root) async {
  for (final suffix in ['', ..._databaseSideFiles]) {
    final file = File(p.join(root.path, '$_databaseName$suffix'));
    if (await file.exists()) await file.delete();
  }
}

class BackupService {
  BackupService(
    this._db,
    this._root, {
    this.iterations = 200000,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final Directory _root;
  final int iterations;
  final DateTime Function() _now;

  File get lastBackupFile => File(p.join(_root.path, _lastBackupName));

  Future<DateTime?> lastBackup() async {
    if (!await lastBackupFile.exists()) return null;
    return DateTime.tryParse(await lastBackupFile.readAsString());
  }

  /// Writes the backup to disk, ready to be copied by the native code.
  Future<File> createFile(String password) async {
    final file = File(p.join(_root.path, _pendingFileName));
    await file.writeAsBytes(await create(password), flush: true);
    return file;
  }

  /// Creates the encrypted file holding the database.
  Future<Uint8List> create(String password) async {
    if (password.length < backupPasswordMinLength) {
      throw BackupException('Mot de passe de sauvegarde trop court.');
    }
    // VACUUM INTO gives a consistent copy, even while the database is in use.
    final copy = File(p.join(_root.path, 'backup_tmp.sqlite'));
    if (await copy.exists()) await copy.delete();
    try {
      await _db.customStatement('VACUUM INTO ?', [copy.path]);

      final archive = Archive()
        ..add(
          ArchiveFile.string(
            _manifestEntry,
            jsonEncode({
              'schemaVersion': _db.schemaVersion,
              'createdAt': _now().toIso8601String(),
            }),
          ),
        )
        ..add(ArchiveFile.bytes(_databaseEntry, await copy.readAsBytes()));
      final content = TarEncoder().encodeBytes(archive);
      return await _encryptInBackground(content, password, iterations);
    } finally {
      if (await copy.exists()) await copy.delete();
    }
  }

  /// Decrypts and checks the backup in a staging directory, without touching
  /// the data in place. Returns that directory, ready for [schedule].
  Future<Directory> prepare(Uint8List file, String password) async {
    final content = await _decryptInBackground(file, password);
    final archive = _readArchive(content);

    final manifest = archive.find(_manifestEntry);
    final database = archive.find(_databaseEntry);
    if (manifest == null || database == null) {
      throw BackupException('Ce fichier n’est pas une sauvegarde Ma Tontine.');
    }
    if (archive.files.any(
      (e) => e.name != _manifestEntry && e.name != _databaseEntry,
    )) {
      throw BackupException('Cette sauvegarde est invalide.');
    }
    final Object? version;
    try {
      version =
          (jsonDecode(utf8.decode(manifest.content)) as Map)['schemaVersion'];
    } on Object {
      // Decrypted with the right password but malformed.
      throw BackupException('Cette sauvegarde est invalide.');
    }
    if (version is! int || version > _db.schemaVersion) {
      throw BackupException(
        'Cette sauvegarde vient d’une version plus récente. Mettez d’abord '
        'l’application à jour.',
      );
    }

    final directory = Directory(p.join(_root.path, _stagingDirectory));
    if (await directory.exists()) await directory.delete(recursive: true);
    await directory.create(recursive: true);
    try {
      final stagedDatabase = File(p.join(directory.path, _databaseName));
      await stagedDatabase.writeAsBytes(database.content, flush: true);
      await _checkDatabase(stagedDatabase);
      return directory;
    } on Object {
      await directory.delete(recursive: true);
      rethrow;
    }
  }

  /// Asks for the prepared backup to be applied at the next start.
  Future<void> schedule(Directory directory) =>
      File(p.join(_root.path, _scheduledName))
          .writeAsString(directory.path, flush: true);

  /// Gives up a scheduled restore, for example when the restart fails:
  /// otherwise it would apply at the next launch and erase the payments
  /// recorded in between.
  Future<void> cancelSchedule() async {
    final scheduled = File(p.join(_root.path, _scheduledName));
    if (await scheduled.exists()) await scheduled.delete();
    final directory = Directory(p.join(_root.path, _stagingDirectory));
    if (await directory.exists()) await directory.delete(recursive: true);
  }

  Future<void> _checkDatabase(File database) async {
    final check = AppDatabase(NativeDatabase(database));
    try {
      final integrity = await check
          .customSelect('PRAGMA integrity_check', variables: <Variable>[])
          .getSingle();
      if (integrity.data.values.first != 'ok') {
        throw BackupException('Cette sauvegarde est endommagée.');
      }
      if ((await check.select(check.accounts).get()).length != 1) {
        throw BackupException('Cette sauvegarde est invalide.');
      }
      // Impossible values would crash the screens (a tour without exactly
      // one place, a contribution that does not halve): the database refuses
      // them, a backup edited by hand too.
      final inconsistencies = await check
          .customSelect(
            'SELECT '
            '(SELECT COUNT(*) FROM tontine WHERE places < 1 OR tour_days < 1 '
            'OR contribution_per_place <= 0 '
            'OR contribution_per_place % 10 != 0) + '
            '(SELECT COUNT(*) FROM (SELECT s.tontine_id, s.tour '
            'FROM slot s GROUP BY s.tontine_id, s.tour '
            'HAVING SUM(s.halves) != 2)) + '
            '(SELECT COUNT(*) FROM tontine t WHERE (SELECT COUNT(DISTINCT '
            's.tour) FROM slot s WHERE s.tontine_id = t.id '
            'AND s.tour BETWEEN 1 AND t.places) != t.places) + '
            '(SELECT COUNT(*) FROM slot s JOIN tontine t '
            'ON t.id = s.tontine_id WHERE s.tour > t.places) + '
            '(SELECT COUNT(*) FROM payment WHERE amount <= 0) AS n',
            variables: <Variable>[],
          )
          .getSingle();
      if (inconsistencies.read<int>('n') > 0) {
        throw BackupException('Cette sauvegarde est endommagée.');
      }
    } on BackupException {
      rethrow;
    } on Exception {
      throw BackupException('Cette sauvegarde est endommagée.');
    } finally {
      await check.close();
    }
  }
}

/// Swaps the data in place with the one in [directory]. No connection may be
/// open on the database. On failure, the original state is put back.
Future<void> applyRestore(Directory root, Directory directory) async {
  final database = File(p.join(root.path, _databaseName));
  final oldDatabase = File('${database.path}$_oldSuffix');
  try {
    if (await database.exists()) {
      await database.rename(oldDatabase.path);
    } else {
      // Empty file: marks a swap in progress on a new phone.
      await oldDatabase.writeAsBytes(const [], flush: true);
    }
    // The journal may hold the last writes: it follows the old database.
    for (final side in _databaseSideFiles) {
      final file = File('${database.path}$side');
      if (await file.exists()) await file.rename('${file.path}$_oldSuffix');
    }
    await File(p.join(directory.path, _databaseName)).rename(database.path);
  } on Object {
    // If putting things back fails too, the error goes up: the old database,
    // still beside, is put back on the next launch.
    await _undoInterruptedSwap(root);
    throw BackupException('La restauration a échoué. Rien n’a été modifié.');
  }
  await File(p.join(root.path, _swapDoneName))
      .writeAsBytes(const [], flush: true);
  // The new data is in place: a failed clean-up does not fail the restore.
  // It is done again on the next launch.
  try {
    if (await directory.exists()) await directory.delete(recursive: true);
    await _finishSwap(root);
  } on Object {
    // No consequence for the data.
  }
}

/// Deletes the old database once the new one is in place. The done marker
/// goes last.
Future<void> _finishSwap(Directory root) async {
  final database = File(p.join(root.path, _databaseName));
  for (final suffix in ['', ..._databaseSideFiles]) {
    final old = File('${database.path}$suffix$_oldSuffix');
    if (await old.exists()) await old.delete();
  }
  // The restored account has its own password: it is asked again. The last
  // tontine opened may not exist in the restored data.
  for (final name in [sessionFileName, lastTontineFileName]) {
    final file = File(p.join(root.path, name));
    if (await file.exists()) await file.delete();
  }
  await File(p.join(root.path, _swapDoneName)).delete();
}

Archive _readArchive(Uint8List content) {
  try {
    return TarDecoder().decodeBytes(content);
  } on Object {
    // A damaged archive may throw a read error (RangeError…).
    throw BackupException('Ce fichier n’est pas une sauvegarde Ma Tontine.');
  }
}

Future<Uint8List> _encryptInBackground(
  Uint8List content,
  String password,
  int iterations,
) {
  return Isolate.run(() async {
    final random = Random.secure();
    List<int> bytes(int length) =>
        List.generate(length, (_) => random.nextInt(256));
    final salt = bytes(_saltLength);
    final nonce = bytes(_nonceLength);
    final key = await _deriveKey(password, salt, iterations);
    final box = await AesGcm.with256bits().encrypt(
      content,
      secretKey: key,
      nonce: nonce,
    );
    final iterationBytes = ByteData(4)..setUint32(0, iterations);
    return (BytesBuilder(copy: false)
          ..add(_signature)
          ..addByte(_formatVersion)
          ..add(iterationBytes.buffer.asUint8List())
          ..add(salt)
          ..add(nonce)
          ..add(box.mac.bytes)
          ..add(box.cipherText))
        .takeBytes();
  });
}

Future<Uint8List> _decryptInBackground(Uint8List file, String password) async {
  final saltStart = _signature.length + 1 + 4;
  final cipherStart = saltStart + _saltLength + _nonceLength + _macLength;
  final validSignature =
      file.length >= cipherStart &&
      file[_signature.length] == _formatVersion &&
      List.generate(
        _signature.length,
        (i) => file[i] == _signature[i],
      ).every((same) => same);
  if (!validSignature) {
    throw BackupException('Ce fichier n’est pas une sauvegarde Ma Tontine.');
  }
  final iterations = ByteData.sublistView(file)
      .getUint32(_signature.length + 1);
  if (iterations < 1 || iterations > _maxIterations) {
    throw BackupException('Ce fichier de sauvegarde est endommagé.');
  }
  try {
    return await Isolate.run(() async {
      final nonceStart = saltStart + _saltLength;
      final macStart = nonceStart + _nonceLength;
      final key = await _deriveKey(
        password,
        file.sublist(saltStart, nonceStart),
        iterations,
      );
      final clear = await AesGcm.with256bits().decrypt(
        SecretBox(
          Uint8List.sublistView(file, cipherStart),
          nonce: file.sublist(nonceStart, macStart),
          mac: Mac(file.sublist(macStart, cipherStart)),
        ),
        secretKey: key,
      );
      // Already a Uint8List in practice: no second copy of all the data.
      return clear is Uint8List ? clear : Uint8List.fromList(clear);
    });
  } on SecretBoxAuthenticationError {
    throw BackupException('Mot de passe incorrect ou fichier endommagé.');
  }
}

Future<SecretKey> _deriveKey(String password, List<int> salt, int iterations) {
  return Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: iterations,
    bits: 256,
  ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
}
