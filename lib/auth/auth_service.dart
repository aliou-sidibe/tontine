// Ported from IP Caisse (lib/auth/auth_service.dart), translated to English.
// Keep the logic identical so fixes can be carried over between the two apps.

import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' show Value;

import '../data/app_database.dart';

const minPasswordLength = 6;
const _maxFailures = 5;
const _lockoutDuration = Duration(seconds: 30);
const _maxLockoutDuration = Duration(minutes: 16);

/// Duration of a lockout after [lockouts] previous ones: 30 s, then twice as
/// long each time, up to 16 min. Guessing a password by repeated attempts
/// quickly becomes very slow.
Duration lockoutDuration(int lockouts) {
  final duration = _lockoutDuration * (1 << min(lockouts, 5));
  return duration > _maxLockoutDuration ? _maxLockoutDuration : duration;
}

/// "30 secondes", "2 min", "1 min 30 s" (shown to the user).
String formatWait(Duration wait) {
  final seconds = (wait.inMilliseconds / 1000).ceil();
  if (seconds < 60) return '$seconds seconde${seconds > 1 ? 's' : ''}';
  final minutes = seconds ~/ 60;
  final rest = seconds % 60;
  return rest == 0 ? '$minutes min' : '$minutes min $rest s';
}

const _codeAlphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';

enum LoginResult { success, rejected, locked }

/// Local authentication: the app works without a server, so the account and
/// its hashes stay in the device database.
class AuthService {
  AuthService(
    this._db, {
    this.iterations = 120000,
    DateTime Function()? now,
    Duration Function()? stopwatch,
  }) : _now = now ?? DateTime.now,
       _stopwatch = stopwatch ?? (Stopwatch()..start()).elapsedFunction;

  final AppDatabase _db;
  final int iterations;
  final DateTime Function() _now;

  /// Time since launch, independent of the phone's clock: moving the clock
  /// forward does not shorten a lockout while the app stays open.
  final Duration Function() _stopwatch;

  /// End of the current lockout, according to [_stopwatch].
  Duration? _lockoutEnd;

  /// Attempts run one at a time: two simultaneous attempts (login and
  /// recovery code) cannot lose a failure.
  Future<void> _queue = Future.value();

  Future<T> _oneAtATime<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  Future<bool> accountExists() async => await _account() != null;

  /// Creates the only account and returns its recovery code, shown once.
  Future<String> createAccount(String username, String password) async {
    if (await accountExists()) throw StateError('The account already exists.');
    _checkPassword(password);

    final recoveryCode = _generateRecoveryCode();
    final passwordSalt = _generateSalt();
    final codeSalt = _generateSalt();
    // Both computations, slow by design, run at the same time.
    final (passwordHash, codeHash) = await (
      _derive(password, passwordSalt, iterations),
      _derive(_normalizeCode(recoveryCode), codeSalt, iterations),
    ).wait;
    await _db
        .into(_db.accounts)
        .insert(
          AccountsCompanion.insert(
            username: _normalizeUsername(username),
            passwordHash: passwordHash,
            passwordSalt: passwordSalt,
            recoveryCodeHash: codeHash,
            recoveryCodeSalt: codeSalt,
            iterations: iterations,
          ),
        );
    return recoveryCode;
  }

  Future<LoginResult> login(String username, String password) =>
      _oneAtATime(() => _login(username, password));

  Future<LoginResult> _login(String username, String password) async {
    final account = await _account();
    if (account == null) return LoginResult.rejected;
    if (_isLocked(account)) return LoginResult.locked;

    final hash = await _derive(
      password,
      account.passwordSalt,
      account.iterations,
    );
    final valid =
        account.username == _normalizeUsername(username) &&
        _constantTimeEquals(hash, account.passwordHash);
    return _recordAttempt(account, valid);
  }

  /// Replaces the password and also returns a new recovery code, since the
  /// old one may have been seen while it was typed.
  Future<(LoginResult, String?)> resetPassword(
    String username,
    String recoveryCode,
    String newPassword,
  ) {
    _checkPassword(newPassword);
    return _oneAtATime(
      () => _resetPassword(username, recoveryCode, newPassword),
    );
  }

  Future<(LoginResult, String?)> _resetPassword(
    String username,
    String recoveryCode,
    String newPassword,
  ) async {
    final account = await _account();
    if (account == null) return (LoginResult.rejected, null);
    if (_isLocked(account)) return (LoginResult.locked, null);

    final hash = await _derive(
      _normalizeCode(recoveryCode),
      account.recoveryCodeSalt,
      account.iterations,
    );
    final valid =
        account.username == _normalizeUsername(username) &&
        _constantTimeEquals(hash, account.recoveryCodeHash);
    final result = await _recordAttempt(account, valid);
    if (result != LoginResult.success) return (result, null);

    final newCode = _generateRecoveryCode();
    final passwordSalt = _generateSalt();
    final codeSalt = _generateSalt();
    final (passwordHash, codeHash) = await (
      _derive(newPassword, passwordSalt, iterations),
      _derive(_normalizeCode(newCode), codeSalt, iterations),
    ).wait;
    await (_db.update(
      _db.accounts,
    )..where((a) => a.id.equals(account.id))).write(
      AccountsCompanion(
        passwordHash: Value(passwordHash),
        passwordSalt: Value(passwordSalt),
        recoveryCodeHash: Value(codeHash),
        recoveryCodeSalt: Value(codeSalt),
        iterations: Value(iterations),
      ),
    );
    return (LoginResult.success, newCode);
  }

  Future<Account?> _account() =>
      (_db.select(_db.accounts)..limit(1)).getSingleOrNull();

  /// Time to wait before a new attempt, zero when not locked.
  Future<Duration> lockoutWait() async {
    final account = await _account();
    return account == null ? Duration.zero : _wait(account);
  }

  /// The longer of the two: the stored time, and the stopwatch of the
  /// current lockout. A stored time further away than the longest lockout
  /// comes from a clock moved back since: it does not lock.
  Duration _wait(Account account) {
    var wall = Duration.zero;
    final limit = account.lockedUntil;
    final now = _now();
    if (limit != null && now.isBefore(limit)) {
      final rest = limit.difference(now);
      if (rest <= _maxLockoutDuration) wall = rest;
    }
    var stopwatch = Duration.zero;
    if (_lockoutEnd case final end?) {
      final rest = end - _stopwatch();
      if (rest > Duration.zero) stopwatch = rest;
    }
    return wall > stopwatch ? wall : stopwatch;
  }

  bool _isLocked(Account account) => _wait(account) > Duration.zero;

  Future<LoginResult> _recordAttempt(Account account, bool valid) async {
    final failures = valid ? 0 : account.failures + 1;
    final locked = failures >= _maxFailures;
    final duration = lockoutDuration(account.lockouts);
    await (_db.update(
      _db.accounts,
    )..where((a) => a.id.equals(account.id))).write(
      AccountsCompanion(
        failures: Value(locked ? 0 : failures),
        lockedUntil: Value(locked ? _now().add(duration) : null),
        // A successful login clears the lockout history.
        lockouts: valid
            ? const Value(0)
            : locked
            ? Value(account.lockouts + 1)
            : const Value.absent(),
      ),
    );
    if (locked) {
      _lockoutEnd = _stopwatch() + duration;
    } else if (valid) {
      _lockoutEnd = null;
    }
    if (valid) return LoginResult.success;
    return locked ? LoginResult.locked : LoginResult.rejected;
  }

  void _checkPassword(String password) {
    if (password.length < minPasswordLength) {
      throw ArgumentError('Password too short.');
    }
  }
}

String _normalizeUsername(String username) => username.trim().toLowerCase();

String _normalizeCode(String code) =>
    code.toUpperCase().replaceAll(RegExp(r'[^0-9A-Z]'), '');

Uint8List _generateSalt() {
  final random = Random.secure();
  return Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));
}

String _generateRecoveryCode() {
  final random = Random.secure();
  String block() => List.generate(
    4,
    (_) => _codeAlphabet[random.nextInt(_codeAlphabet.length)],
  ).join();
  return '${block()}-${block()}-${block()}';
}

/// Slow by design: runs off the UI thread.
Future<Uint8List> _derive(String secret, List<int> salt, int iterations) {
  return Isolate.run(() async {
    final key = await Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    ).deriveKey(secretKey: SecretKey(utf8.encode(secret)), nonce: salt);
    return Uint8List.fromList(await key.extractBytes());
  });
}

bool _constantTimeEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var difference = 0;
  for (var i = 0; i < a.length; i++) {
    difference |= a[i] ^ b[i];
  }
  return difference == 0;
}

extension on Stopwatch {
  /// Elapsed time, read on each call.
  Duration Function() get elapsedFunction =>
      () => elapsed;
}
