// Ported from IP Caisse (lib/auth/session.dart), translated to English. The
// single account has no role here.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../data/providers.dart';
import 'auth_service.dart';

/// Inactivity after which the password is asked again: a day of rounds
/// needs no new login, the night locks the app.
const sessionDuration = Duration(hours: 8);

/// Session file name, deleted by a backup restore.
const sessionFileName = 'session.json';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(appDatabaseProvider));
});

final accountExistsProvider = FutureProvider<bool>((ref) {
  return ref.watch(authServiceProvider).accountExists();
});

/// Remembers the last activity, to keep the session across a restart. The
/// tiny file is read and written synchronously.
class SessionStore {
  SessionStore(Directory root)
    : _file = File(p.join(root.path, sessionFileName));

  final File _file;

  DateTime? lastActivity() {
    try {
      if (!_file.existsSync()) return null;
      return DateTime.parse(_file.readAsStringSync().trim());
    } on Object {
      return null;
    }
  }

  void record(DateTime moment) {
    File('${_file.path}.tmp')
      ..writeAsStringSync(moment.toIso8601String(), flush: true)
      ..renameSync(_file.path);
  }

  void clear() {
    if (_file.existsSync()) _file.deleteSync();
  }
}

final sessionStoreProvider = Provider<SessionStore>((ref) {
  return SessionStore(ref.watch(documentsDirectoryProvider));
});

/// `true` while the user is logged in.
final sessionProvider = NotifierProvider<Session, bool>(Session.new);

/// At launch, resumes a session used less than [sessionDuration] ago.
final sessionRestoreProvider = FutureProvider<void>((ref) {
  return ref.read(sessionProvider.notifier).restore(DateTime.now());
});

class Session extends Notifier<bool> {
  DateTime? _backgroundSince;

  @override
  bool build() => false;

  SessionStore get _store => ref.read(sessionStoreProvider);

  void login() {
    state = true;
    _store.record(DateTime.now());
  }

  void logout() {
    state = false;
    _store.clear();
  }

  /// A clock moved back does not extend the session.
  Future<void> restore(DateTime now) async {
    final last = _store.lastActivity();
    if (last == null) return;
    final gap = now.difference(last);
    if (gap.isNegative ||
        gap >= sessionDuration ||
        !await ref.read(authServiceProvider).accountExists()) {
      _store.clear();
      return;
    }
    login();
  }

  void goToBackground(DateTime now) {
    _backgroundSince = now;
    if (state) _store.record(now);
  }

  void resume(DateTime now) {
    final since = _backgroundSince;
    _backgroundSince = null;
    // A clock moved back while in the background does not extend the
    // session: a negative gap locks, as at restart.
    final gap = since == null ? null : now.difference(since);
    if (gap != null && (gap.isNegative || gap >= sessionDuration)) {
      logout();
    } else if (state) {
      _store.record(now);
    }
  }
}
